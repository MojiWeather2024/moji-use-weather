---
name: moji-use-weather
description: Use when the user wants to check current weather, temperature, forecasts, air quality, or get lifestyle advice like what to wear, whether to bring an umbrella, allergy risk, UV index, exercise suitability, or car wash timing. Also covers minute-level rain predictions, weather alerts, historical weather, traffic restrictions, tides, and sunrise/sunset. Use this skill whenever the user mentions weather, temperature, forecast, AQI, PM2.5, rain, snow, wind, humidity, sunrise, sunset, tides, traffic restrictions, historical weather, weather alerts, or any question about outdoor conditions, even if they don't explicitly say "weather" or "天气".
homepage: https://www.moji.com
metadata:
  openclaw:
    emoji: "🌦️"
    requires:
      bins: []
      env: []
    optional_env: ["MOJI_WEATHER_SNSID_KEY"]
---

# 墨迹天气 Equity Gateway Skill

12 种天气数据查询，零外部依赖。

## 执行模板

```bash
moji-use-weather <command> <位置>
```

位置参数: 城市名(`北京`/`beijing`) 或 经纬度(`39.9,116.4`)。shortterm 强烈建议用经纬度。

## 意图 → 命令 决策树

收到用户请求后，按以下决策树选择命令：

```
用户意图
├─ 现在天气/多少度/实况 → now
├─ 穿什么/带伞/感冒/洗车/运动/任何生活建议 → index（不是 now）
├─ 空气质量/AQI/PM2.5/雾霾 → aqi
├─ 会不会下雨？
│   ├─ 未来2小时内 → shortterm（建议用经纬度）
│   ├─ 今天剩余时间 → hourly
│   └─ 明天及之后 → forecast
├─ 逐小时天气 → hourly
├─ 明天/未来几天/一周/40天预报 → forecast
├─ 去年/历史天气 → history <位置> <YYYYMMDD|YYYYMM>
├─ 天气预警/暴雨/寒潮/台风 → alert
├─ 限行/限号 → restrict
├─ 潮汐 → tide
├─ 天气提醒文案 → remind
├─ 城市信息/经纬度 → city
└─ 复合意图（出行规划/通勤/运动等）→ 组合多命令，见 [usage-patterns.md](examples/usage-patterns.md)
```

## 错误处理

- `NO_API_KEY` → 引导用户执行 `moji-use-weather trial`（免费试用）或 `moji-use-weather login`（注册）。详见 [setup.md](references/setup.md)
- 试用模式仅支持 `now` 和 `forecast`，其他接口需注册账号
- 其他错误 → 见 [troubleshooting.md](references/troubleshooting.md)

## 输出规则（必须遵守）

不要返回原始 JSON。每次回复必须包含：

1. **一句话总结** — 直接回答用户问题
2. **关键数据** — 温度、天气、风力等核心数值
3. **行动建议** — 穿什么/带什么/注意什么

> 示例：北京现在 28°C 多云，体感 30°C，比较热。建议穿短袖薄裤，外出注意防晒（紫外线中等）。空气质量良，适合户外活动。

需要精确解读温度体感、AQI等级、风力影响、紫外线等级时，参考 [interpretation.md](references/interpretation.md)。

## 按需参考文档

仅在需要字段详情或高级用法时加载：

| 场景 | 文档 |
|------|------|
| now/hourly 字段详情 | [api-realtime.md](references/api-realtime.md) |
| forecast/history 字段详情 | [api-forecast.md](references/api-forecast.md) |
| index/aqi/alert 字段详情 | [api-life.md](references/api-life.md) |
| shortterm/tide/restrict/remind/city | [api-special.md](references/api-special.md) |
| 温度/AQI/风力/紫外线 解读表 | [interpretation.md](references/interpretation.md) |
| 安装与认证 | [setup.md](references/setup.md) |
| 错误码与排查 | [troubleshooting.md](references/troubleshooting.md) |
| 复合查询组合模式 | [usage-patterns.md](examples/usage-patterns.md) |

## 快速参考

```bash
moji-use-weather now 北京              # 实况天气
moji-use-weather forecast 上海         # 多日预报
moji-use-weather index 成都            # 生活指数（穿衣/伞/感冒等15种）
moji-use-weather aqi 广州              # 空气质量
moji-use-weather shortterm 39.9,116.4  # 短时降水（建议用坐标）
moji-use-weather hourly 北京           # 逐小时预报
moji-use-weather history 北京 20250214 # 历史天气
moji-use-weather alert 深圳            # 天气预警
moji-use-weather restrict 北京         # 限行查询
moji-use-weather tide 青岛             # 潮汐
moji-use-weather trial                 # 匿名免费试用
moji-use-weather device-id             # 设备标识
```
