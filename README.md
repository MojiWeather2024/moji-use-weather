# 🌦️ moji-use-weather

墨迹天气 CLI — 12 种天气数据查询，零外部依赖，单文件二进制，开箱即用。

支持实况天气、多日预报、空气质量、生活指数、短时降水、天气预警、历史天气、潮汐、限行等查询，覆盖全球城市。内置 AI Skill，可与 Claude Code、Kiro、Codex、OpenClaw、OpenCode 等 AI 编程助手无缝集成。

## 特性

- 🚀 单文件二进制，无需 Node/Python/Java 等运行时
- 🌍 支持全球城市名或经纬度定位
- 📊 12 种天气数据接口
- 🤖 内置 AI Skill，支持 Claude Code / Kiro / Codex / OpenClaw / OpenCode
- 🔑 匿名免费试用，零门槛上手

## 安装

### Claude Code

```
/plugin marketplace add MojiWeather2024/moji-use-weather
/plugin install moji-use-weather@moji-use-weather
```

或通过 npx：

```bash
npx skills add git@github.com:MojiWeather2024/moji-use-weather.git
```

### Kiro

在 Kiro 对话中输入：

```
安装 moji-use-weather skill，来源 https://github.com/MojiWeather2024/moji-use-weather
```

或手动将项目根目录中的 Skill 文件（`SKILL.md`、`references/`、`examples/`）复制到 `~/.kiro/skills/moji-use-weather/`。

### Codex

在 Codex 聊天中输入：

```
$skill-installer https://github.com/MojiWeather2024/moji-use-weather/tree/main
```

### 其他 AI 助手

让你的 AI 助手执行：

```
安装 moji-use-weather skill，来源 https://github.com/MojiWeather2024/moji-use-weather
```

也可以手动将项目根目录中的 Skill 文件复制到对应平台的 skills 目录中。

### 脚本安装（CLI 二进制 + Skill 一键部署）

脚本会自动下载 CLI 二进制并将 Skill 注册到所有已安装的 AI 编程助手平台。

**macOS / Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/MojiWeather2024/moji-use-weather/main/install.sh | bash
```

**Windows (PowerShell)**

```powershell
irm https://raw.githubusercontent.com/MojiWeather2024/moji-use-weather/main/install.ps1 | iex
```

**更多选项**

```bash
# 安装指定版本
curl -fsSL https://raw.githubusercontent.com/MojiWeather2024/moji-use-weather/main/install.sh | bash -s -- --version v1.0.0

# 仅注册 AI Skill（不下载二进制）
curl -fsSL https://raw.githubusercontent.com/MojiWeather2024/moji-use-weather/main/install.sh | bash -s -- --skill-only

# 卸载
curl -fsSL https://raw.githubusercontent.com/MojiWeather2024/moji-use-weather/main/install.sh | bash -s -- --uninstall
```

## 快速开始

```bash
# 首次使用，免费试用（无需注册）
moji-use-weather trial

# 查询实况天气
moji-use-weather now 北京

# 多日预报
moji-use-weather forecast 上海
```

## 命令一览

| 命令 | 说明 | 免费试用 |
|------|------|:--------:|
| `now <位置>` | 实况天气（温度、体感、风力、湿度等） | ✅ |
| `forecast <位置>` | 多日天气预报（7/15/40天） | ✅ |
| `index <位置>` | 15种生活指数（穿衣、雨伞、感冒、洗车等） | ❌ |
| `aqi <位置>` | 空气质量（AQI、PM2.5、污染物） | ❌ |
| `hourly <位置>` | 逐小时预报（24/36小时） | ❌ |
| `shortterm <经纬度>` | 分钟级短时降水预报（未来2小时） | ❌ |
| `history <位置> <日期>` | 历史天气（指定日期或整月） | ❌ |
| `alert <位置>` | 气象预警信息 | ❌ |
| `restrict <位置>` | 机动车限行查询 | ❌ |
| `tide <位置>` | 潮汐数据 | ❌ |
| `remind <位置>` | 天气提醒文案 | ❌ |
| `city <位置>` | 城市信息查询 | ❌ |

位置参数支持：城市名（`北京` / `beijing`）或经纬度（`39.9,116.4`）。

## 使用示例

```bash
# 实况天气
moji-use-weather now 北京

# 生活指数（穿什么、带不带伞）
moji-use-weather index 成都

# 空气质量
moji-use-weather aqi 广州

# 短时降水（建议用经纬度，更精确）
moji-use-weather shortterm 39.9042,116.4074

# 逐小时预报
moji-use-weather hourly 深圳

# 历史天气
moji-use-weather history 北京 20250214

# 天气预警
moji-use-weather alert 深圳

# 限行查询
moji-use-weather restrict 北京

# 潮汐
moji-use-weather tide 青岛
```

## 认证方式

### 匿名免费试用（推荐先体验）

```bash
moji-use-weather trial
```

自动用设备 ID 注册，无需手机号。支持 `now` 和 `forecast` 两个接口。

### 注册账号（解锁全部功能）

```bash
moji-use-weather login
```

手机号注册，解锁全部 12 个接口及更高配额。

### 手动配置密钥

```bash
moji-use-weather claim <snsidKey>
```

密钥配置文件搜索顺序：`~/.openclaw/.env` → `~/.moji/.env` → `./.env`

## AI Skill 集成

安装后，Skill 会自动注册到已安装的 AI 编程助手平台：

| 平台 | 安装方式 | Skill 目录 |
|------|---------|-----------|
| Claude Code | `/plugin marketplace add` 或脚本安装 | `~/.claude/skills/moji-use-weather/` |
| Kiro | 对话安装或脚本安装 | `~/.kiro/skills/moji-use-weather/` |
| Codex | `$skill-installer` | 项目内 `.codex/skills/` |
| OpenClaw | 脚本安装 | `~/.openclaw/skills/moji-use-weather/` |
| OpenCode | 脚本安装 | `~/.opencode/skills/moji-use-weather/` |

注册后，在对话中直接说"北京天气怎么样"、"明天要带伞吗"等自然语言即可触发天气查询。

## 支持平台

| 平台 | 架构 | 文件 |
|------|------|------|
| macOS | arm64 (Apple Silicon) | `moji-use-weather-darwin-arm64.tar.gz` |
| macOS | x64 (Intel) | `moji-use-weather-darwin-x64.tar.gz` |
| Linux | x64 | `moji-use-weather-linux-x64.tar.gz` |
| Windows | x64 | `moji-use-weather-win-x64.zip` |

## Contributing

欢迎贡献！无论是 Bug 报告、新功能建议还是 Pull Request，都非常感谢。

- 发现问题或过时信息？请提 Issue。天气数据 API 变化频繁，保持更新需要社区的力量。
- 有改进建议？欢迎提 PR，请附上简要说明。

## License

MIT
