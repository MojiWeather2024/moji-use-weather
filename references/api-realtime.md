# 实况与逐时接口

## now - 实况天气

实时天气数据，包含温度、体感温度、湿度、风向风力、天气现象等。

```bash
moji-use-weather now <位置>
```

**示例**:
```bash
moji-use-weather now 北京
moji-use-weather now 39.9042,116.4074
```

**返回字段**:
- `temperature` - 当前温度 (°C)
- `realFeel` - 体感温度 (°C)
- `humidity` - 相对湿度 (%)
- `weather` - 天气现象 (晴/多云/阴/雨等)
- `windDirection` - 风向
- `windLevel` - 风力等级
- `pressure` - 气压 (hPa)
- `visibility` - 能见度 (km)
- `uvi` - 紫外线指数
- `sunRise` / `sunSet` - 日出/日落时间

**匿名试用**: 支持

## hourly - 逐小时预报

未来 24/36 小时逐小时天气预报。

```bash
moji-use-weather hourly <位置>
```

**示例**:
```bash
moji-use-weather hourly 北京
```

**返回字段** (每小时):
- `hour` - 时间
- `temperature` - 温度 (°C)
- `weather` - 天气现象
- `windDirection` / `windLevel` - 风向风力
- `humidity` - 湿度
- `pop` - 降水概率 (%)

**匿名试用**: 不支持，需注册账号
