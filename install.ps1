#Requires -Version 5.1
<#
.SYNOPSIS
    moji-use-weather Windows 安装脚本
.DESCRIPTION
    下载 moji-use-weather 预编译二进制，注册 Skill 到多个 AI 编程助手平台
.PARAMETER Version
    安装指定版本 (默认: latest)
.PARAMETER InstallDir
    安装目录 (默认: %LOCALAPPDATA%\moji-use-weather)
.PARAMETER Uninstall
    卸载 moji-use-weather
.PARAMETER SkillOnly
    仅注册 Skill，不下载二进制
.EXAMPLE
    irm https://raw.githubusercontent.com/MojiWeather2024/moji-use-weather/main/install.ps1 | iex
.EXAMPLE
    .\install.ps1 -Version v1.2.0
.EXAMPLE
    .\install.ps1 -Uninstall
#>

param(
    [string]$Version = "latest",
    [string]$InstallDir = "",
    [switch]$Uninstall,
    [switch]$SkillOnly
)

$ErrorActionPreference = "Stop"

# ─── 配置 ───────────────────────────────────────────
$Repo = "MojiWeather2024/moji-use-weather"
$SkillName = "moji-weather-equity"
$AssetName = "moji-use-weather-win-x64.zip"
if (-not $InstallDir) {
    $InstallDir = Join-Path $env:LOCALAPPDATA "moji-use-weather"
}
$SkillBackupDir = Join-Path $HOME ".ai-skills"
$EnvDir = Join-Path $HOME ".openclaw"

$Platforms = @(
    @{ Name = "claude-code"; ConfigDir = ".claude"; SkillDir = ".claude\skills" }
    @{ Name = "openclaw";    ConfigDir = ".openclaw"; SkillDir = ".openclaw\skills" }
    @{ Name = "opencode";    ConfigDir = ".opencode"; SkillDir = ".opencode\skills" }
    @{ Name = "kiro";        ConfigDir = ".kiro"; SkillDir = ".kiro\skills" }
)

# ─── 输出函数 ────────────────────────────────────────
function Write-Info  { Write-Host "[INFO] " -ForegroundColor Blue -NoNewline; Write-Host $args }
function Write-Ok    { Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host $args }
function Write-Warn  { Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline; Write-Host $args }
function Write-Err   { Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $args }

# ─── 获取下载地址 ─────────────────────────────────────
function Get-DownloadUrl {
    if ($Version -eq "latest") {
        $apiUrl = "https://api.github.com/repos/$Repo/releases/latest"
    } else {
        $apiUrl = "https://api.github.com/repos/$Repo/releases/tags/$Version"
    }

    Write-Info "查询 Release: $Version..."

    try {
        $release = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "moji-use-weather-installer" }
    } catch {
        Write-Err "无法访问 GitHub API: $_"
        exit 1
    }

    $script:SkillVersion = $release.tag_name

    $asset = $release.assets | Where-Object { $_.name -eq $AssetName } | Select-Object -First 1
    if (-not $asset) {
        Write-Err "找不到 $AssetName 的下载地址"
        Write-Err "请确认 Release 是否存在: https://github.com/$Repo/releases"
        exit 1
    }
    $script:DownloadUrl = $asset.browser_download_url

    $checksumAsset = $release.assets | Where-Object { $_.name -eq "checksums.txt" } | Select-Object -First 1
    $script:ChecksumUrl = if ($checksumAsset) { $checksumAsset.browser_download_url } else { $null }

    Write-Info "版本: $script:SkillVersion"
}

