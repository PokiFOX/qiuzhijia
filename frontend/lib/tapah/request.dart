// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:frontend/tapah/const.dart';
import 'package:frontend/tapah/class.dart';
import 'package:frontend/tapah/data.dart';
import 'package:frontend/tapah/function.dart';

List<Article> mergeArticlesFromCell(List<Article> existing, String cellValue) {
	final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
	final urls = cellValue.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
	final merged = <Article>[];
	for (final url in urls) {
		Article? old;
		for (final item in existing) {
			if (item.article == url) {
				old = item;
				break;
			}
		}
		merged.add(old ?? Article(article: url, update: now));
	}
	return merged;
}

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
		fieldlist.add(Field(
			id: item["id"],
			value: item["name"],
			type: item["type"],
			star: item["star"],
			content: item["content"],
			mapping: List<String>.from((item["mapping"] as List?)?.map((e) => e.toString()) ?? [])
				.map((e) => e.trim())
				.where((e) => e.isNotEmpty)
				.toList(),
		));
	});
}

Future<void> RequestEnterpriseList(int page) async {
	var response = await dio.post(parseurl(url_query_enterprise), data: {
		"zone": 0,
		"sector": 0,
		"level": 0,
		"enttype": 0,
		"financial": null,
		"field": 0,
		"name": "",
		"page": page,
	}, options: options,);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
	var json = response.data["data"]["enterpriselist"];
	if (page == 1) enterpriselist = [];
	json.forEach((item) {
		Enterprise enterprise = Enterprise(id: item["id"]);
		enterprise.zone = zonelist.firstWhere((e) => e.id == item["zone"]);
		enterprise.city = item["city"];
		enterprise.name = item["name"];
		enterprise.shortname = item["shortname"];
		enterprise.englishname = item["englishname"];
		enterprise.brief = item["brief"];
		enterprise.upper = item["upper"];
		enterprise.sector = sectorlist.firstWhere((e) => e.id == item["sector"], orElse: () => Sector(id: 0, value: ""));
		enterprise.level = levellist.firstWhere((e) => e.id == item["level"], orElse: () => Level(id: 0, value: ""));
		item["field"].forEach((field) {
			enterprise.fields.add(fieldlist.firstWhere((e) => e.id == field, orElse: () => Field(id: 0, value: "", type: "", star: 0, content: "", mapping: [])));
		});
		enterprise.tags = item["tag"].split(',');
		enterprise.website1 = item["website1"];
		enterprise.website2 = item["website2"];
		enterprise.icon = item["icon"];
		(item["images"] as String).split(',').forEach((image) {
			if (image.isNotEmpty) enterprise.images.add(image);
		});
		if (item["enttype"] ==  '国有企业') enterprise.enttype = 1;
		if (item["enttype"] == '中央企业') enterprise.enttype = 2;
		if (item["financial"] == '是') enterprise.financial = true;
		if (item["financial"] == '否') enterprise.financial = false;
		for (int i = 0;i < item['article1'].length;i++) {
			var article = item['article1'][i];
			var url = (article is Map ? article["article"] : article[0])?.toString() ?? "";
			var update = article is Map ? article["update"] : article[1];
			if (url.isNotEmpty) enterprise.article1.add(Article(article: url, update: update is int ? update : int.tryParse("$update") ?? 0));
		}
		for (int i = 0;i < item['article2'].length;i++) {
			var article = item['article2'][i];
			var url = (article is Map ? article["article"] : article[0])?.toString() ?? "";
			var update = article is Map ? article["update"] : article[1];
			if (url.isNotEmpty) enterprise.article2.add(Article(article: url, update: update is int ? update : int.tryParse("$update") ?? 0));
		}
		enterprise.mapping = item["mapping"];
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
			"type": field.type,
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

Future<void> RequestQuestionListAll() async {
	questionlist = [];
	for (final agent in ['resume', 'joblevel']) {
		var response = await dio.get(parseurl(url_query_questions), queryParameters: {
			"agent": agent,
		});
		if (response.data['code'] != 0) {
			throw Exception('Error code: ${response.data['code']}');
		}
		var json = response.data["data"]["questions"];
		json.forEach((item) {
			questionlist.add(Question(
				id: item["id"],
				agent: item["agent"],
				question: item["question"],
			));
		});
	}
}

Future<void> RequestAddQuestion(String agent, String question) async {
	var response = await dio.post(
		parseurl(url_add_question),
		data: [{
			"agent": agent,
			"question": question,
		}],
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestEditQuestion(Question question) async {
	var response = await dio.post(
		parseurl(url_edit_question),
		data: {
			"id": question.id,
			"agent": question.agent,
			"question": question.question,
		},
		options: options,
	);
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']}');
	}
}

Future<void> RequestDeleteQuestion(int id) async {
	var response = await dio.post(
		parseurl(url_delete_question),
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
			"englishname": enterprise.englishname,
			"zone": zonelist.firstWhere((z) => z.id == enterprise.zone?.id).value,
			"city": enterprise.city,
			"brief": enterprise.brief,
			"upper": enterprise.upper,
			"sector": sectorlist.firstWhere((s) => s.id == enterprise.sector?.id).value,
			"level": levellist.firstWhere((l) => l.id == enterprise.level?.id).value,
			"field": enterprise.mapping ?? "",
			"tag": enterprise.tags.join(','),
			"website1": enterprise.website1,
			"website2": enterprise.website2,
			"icon": enterprise.icon,
			"images": enterprise.images.join(','),
			"enttype": enterprise.enttype,
			"financial": enterprise.financial,
			"article1": enterprise.article1.map((e) => [e.article, e.update]).toList(),
			"article2": enterprise.article2.map((e) => [e.article, e.update]).toList(),
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
			"englishname": enterprise.englishname,
			"zone": zonelist.firstWhere((z) => z.id == enterprise.zone?.id).value,
			"city": enterprise.city,
			"brief": enterprise.brief,
			"upper": enterprise.upper,
			"sector": sectorlist.firstWhere((s) => s.id == enterprise.sector?.id).value,
			"level": levellist.firstWhere((l) => l.id == enterprise.level?.id).value,
			"field": enterprise.mapping ?? "",
			"tag": enterprise.tags.join(','),
			"website1": enterprise.website1,
			"website2": enterprise.website2,
			"icon": enterprise.icon,
			"images": enterprise.images.join(','),
			"enttype": enterprise.enttype,
			"financial": enterprise.financial,
			"article1": enterprise.article1.map((e) => e.article).toList(),
			"article2": enterprise.article2.map((e) => e.article).toList(),
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

Future<dynamic> RequestImport(String filename, Uint8List? filedata) async {
	var response = await dio.post(
		parseurl(url_import),
		data: {
			"filename": filename,
			"filedata": String.fromCharCodes(filedata ?? []),
		},
		options: options,
	);
	return response;
}