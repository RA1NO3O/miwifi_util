# MiWifi Util
此工具旨在对 [小米路由器](https://www.mi.com/miwifi/) 的一些常用操作提供命令行工具支持。

## 需求开发环境

* [Dart SDK](https://dart.dev/get-dart)

## 项目目录说明

* 库代码: `lib/`
* 单元测试: `test/`
* 可执行文件: `build/`

## 编译指令

```shell
dart compile exe bin/miwifi_util.dart -o build/miwifi_util
```
Windows平台下请添加`.exe`扩展名.
> PS: 可能需要先创建build目录。