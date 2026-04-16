# 故障排查

## 常见错误码

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `NO_API_KEY` | 未配置密钥 | 执行 `moji-use-weather trial` 或 `moji-use-weather login` |
| `INVALID_KEY` | 密钥无效/过期 | 重新执行 `moji-use-weather claim <snsidKey>` 或 `moji-use-weather trial` |
| `QUOTA_EXCEEDED` | 配额用尽 | 等待配额重置或升级账号 |
| `RATE_LIMITED` | QPS 超限 | 降低请求频率（试用 QPS=3） |
| `INVALID_LOCATION` | 位置无法识别 | 检查城市名拼写或使用经纬度格式 |
| `NETWORK_ERROR` | 网络连接失败 | 检查网络连接，重试 |
| `TIMEOUT` | 请求超时 | 重试，默认 15 秒超时 |

## 试用限制

匿名试用 (`moji-use-weather trial`) 的限制：

| 限制项 | 值 |
|--------|-----|
| 可用接口 | `now`, `forecast` |
| QPS | 3 请求/秒 |
| 不可用接口 | hourly, aqi, alert, index, shortterm, tide, history, restrict, remind |

当用户使用试用模式调用不支持的接口时，应引导注册账号：
```
该接口需要注册账号才能使用。执行 moji-use-weather login 注册后可解锁全部 12 个接口。
```

## 位置参数排查

| 问题 | 排查 |
|------|------|
| 城市找不到 | 尝试全名（"北京市"而非"北京"），或使用拼音 |
| 精度不够 | 使用经纬度格式: `39.9042,116.4074` |
| shortterm 不准 | shortterm 强烈建议用经纬度，城市名精度不足 |

## 调试模式

```bash
DEBUG=moji-use-weather moji-use-weather now 北京
```

开启详细日志，输出请求 URL、签名参数、响应状态等。
