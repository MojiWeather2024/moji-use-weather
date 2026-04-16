#!/usr/bin/env bash
set -euo pipefail

# ─── 配置 ───────────────────────────────────────────
REPO="sheldoncopperzh-droid/muwtest"
SKILL_NAME="moji-weather-equity"
DEFAULT_INSTALL_DIR="$HOME/.local/bin"
SKILL_BACKUP_DIR="$HOME/.ai-skills"
ENV_DIR="$HOME/.openclaw"

# 智能体平台列表: config_dir|skill_dir
PLATFORMS=(
  ".claude|.claude/skills"
  ".openclaw|.openclaw/skills"
  ".opencode|.opencode/skills"
  ".kiro|.kiro/skills"
)

# ─── 颜色输出 ────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ─── 参数解析 ────────────────────────────────────────
ACTION="install"
VERSION="latest"
INSTALL_DIR="$DEFAULT_INSTALL_DIR"
SKILL_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --uninstall)   ACTION="uninstall"; shift ;;
    --version)     VERSION="$2"; shift 2 ;;
    --install-dir) INSTALL_DIR="$2"; shift 2 ;;
    --skill-only)  SKILL_ONLY=true; shift ;;
    --help|-h)     ACTION="help"; shift ;;
    *) error "未知参数: $1"; exit 1 ;;
  esac
done

# ─── 帮助信息 ────────────────────────────────────────
show_help() {
  cat <<'EOF'
moji-use-weather 安装脚本

用法:
  curl -fsSL https://raw.githubusercontent.com/sheldoncopperzh-droid/muwtest/main/install.sh | bash

参数:
  --version <tag>    安装指定版本 (默认: latest)
  --install-dir <dir> 指定安装目录 (默认: ~/.local/bin)
  --skill-only       仅注册 Skill，不下载二进制
  --uninstall        卸载 moji-use-weather 及所有 Skill 注册
  -h, --help         显示帮助

示例:
  # 安装最新版
  curl -fsSL https://raw.githubusercontent.com/sheldoncopperzh-droid/muwtest/main/install.sh | bash

  # 安装指定版本
  curl -fsSL https://raw.githubusercontent.com/sheldoncopperzh-droid/muwtest/main/install.sh | bash -s -- --version v1.2.0

  # 卸载
  curl -fsSL https://raw.githubusercontent.com/sheldoncopperzh-droid/muwtest/main/install.sh | bash -s -- --uninstall
EOF
}

# ─── 平台检测 ────────────────────────────────────────
detect_platform() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Darwin) os="darwin" ;;
    Linux)  os="linux" ;;
    *)      error "不支持的操作系统: $os"; exit 1 ;;
  esac

  case "$arch" in
    arm64|aarch64) arch="arm64" ;;
    x86_64|amd64)  arch="x64" ;;
    *)             error "不支持的 CPU 架构: $arch"; exit 1 ;;
  esac

  # linux-arm64 暂不支持
  if [[ "$os" == "linux" && "$arch" == "arm64" ]]; then
    error "暂不支持 linux-arm64，请使用 x64 架构"
    exit 1
  fi

  PLATFORM="${os}-${arch}"
  ASSET_NAME="moji-use-weather-${PLATFORM}.tar.gz"
  info "检测到平台: ${PLATFORM}"
}

