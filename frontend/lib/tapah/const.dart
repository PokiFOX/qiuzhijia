import 'package:dio/dio.dart';

String url_query_zonelist = "query_zonelist";
String url_query_levellist = "query_levellist";
String url_query_sectorlist = "query_sectorlist";
String url_query_fieldlist = "query_fieldlist";
String url_query_enterprise = "query_enterprise";
String url_add_zone = "set_zone";
String url_edit_zone = "edit_zone";
String url_delete_zone = "delete_zone";
String url_add_level = "set_level";
String url_edit_level = "edit_level";
String url_delete_level = "delete_level";
String url_add_sector = "set_sector";
String url_edit_sector = "edit_sector";
String url_delete_sector = "delete_sector";

var options = Options(
	contentType: "application/json",
);
