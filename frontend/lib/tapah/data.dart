import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:frontend/tapah/class.dart';

Dio dio = Dio();
GlobalKey<NavigatorState>? globalkey = GlobalKey();

List<Zone> zonelist = [];
List<Sector> sectorlist = [];
List<Level> levellist = [];
List<Field> fieldlist = [];
List<Enterprise> enterpriselist = [];