# ─── 获取下载地址 ─────────────────────────────────────
get_download_url() {
  local api_url release_data

  if [[ "$VERSION" == "latest" ]]; then
    api_url="https://api.github.com/repos/${REPO}/releases/latest"
  else
    api_url="https://api.github.com/repos/${REPO}/releases/tags/${VERSION}"
  fi

  info "查询 Release: ${VERSION}..."
  release_data=$(curl -sL "$api_url") || {
    error "无法访问 GitHub API"; exit 1
  }

  DOWNLOAD_URL=$(echo "$release_data" | grep -o "\"browser_download_url\": *\"[^\"]*${ASSET_NAME}\"" | head -1 | cut -d'"' -f4)
  CHECKSUM_URL=$(echo "$release_data" | grep -o "\"browser_download_url\": *\"[^\"]*checksums.txt\"" | head -1 | cut -d'"' -f4)
  SKILL_VERSION=$(echo "$release_data" | grep -o "\"tag_name\": *\"[^\"]*\"" | head -1 | cut -d'"' -f4)

  if [[ -z "$DOWNLOAD_URL" ]]; then
    error "找不到 ${ASSET_NAME} 的下载地址"
    error "请确认 Release 是否存在: https://github.com/${REPO}/releases"
    exit 1
  fi

  info "版本: ${SKILL_VERSION}"
}

# ─── 下载并安装二进制 ─────────────────────────────────
install_binary() {
  local tmp_dir tmp_file

  tmp_dir=$(mktemp -d)
  tmp_file="${tmp_dir}/${ASSET_NAME}"

  info "下载 ${ASSET_NAME}..."
  curl -fSL --progress-bar -o "$tmp_file" "$DOWNLOAD_URL"

  # SHA256 校验
  if [[ -n "$CHECKSUM_URL" ]]; then
    info "校验 SHA256..."
    local checksums_file="${tmp_dir}/checksums.txt"
    curl -fsSL -o "$checksums_file" "$CHECKSUM_URL"

    local expected actual
    expected=$(grep "$ASSET_NAME" "$checksums_file" | awk '{print $1}')
    if [[ -n "$expected" ]]; then
      if command -v sha256sum &>/dev/null; then
        actual=$(sha256sum "$tmp_file" | awk '{print $1}')
      else
        actual=$(shasum -a 256 "$tmp_file" | awk '{print $1}')
      fi
      if [[ "$expected" != "$actual" ]]; then
        error "SHA256 校验失败！"
        error "期望: $expected"
        error "实际: $actual"
        rm -rf "$tmp_dir"
        exit 1
      fi
      ok "SHA256 校验通过"
    else
      warn "checksums.txt 中未找到 ${ASSET_NAME} 的校验和，跳过校验"
    fi
  else
    warn "未找到 checksums.txt，跳过 SHA256 校验"
  fi

  # 解压安装
  mkdir -p "$INSTALL_DIR"
  tar -xzf "$tmp_file" -C "$INSTALL_DIR"
  chmod +x "${INSTALL_DIR}/moji-use-weather"

  rm -rf "$tmp_dir"
  ok "已安装到 ${INSTALL_DIR}/moji-use-weather"
}

# ─── 配置 PATH ────────────────────────────────────────
ensure_path() {
  if echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    return
  fi

  local shell_rc=""
  case "${SHELL:-}" in
    */zsh)  shell_rc="$HOME/.zshrc" ;;
    */bash) shell_rc="$HOME/.bashrc" ;;
    */fish) shell_rc="$HOME/.config/fish/config.fish" ;;
    *)      shell_rc="$HOME/.profile" ;;
  esac

  if [[ -n "$shell_rc" ]]; then
    # 避免重复追加
    if ! grep -q "# moji-use-weather" "$shell_rc" 2>/dev/null; then
      echo "" >> "$shell_rc"
      echo "# moji-use-weather" >> "$shell_rc"
      if [[ "$shell_rc" == *fish* ]]; then
        echo "set -gx PATH \"${INSTALL_DIR}\" \$PATH" >> "$shell_rc"
      else
        echo "export PATH=\"${INSTALL_DIR}:\$PATH\"" >> "$shell_rc"
      fi
      info "已添加 ${INSTALL_DIR} 到 ${shell_rc}"
      warn "请执行 source ${shell_rc} 或重新打开终端"
    fi
  fi

  export PATH="${INSTALL_DIR}:$PATH"
}

