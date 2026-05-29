import 'package:dio/dio.dart';

import 'package:qiuzhijia/tapah/class.dart';

Dio dio = Dio();

List<Zone> zonelist = [];
List<Sector> sectorlist = [];
List<Level> levellist = [];
List<Field> fieldlist = [];
List<Field> myfieldlist = [];
List<Enterprise> enterpriselist = [];
List<Case> caselist = [];
List<Article> article1 = [], article2 = [];

AccountInfo? accountinfo;