# ─── 下载并安装二进制 ─────────────────────────────────
function Install-Binary {
    $tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "moji-use-weather-install"
    if (Test-Path $tmpDir) { Remove-Item $tmpDir -Recurse -Force }
    New-Item -ItemType Directory -Path $tmpDir | Out-Null

    $zipFile = Join-Path $tmpDir $AssetName

    Write-Info "下载 $AssetName..."
    Invoke-WebRequest -Uri $script:DownloadUrl -OutFile $zipFile -UseBasicParsing

    # SHA256 校验
    if ($script:ChecksumUrl) {
        Write-Info "校验 SHA256..."
        $checksumFile = Join-Path $tmpDir "checksums.txt"
        Invoke-WebRequest -Uri $script:ChecksumUrl -OutFile $checksumFile -UseBasicParsing

        $checksumContent = Get-Content $checksumFile
        $expectedLine = $checksumContent | Where-Object { $_ -match $AssetName }
        if ($expectedLine) {
            $expected = ($expectedLine -split '\s+')[0]
            $actual = (Get-FileHash -Path $zipFile -Algorithm SHA256).Hash.ToLower()
            if ($expected -ne $actual) {
                Write-Err "SHA256 校验失败！"
                Write-Err "期望: $expected"
                Write-Err "实际: $actual"
                Remove-Item $tmpDir -Recurse -Force
                exit 1
            }
            Write-Ok "SHA256 校验通过"
        } else {
            Write-Warn "checksums.txt 中未找到 $AssetName 的校验和，跳过校验"
        }
    } else {
        Write-Warn "未找到 checksums.txt，跳过 SHA256 校验"
    }

    # 解压安装
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir | Out-Null
    }
    Expand-Archive -Path $zipFile -DestinationPath $InstallDir -Force

    Remove-Item $tmpDir -Recurse -Force
    Write-Ok "已安装到 $InstallDir\moji-use-weather.exe"
}

# ─── 配置 PATH ────────────────────────────────────────
function Set-UserPath {
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -split ';' -contains $InstallDir) {
        return
    }

    $newPath = "$InstallDir;$currentPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    $env:Path = "$InstallDir;$env:Path"
    Write-Info "已添加 $InstallDir 到用户 PATH"
    Write-Warn "新打开的终端会自动生效，当前终端已临时生效"
}

# ─── 注册 Skill 到各平台 ─────────────────────────────
function Register-Skills {
    $skillUrl = "https://raw.githubusercontent.com/$Repo/$($script:SkillVersion)/SKILL.md"
    Write-Info "下载 Skill 定义..."

    try {
        $skillContent = Invoke-WebRequest -Uri $skillUrl -UseBasicParsing | Select-Object -ExpandProperty Content
    } catch {
        # 回退到 main 分支
        $skillUrl = "https://raw.githubusercontent.com/$Repo/main/SKILL.md"
        try {
            $skillContent = Invoke-WebRequest -Uri $skillUrl -UseBasicParsing | Select-Object -ExpandProperty Content
        } catch {
            Write-Err "无法下载 SKILL.md: $_"
            return
        }
    }

    Write-Info "扫描已安装的智能体平台..."
    Write-Host ""

    $registered = 0
    foreach ($platform in $Platforms) {
        $configPath = Join-Path $HOME $platform.ConfigDir
        $skillPath = Join-Path $HOME $platform.SkillDir
        $skillFile = Join-Path $skillPath "$SkillName.md"

        if (Test-Path $configPath) {
            if (-not (Test-Path $skillPath)) {
                New-Item -ItemType Directory -Path $skillPath | Out-Null
            }
            Set-Content -Path $skillFile -Value $skillContent -Encoding UTF8
            Write-Ok "  $($platform.Name) -> ~\$($platform.SkillDir)\$SkillName.md"
            $registered++
        } else {
            Write-Host "  " -NoNewline
            Write-Host "-- " -ForegroundColor Yellow -NoNewline
            Write-Host "$($platform.Name) (未检测到，跳过)"
        }
    }

    # 通用备份
    if (-not (Test-Path $SkillBackupDir)) {
        New-Item -ItemType Directory -Path $SkillBackupDir | Out-Null
    }
    Set-Content -Path (Join-Path $SkillBackupDir "$SkillName.md") -Value $skillContent -Encoding UTF8
    Write-Ok "  通用备份 -> ~\.ai-skills\$SkillName.md"

    Write-Host ""
    if ($registered -gt 0) {
        Write-Ok "已注册到 $registered 个智能体平台"
    } else {
        Write-Warn "未检测到任何已安装的智能体平台"
        Write-Info "Skill 已保存到 ~\.ai-skills\$SkillName.md"
        Write-Info "您可以手动复制到对应平台的 skills 目录"
    }
}