# ─── Skill 目录中需要下载的文件列表 ─────────────────
SKILL_FILES=(
  "skill/SKILL.md"
  "skill/skill.json"
  "skill/references/setup.md"
  "skill/references/api-realtime.md"
  "skill/references/api-forecast.md"
  "skill/references/api-life.md"
  "skill/references/api-special.md"
  "skill/references/interpretation.md"
  "skill/references/troubleshooting.md"
  "skill/examples/usage-patterns.md"
  "skill/evals/evals.json"
)

# ─── 注册 Skill 到各平台 ─────────────────────────────
register_skills() {
  local branch="${SKILL_VERSION:-main}"
  local base_url="https://raw.githubusercontent.com/${REPO}/${branch}"
  local registered=0

  # 下载完整 skill 目录到临时位置
  local tmp_skill
  tmp_skill=$(mktemp -d)
  local skill_root="${tmp_skill}/${SKILL_NAME}"

  info "下载 Skill 定义 (分层文档)..."
  local download_ok=true
  for rel_path in "${SKILL_FILES[@]}"; do
    local target_path="${skill_root}/${rel_path#skill/}"
    mkdir -p "$(dirname "$target_path")"
    if ! curl -fsSL -o "$target_path" "${base_url}/${rel_path}" 2>/dev/null; then
      # 回退到 main 分支
      if ! curl -fsSL -o "$target_path" "https://raw.githubusercontent.com/${REPO}/main/${rel_path}" 2>/dev/null; then
        warn "无法下载 ${rel_path}，跳过"
      fi
    fi
  done

  # 校验核心文件
  if [[ ! -f "${skill_root}/SKILL.md" ]]; then
    error "核心文件 SKILL.md 下载失败"
    rm -rf "$tmp_skill"
    return 1
  fi
  ok "Skill 文件下载完成 ($(find "$skill_root" -type f | wc -l | tr -d ' ') 个文件)"

  info "扫描已安装的智能体平台..."
  echo ""

  for entry in "${PLATFORMS[@]}"; do
    local config_dir skill_dir platform_name
    config_dir="${entry%%|*}"
    skill_dir="${entry##*|}"
    platform_name="$config_dir"

    local full_config="$HOME/$config_dir"
    local full_skill="$HOME/$skill_dir"

    if [[ -d "$full_config" ]]; then
      # 清理旧的单文件格式
      rm -f "${full_skill}/${SKILL_NAME}.md"
      # 安装完整目录
      rm -rf "${full_skill}/${SKILL_NAME}"
      mkdir -p "${full_skill}"
      cp -r "$skill_root" "${full_skill}/${SKILL_NAME}"
      ok "  ${platform_name} -> ~/${skill_dir}/${SKILL_NAME}/"
      registered=$((registered + 1))
    else
      echo -e "  ${YELLOW}--${NC} ${platform_name} (未检测到，跳过)"
    fi
  done

  # 通用备份
  rm -f "${SKILL_BACKUP_DIR}/${SKILL_NAME}.md"
  rm -rf "${SKILL_BACKUP_DIR}/${SKILL_NAME}"
  mkdir -p "$SKILL_BACKUP_DIR"
  cp -r "$skill_root" "${SKILL_BACKUP_DIR}/${SKILL_NAME}"
  ok "  通用备份 -> ~/.ai-skills/${SKILL_NAME}/"

  rm -rf "$tmp_skill"

  echo ""
  if [[ $registered -gt 0 ]]; then
    ok "已注册到 ${registered} 个智能体平台"
  else
    warn "未检测到任何已安装的智能体平台"
    info "Skill 已保存到 ~/.ai-skills/${SKILL_NAME}/"
    info "您可以手动复制到对应平台的 skills 目录"
  fi
}

