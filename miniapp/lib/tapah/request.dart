import 'package:qiuzhijia/tapah/const.dart';
import 'package:qiuzhijia/tapah/class.dart';
import 'package:qiuzhijia/tapah/data.dart';
import 'package:qiuzhijia/tapah/function.dart';

Future<void> RequestZoneList() async {
	var response = await dio.get(parseurl(url_query_zonelist));
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
	var json = response.data["data"]["zonelist"];
	zonelist = [Zone(id: 0, value: "不限")];
	json.forEach((key, item) {
		zonelist.add(Zone(id: int.parse(key), value: item));
	});
}

Future<void> RequestSectorList() async {
	var response = await dio.get(parseurl(url_query_sectorlist));
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	var json = response.data["data"]["sectorlist"];
	sectorlist = [Sector(id: 0, value: "不限")];
	json.forEach((key, item) {
		sectorlist.add(Sector(id: int.parse(key), value: item));
	});
}

Future<void> RequestLevelList() async {
	var response = await dio.get(parseurl(url_query_levellist));
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	var json = response.data["data"]["levellist"];
	levellist = [Level(id: 0, value: "不限")];
	json.forEach((key, item) {
		levellist.add(Level(id: int.parse(key), value: item));
	});
}

Future<void> RequestFieldList() async {
	var response = await dio.get(parseurl(url_query_fieldlist));
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	var json = response.data["data"]["fieldlist"];
	fieldlist = [];
	json.forEach((item) {
		fieldlist.add(Field(id: item["id"], value: item["name"], mapping: List<String>.from(item["mapping"]), type: item["type"], star: item["star"], content: item["content"]));
	});
}

Future<int> RequestEnterpriseList(int zone, int sector, int level, int enttype, bool? financial, String name, int page) async {
	var response = await dio.post(parseurl(url_query_enterprise), data: {
		"zone": zone,
		"sector": sector,
		"level": level,
		"enttype": enttype,
		"financial": financial,
		"name": name,
		"page": page,
	});
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	var json = response.data["data"]["enterpriselist"];
	json.forEach((item) {
		Enterprise enterprise = Enterprise(id: item["id"]);
		enterprise.zone = zonelist.firstWhere((e) => e.id == item["zone"]);
		enterprise.city = item["city"];
		enterprise.name = item["name"];
		enterprise.brief = item["brief"];
		enterprise.upper = item["upper"];
		enterprise.sector = sectorlist.firstWhere((e) => e.id == item["sector"]);
		enterprise.level = levellist.firstWhere((e) => e.id == item["level"]);
		item["field"].forEach((field) {
			enterprise.fields.add(fieldlist.firstWhere((e) => e.id == field));
		});
		enterprise.tags = item["tag"].split(',');
		enterprise.website1 = item["website1"];
		enterprise.website2 = item["website2"];
		enterprise.icon = item["icon"];
		enterprise.images = item["images"].split(',');
		if (item["enttype"] != '国企') enterprise.enttype = 1;
		if (item["enttype"] == '央企') enterprise.enttype = 2;
		enterprise.financial = item["financial"] == "是";
		enterprise.article1 = item["article1"].split('\n');
		enterprise.article2 = item["article2"].split('\n');
		enterpriselist.add(enterprise);
	});
	return json.length;
}

Future<int> RequestCaseList(int enterprise, int page) async {
	var response = await dio.post(parseurl(url_query_case), data: {
		"enterprise": enterprise,
		"page": page,
	});
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	var json = response.data["data"]["caselist"];
	json.forEach((item) {
		Case c = Case(id: item["id"], name: item["name"]);
		c.enticon = item["enticon"];
		c.entname = item["entname"];
		c.field = fieldlist.firstWhere((e) => e.id == item["field"]);
		c.tags = List<String>.from(item["tags"]);
		c.student = item["student"];
		c.school1 = item["school1"]; c.field1 = item["field1"];
		c.school2 = item["school2"]; c.field2 = item["field2"];
		c.detail = item["detail"];
		caselist.add(c);
	});
	return json.length;
}

Future<ArticleMeta> RequestArticleMeta(String url) async {
	var response = await dio.post(parseurl(url_query_article_meta), data: {
		"url": url,
	});
	if (response.data['code'] != 0) {
		return ArticleMeta(url: url);
	}
	var d = response.data["data"];
	return ArticleMeta(
		url: url,
		title: d["title"] ?? "",
		description: d["description"] ?? "",
		image: d["image"] ?? "",
	);
}