# ─── 创建环境变量配置 ─────────────────────────────────
function New-EnvConfig {
    if (-not (Test-Path $EnvDir)) {
        New-Item -ItemType Directory -Path $EnvDir | Out-Null
    }

    $envFile = Join-Path $EnvDir ".env"
    if (-not (Test-Path $envFile)) {
        @"
# moji-use-weather 环境变量配置
# 首次使用时会自动引导领取密钥，也可手动配置

# 会员ID加密值（必需，首次使用自动领取）
# MOJI_WEATHER_SNSID_KEY=your_key_here
"@ | Set-Content -Path $envFile -Encoding UTF8
        Write-Ok "已创建配置文件: $envFile"
    } else {
        Write-Info "配置文件已存在: $envFile（保留现有配置）"
    }
}

# ─── 验证安装 ─────────────────────────────────────────
function Test-Installation {
    Write-Host ""
    $exePath = Join-Path $InstallDir "moji-use-weather.exe"
    if (Test-Path $exePath) {
        try {
            $ver = & $exePath version 2>&1
            Write-Ok "验证通过: moji-use-weather $ver"
        } catch {
            Write-Ok "已安装，请重新打开终端后运行: moji-use-weather version"
        }
    } else {
        Write-Warn "moji-use-weather.exe 未找到于 $InstallDir"
    }
}

# ─── 卸载 ─────────────────────────────────────────────
function Invoke-Uninstall {
    Write-Info "开始卸载 moji-use-weather..."
    Write-Host ""

    # 删除二进制
    $exePath = Join-Path $InstallDir "moji-use-weather.exe"
    if (Test-Path $exePath) {
        Remove-Item $exePath -Force
        Write-Ok "已删除: $exePath"
    } else {
        Write-Info "未找到 moji-use-weather.exe"
    }

    # 清理空安装目录
    if ((Test-Path $InstallDir) -and -not (Get-ChildItem $InstallDir)) {
        Remove-Item $InstallDir -Force
    }

    # 从 PATH 移除
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $pathList = $currentPath -split ';' | Where-Object { $_ -ne $InstallDir }
    [Environment]::SetEnvironmentVariable("Path", ($pathList -join ';'), "User")

    # 删除各平台 Skill
    foreach ($platform in $Platforms) {
        $skillFile = Join-Path $HOME $platform.SkillDir "$SkillName.md"
        if (Test-Path $skillFile) {
            Remove-Item $skillFile -Force
            Write-Ok "已删除: ~\$($platform.SkillDir)\$SkillName.md"
        }
    }

    # 删除通用备份
    $backupFile = Join-Path $SkillBackupDir "$SkillName.md"
    if (Test-Path $backupFile) {
        Remove-Item $backupFile -Force
        Write-Ok "已删除: ~\.ai-skills\$SkillName.md"
    }

    Write-Host ""
    Write-Info "保留了 $EnvDir\.env（用户配置数据不删除）"
    Write-Info "如需彻底清理，请手动删除: Remove-Item '$EnvDir' -Recurse"
    Write-Host ""
    Write-Ok "卸载完成"
}

# ─── 主流程 ───────────────────────────────────────────
function Main {
    Write-Host ""
    Write-Host "=================================="
    Write-Host "  moji-use-weather 安装程序 (Windows)"
    Write-Host "=================================="
    Write-Host ""

    if ($Uninstall) {
        Invoke-Uninstall
        return
    }

    if ($SkillOnly) {
        $script:SkillVersion = "main"
        Register-Skills
        return
    }

    # 检测架构
    $arch = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture
    if ($arch -ne "X64") {
        Write-Err "当前仅支持 x64 架构，检测到: $arch"
        exit 1
    }
    Write-Info "检测到平台: win-x64"

    Get-DownloadUrl
    Install-Binary
    Set-UserPath
    Register-Skills
    New-EnvConfig
    Test-Installation

    Write-Host ""
    Write-Host "=================================="
    Write-Host "  安装完成！"
    Write-Host "=================================="
    Write-Host ""
    Write-Host "  快速验证: moji-use-weather now 北京"
    Write-Host ""
}

Main
