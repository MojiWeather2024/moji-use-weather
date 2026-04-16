# 特殊接口

## shortterm - 短时降水

未来 2 小时分钟级降水预报。**建议使用经纬度坐标**以获得更精确结果。

```bash
moji-use-weather shortterm <经纬度>
moji-use-weather shortterm <城市名>
```

**示例**:
```bash
moji-use-weather shortterm 39.9042,116.4074
moji-use-weather shortterm 北京
```

**返回字段**:
- `summary` - 降水摘要文案
- `minutely[]` - 分钟级降水数据
  - `time` - 时间
  - `precipitation` - 降水量 (mm)
  - `type` - 降水类型 (rain/snow/none)

**匿名试用**: 不支持

## tide - 潮汐

沿海城市潮汐数据。

```bash
moji-use-weather tide <位置>
```

**示例**:
```bash
moji-use-weather tide 青岛
moji-use-weather tide 三亚
```

**返回字段**:
- `tideData[]` - 潮汐列表
  - `time` - 时间
  - `height` - 潮高 (cm)
  - `type` - 高潮/低潮

**匿名试用**: 不支持

## restrict - 限行查询

查询城市机动车限行信息。

```bash
moji-use-weather restrict <位置>
```

**示例**:
```bash
moji-use-weather restrict 北京
```

**返回字段**:
- `isRestrict` - 是否限行
- `restrictNumbers` - 限行尾号
- `restrictArea` - 限行区域
- `restrictTime` - 限行时间段

**匿名试用**: 不支持

## remind - 天气提醒

生成天气提醒文案。

```bash
moji-use-weather remind <位置>
```

**示例**:
```bash
moji-use-weather remind 北京
```

**匿名试用**: 不支持

## city - 城市信息

查询城市基本信息（经纬度、行政区划等）。

```bash
moji-use-weather city <位置>
```

**示例**:
```bash
moji-use-weather city 北京
```

**匿名试用**: 不支持
