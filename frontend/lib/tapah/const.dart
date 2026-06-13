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
String url_add_field = "set_field";
String url_edit_field = "edit_field";
String url_delete_field = "delete_field";
String url_query_questions = "query_questions";
String url_add_question = "set_question";
String url_edit_question = "edit_question";
String url_delete_question = "delete_question";
String url_add_enterprise = "insert_enterprise";
String url_edit_enterprise = "edit_enterprise";
String url_delete_enterprise = "delete_enterprise";
String url_import = "import_excel";

var options = Options(
	contentType: "application/json",
);

const Map<String, String> questionAgentLabels = {
	'resume': '简历助手',
	'joblevel': '岗位分析',
};

String questionAgentLabel(String key) => questionAgentLabels[key] ?? key;

String questionAgentKey(String label) {
	for (final entry in questionAgentLabels.entries) {
		if (entry.value == label) return entry.key;
	}
	return label;
}

List<String> get questionAgentLabelList => questionAgentLabels.values.toList();
