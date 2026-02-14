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

Future<void> RequestEnterpriseList(int zone, int sector, List<int> levels) async {
	var response = await dio.post(parseurl(url_query_enterprise), data: {
		"zone": zone,
		"sector": sector,
		"levels": levels,
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

Future<void> RequestEditZone(int id, String value) async {
	var response = await dio.post(
		parseurl(url_edit_zone), data: {
			"id": id,
			"zone": value,
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

Future<void> RequestEditSector(int id, String value) async {
	var response = await dio.post(
		parseurl(url_edit_sector), data: {
			"id": id,
			"sector": value,
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

Future<void> RequestEditLevel(int id, String value) async {
	var response = await dio.post(
		parseurl(url_edit_level), data: {
			"id": id,
			"level": value,
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

Future<void> RequestEditField(int id, String value, String sector, int star, String content) async {
	var response = await dio.post(
		parseurl(url_edit_field),
		data: {
			"id": id,
			"field": value,
			"sector": sector,
			"star": star,
			"content": content,
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
