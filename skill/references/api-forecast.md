# 预报与历史接口

## forecast - 多日预报

支持 7/15/40 天天气预报。

```bash
moji-use-weather forecast <位置>
```

**示例**:
```bash
moji-use-weather forecast 上海
moji-use-weather forecast 深圳
```

**返回字段** (每天):
- `date` - 日期
- `tempHigh` / `tempLow` - 最高/最低温度 (°C)
- `weatherDay` / `weatherNight` - 白天/夜间天气
- `windDirectionDay` / `windLevelDay` - 白天风向风力
- `humidity` - 湿度
- `pop` - 降水概率 (%)
- `sunRise` / `sunSet` - 日出/日落
- `moonPhase` - 月相

**匿名试用**: 支持

## history - 历史天气

查询指定日期或整月的历史天气数据。

```bash
# 指定日期
moji-use-weather history <位置> <YYYYMMDD>

# 整月数据
moji-use-weather history <位置> <YYYYMM>
```

**示例**:
```bash
moji-use-weather history 北京 20250214
moji-use-weather history 上海 202501
```

**返回字段**:
- `date` - 日期
- `tempHigh` / `tempLow` - 最高/最低温度
- `weather` - 天气现象
- `windDirection` / `windLevel` - 风向风力
- `humidity` - 湿度
- `precipitation` - 降水量 (mm)

**匿名试用**: 不支持
