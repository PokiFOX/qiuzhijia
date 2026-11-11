import 'package:device_preview/device_preview.dart';

String urlheader = "https://qiuzhijia-cdn.xipuseeker.cn/";
DeviceInfo deviceinfo = Devices.ios.iPhone16;

String backendHost = 'qiuzhijia.xipuseeker.cn';
//String backendHost = 'localhost';
int backendPort = 22006;

/// 网关只转发 `/api/*` 时设为 `"/api"`；直连 FastAPI（根路径即接口）时设为 `""`
String backendPathPrefix = '';
