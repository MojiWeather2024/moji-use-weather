# 安装与认证

## 安装方式

moji-use-weather 是编译后的单文件二进制，零外部依赖。

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/MojiWeather2024/moji-use-weather/main/install.sh | bash

# 或本地安装
./install.sh
```

## 认证方式

### 1. 匿名免费试用（零门槛）

```bash
moji-use-weather trial
```

- 自动用设备硬件ID注册，无需手机号
- 密钥自动写入 `~/.openclaw/.env`
- **限制**: 仅支持 `now`（实况）和 `forecast`（预报），QPS=3

### 2. 注册账号（全功能）

```bash
moji-use-weather login
```

- 打开 H5 注册页面，手机号注册
- 解锁全部 12 个接口，更高配额

### 3. 手动配置密钥

```bash
moji-use-weather claim <snsidKey>
```

- 已有墨迹会员ID加密值时直接领取密钥

## 密钥配置

| 变量 | 说明 | 必需 |
|------|------|------|
| `MOJI_WEATHER_APP_KEY` | 应用密钥 | 自动领取 |
| `MOJI_WEATHER_APP_SECRET` | 应用秘钥 | 自动领取 |
| `MOJI_WEATHER_SNSID_KEY` | 会员ID加密值 | 可选 |
| `MOJI_WEATHER_ENDPOINT` | API 地址 | 默认 `https://equity-api.moji.com` |

配置文件搜索顺序: `~/.openclaw/.env` → `~/.moji/.env` → `./.env`

## 无密钥错误处理

当命令返回 `"error": "NO_API_KEY"` 时：

1. 告知用户未配置密钥，提供两个选择
2. 选择**免费试用** → `moji-use-weather trial` → 重新执行原始查询
3. 选择**注册账号** → `moji-use-weather login` → 展示 H5 链接
4. 匿名试用不支持的接口（aqi/alert/index 等），引导注册账号
