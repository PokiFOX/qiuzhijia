// ignore_for_file: non_constant_identifier_names

import 'package:frontend/tapah/const.dart';
import 'package:frontend/tapah/class.dart';
import 'package:frontend/tapah/data.dart';
import 'package:frontend/tapah/function.dart';

Future<void> RequestZoneList() async {
	var response = await dio.get(parseurl(url_query_zonelist));
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
	var json = response.data["data"]["zonelist"];
	zonelist = [];
	json.forEach((key, item) {
		zonelist.add(Zone(id: int.parse(key), value: item));
	});
}

Future<void> RequestSectorList() async {
	var response = await dio.get(parseurl(url_query_sectorlist));
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
	var json = response.data["data"]["sectorlist"];
	sectorlist = [];
	json.forEach((key, item) {
		sectorlist.add(Sector(id: int.parse(key), value: item));
	});
}

Future<void> RequestLevelList() async {
	var response = await dio.get(parseurl(url_query_levellist));
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
	var json = response.data["data"]["levellist"];
	levellist = [];
	json.forEach((key, item) {
		levellist.add(Level(id: int.parse(key), value: item));
	});
}

Future<void> RequestFieldList() async {
	var response = await dio.get(parseurl(url_query_fieldlist));
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
	var json = response.data["data"]["fieldlist"];
	fieldlist = [];
	json.forEach((item) {
		fieldlist.add(Field(id: item["id"], value: item["name"], sector: item["sector"], star: item["star"], content: item["content"]));
	});
}

Future<void> RequestEnterpriseList() async {
	var response = await dio.post(parseurl(url_query_enterprise), data: {
		"zone": 0,
		"sector": 0,
		"levels": [],
	}, options: options,);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
	var json = response.data["data"]["enterpriselist"];
	enterpriselist = [];
	json.forEach((item) {
		Enterprise enterprise = Enterprise(id: item["id"]);
		enterprise.zone = zonelist.firstWhere((e) => e.id == item["zone"]);
		enterprise.city = item["city"];
		enterprise.name = item["name"];
		enterprise.shortname = item["shortname"];
		enterprise.brief = item["brief"];
		enterprise.upper = item["upper"];
		enterprise.sector = sectorlist.firstWhere((e) => e.id == item["sector"], orElse: () => Sector(id: 0, value: ""));
		enterprise.level = levellist.firstWhere((e) => e.id == item["level"], orElse: () => Level(id: 0, value: ""));
		item["field"].forEach((field) {
			enterprise.fields.add(fieldlist.firstWhere((e) => e.id == field, orElse: () => Field(id: 0, value: "", sector: "", star: 0, content: "")));
		});
		enterprise.tags = item["tag"].split(',');
		enterprise.website1 = item["website1"];
		enterprise.website2 = item["website2"];
		enterpriselist.add(enterprise);
	});
}

Future<void> RequestAddZone(String value) async {
	var zone = []; zone.add(value);
	var response = await dio.post(
		parseurl(url_add_zone),
		data: zone,
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestEditZone(Zone zone) async {
	var response = await dio.post(
		parseurl(url_edit_zone), data: {
			"id": zone.id,
			"zone": zone.value,
		},
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestDeleteZone(int id) async {
	var response = await dio.post(parseurl(url_delete_zone), data: {
		"id": id,
	}, options: options,);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestAddSector(String value) async {
	var response = await dio.post(
		parseurl(url_add_sector),
		data: [value],
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestEditSector(Sector sector) async {
	var response = await dio.post(
		parseurl(url_edit_sector), data: {
			"id": sector.id,
			"sector": sector.value,
		},
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestDeleteSector(int id) async {
	var response = await dio.post(
		parseurl(url_delete_sector), data: {
			"id": id,
		},
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestAddLevel(String value) async {
	var response = await dio.post(
		parseurl(url_add_level),
		data: [value],
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestEditLevel(Level level) async {
	var response = await dio.post(
		parseurl(url_edit_level), data: {
			"id": level.id,
			"level": level.value,
		},
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestDeleteLevel(int id) async {
	var response = await dio.post(
		parseurl(url_delete_level), data: {
			"id": id,
		},
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestAddField(String value, String sector, int star, String content) async {
	var response = await dio.post(
		parseurl(url_add_field),
		data: [{
			"name": value,
			"sector": sector,
			"star": star,
			"content": content,
		}],
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestEditField(Field field) async {
	var response = await dio.post(
		parseurl(url_edit_field),
		data: {
			"id": field.id,
			"field": field.value,
			"sector": field.sector,
			"star": field.star,
			"content": field.content,
		},
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestDeleteField(int id) async {
	var response = await dio.post(
		parseurl(url_delete_field),
		data: {
			"id": id,
		},
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestAddEnterprise(Enterprise enterprise) async {
	var response = await dio.post(
		parseurl(url_add_enterprise),
		data: {
			"name": enterprise.name,
			"shortname": enterprise.shortname,
			"zone": zonelist.firstWhere((z) => z.id == enterprise.zone?.id).value,
			"city": enterprise.city,
			"brief": enterprise.brief,
			"upper": enterprise.upper,
			"sector": sectorlist.firstWhere((s) => s.id == enterprise.sector?.id).value,
			"level": levellist.firstWhere((l) => l.id == enterprise.level?.id).value,
			"field": enterprise.fields.map((e) => e.value).join('；'),
			"tag": enterprise.tags.join(','),
			"website1": enterprise.website1,
			"website2": enterprise.website2,
		},
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestEditEnterprise(Enterprise enterprise) async {
	var response = await dio.post(
		parseurl(url_edit_enterprise),
		data: {
			"id": enterprise.id,
			"name": enterprise.name,
			"shortname": enterprise.shortname,
			"zone": zonelist.firstWhere((z) => z.id == enterprise.zone?.id).value,
			"city": enterprise.city,
			"brief": enterprise.brief,
			"upper": enterprise.upper,
			"sector": sectorlist.firstWhere((s) => s.id == enterprise.sector?.id).value,
			"level": levellist.firstWhere((l) => l.id == enterprise.level?.id).value,
			"field": enterprise.fields.map((e) => e.value).join('；'),
			"tag": enterprise.tags.join(','),
			"website1": enterprise.website1,
			"website2": enterprise.website2,
		},
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
}

Future<void> RequestDeleteEnterprise(int id) async {
	var response = await dio.post(
		parseurl(url_delete_enterprise),
		data: {
			"id": id,
		},
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}
