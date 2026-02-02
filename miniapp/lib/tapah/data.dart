import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart';

Dio dio = Dio();
GlobalKey<NavigatorState>? globalkey = GlobalKey();

GlobalKey keyMPHome = GlobalKey();
GlobalKey keyMPEntprise = GlobalKey();
GlobalKey keyMPOffer = GlobalKey();
GlobalKey keyMPService = GlobalKey();
GlobalKey keyMPProfile = GlobalKey();

GlobalKey keyDTBrief = GlobalKey();
GlobalKey keyDTSector = GlobalKey();
GlobalKey keyDTInfo = GlobalKey();
GlobalKey keyDTOffer = GlobalKey();
GlobalKey keyDTExample = GlobalKey();

List<Zone> zonelist = [];
List<Sector> sectorlist = [];
List<Level> levellist = [];
List<Field> fieldlist = [];
List<Enterprise> enterpriselist = [];
