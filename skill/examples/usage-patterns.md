# 组合使用模式

天气查询经常需要组合多个接口来回答用户的复合问题。以下是常见的组合模式。

## 出行规划

**场景**: "周末去三亚玩需要准备什么"

**组合接口**: forecast + aqi + index + tide（沿海城市）

```bash
moji-use-weather forecast 三亚        # 未来天气
moji-use-weather aqi 三亚             # 空气质量
moji-use-weather index 三亚           # 穿衣/防晒/旅游等指数
moji-use-weather tide 三亚            # 潮汐（海边活动）
```

**解读要点**: 综合温度、降水概率、AQI、紫外线给出打包建议。

## 穿衣建议

**场景**: "今天穿什么"

**组合接口**: now + index

```bash
moji-use-weather now 北京             # 当前温度
moji-use-weather index 北京           # 穿衣指数
```

**解读要点**: 以穿衣指数为主，now 温度做补充说明。

## 降水判断

**场景**: "今天会不会下雨"

**时间判断**:
- 未来 2 小时内 → `shortterm`（分钟级精确）
- 今天后续 → `hourly`（逐小时降水概率）
- 明天及之后 → `forecast`（每日降水概率）

```bash
# 近 2 小时
moji-use-weather shortterm 39.9042,116.4074

# 今天逐小时
moji-use-weather hourly 北京

# 明天及之后
moji-use-weather forecast 北京
```

## 运动/户外活动

**场景**: "今天适合跑步/打球吗"

**组合接口**: now + aqi + index

```bash
moji-use-weather now 北京             # 温度、风力
moji-use-weather aqi 北京             # 空气质量
moji-use-weather index 北京           # 运动指数
```

**判断条件**: AQI > 150 不建议户外，风力 > 5 级不建议，温度 > 35°C 不建议。

## 天气对比

**场景**: "去年这时候多少度"

**组合接口**: now + history

```bash
moji-use-weather now 北京
moji-use-weather history 北京 20250413   # 去年同日
```

## 通勤建议

**场景**: "今天开车上班要注意什么"

**组合接口**: now + restrict + alert + aqi

```bash
moji-use-weather restrict 北京        # 限行尾号
moji-use-weather now 北京             # 当前天气
moji-use-weather alert 北京           # 预警
moji-use-weather aqi 北京             # 能见度相关
```
