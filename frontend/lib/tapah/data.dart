import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/class.dart';

Dio dio = Dio();
GlobalKey<NavigatorState>? globalkey = GlobalKey();

GlobalKey keyHome = GlobalKey();
GlobalKey keyEnterprise = GlobalKey();
GlobalKey keyOffer = GlobalKey();
GlobalKey keyService = GlobalKey();
GlobalKey keyProfile = GlobalKey();

List<Zone> zonelist = [];
List<Sector> sectorlist = [];
List<Level> levellist = [];
List<Field> fieldlist = [];
List<Enterprise> enterpriselist = [];
