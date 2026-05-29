import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import 'package:qiuzhijia/tapah/class.dart';

Dio dio = Dio();

GlobalKey<NavigatorState>? globalkey = GlobalKey();

GlobalKey keyMPHome = GlobalKey();
GlobalKey keyMPEntprise = GlobalKey();
GlobalKey keyMPOffer = GlobalKey();
GlobalKey keyMPService = GlobalKey();
GlobalKey keyMPProfile = GlobalKey();

GlobalKey keyDTBrief = GlobalKey();
GlobalKey keyDTField = GlobalKey();
GlobalKey keyDTInfo = GlobalKey();
GlobalKey keyDTOffer = GlobalKey();
GlobalKey keyDTExample = GlobalKey();

List<Zone> zonelist = [];
List<Sector> sectorlist = [];
List<Level> levellist = [];
List<Field> fieldlist = [];
List<Field> myfieldlist = [];
List<Enterprise> enterpriselist = [];
List<Case> caselist = [];
List<Article> article1 = [], article2 = [];

AccountInfo? accountinfo;