# ─── 创建环境变量配置 ─────────────────────────────────
create_env() {
  mkdir -p "$ENV_DIR"
  if [[ ! -f "${ENV_DIR}/.env" ]]; then
    cat > "${ENV_DIR}/.env" << 'ENVEOF'
# moji-use-weather 环境变量配置
# 首次使用时会自动引导领取密钥，也可手动配置

# 会员ID加密值（必需，首次使用自动领取）
# MOJI_WEATHER_SNSID_KEY=your_key_here
ENVEOF
    ok "已创建配置文件: ${ENV_DIR}/.env"
  else
    info "配置文件已存在: ${ENV_DIR}/.env（保留现有配置）"
  fi
}

# ─── 验证安装 ─────────────────────────────────────────
verify_install() {
  echo ""
  if command -v moji-use-weather &>/dev/null; then
    local ver
    ver=$(moji-use-weather version 2>/dev/null || echo "unknown")
    ok "验证通过: moji-use-weather ${ver}"
  else
    warn "moji-use-weather 未在 PATH 中找到"
    info "请执行: source ~/.zshrc 或重新打开终端"
    info "然后运行: moji-use-weather version"
  fi
}

# ─── 卸载 ─────────────────────────────────────────────
do_uninstall() {
  info "开始卸载 moji-use-weather..."
  echo ""

  # 删除二进制
  local bin_path
  bin_path=$(command -v moji-use-weather 2>/dev/null || echo "${INSTALL_DIR}/moji-use-weather")
  if [[ -f "$bin_path" ]]; then
    rm -f "$bin_path"
    ok "已删除: $bin_path"
  else
    info "未找到 moji-use-weather 二进制文件"
  fi

  # 删除各平台 Skill（兼容旧单文件和新目录两种格式）
  for entry in "${PLATFORMS[@]}"; do
    local skill_dir="${entry##*|}"
    local skill_file="$HOME/$skill_dir/${SKILL_NAME}.md"
    local skill_dir_path="$HOME/$skill_dir/${SKILL_NAME}"
    if [[ -f "$skill_file" ]]; then
      rm -f "$skill_file"
      ok "已删除: ~/${skill_dir}/${SKILL_NAME}.md"
    fi
    if [[ -d "$skill_dir_path" ]]; then
      rm -rf "$skill_dir_path"
      ok "已删除: ~/${skill_dir}/${SKILL_NAME}/"
    fi
  done

  # 删除通用备份（兼容两种格式）
  if [[ -f "${SKILL_BACKUP_DIR}/${SKILL_NAME}.md" ]]; then
    rm -f "${SKILL_BACKUP_DIR}/${SKILL_NAME}.md"
    ok "已删除: ~/.ai-skills/${SKILL_NAME}.md"
  fi
  if [[ -d "${SKILL_BACKUP_DIR}/${SKILL_NAME}" ]]; then
    rm -rf "${SKILL_BACKUP_DIR}/${SKILL_NAME}"
    ok "已删除: ~/.ai-skills/${SKILL_NAME}/"
  fi

  echo ""
  info "保留了 ${ENV_DIR}/.env（用户配置数据不删除）"
  info "如需彻底清理，请手动删除: rm -rf ${ENV_DIR}"
  echo ""
  ok "卸载完成"
}

# ─── 主流程 ───────────────────────────────────────────
main() {
  echo ""
  echo "=================================="
  echo "  moji-use-weather 安装程序"
  echo "=================================="
  echo ""

  case "$ACTION" in
    help)
      show_help
      exit 0
      ;;
    uninstall)
      do_uninstall
      exit 0
      ;;
    install)
      if [[ "$SKILL_ONLY" == true ]]; then
        SKILL_VERSION="main"
        register_skills
        exit 0
      fi

      detect_platform
      get_download_url
      install_binary
      ensure_path
      register_skills
      create_env
      verify_install

      echo ""
      echo "=================================="
      echo "  安装完成！"
      echo "=================================="
      echo ""
      echo "  快速验证: moji-use-weather now 北京"
      echo ""
      ;;
  esac
}

main
