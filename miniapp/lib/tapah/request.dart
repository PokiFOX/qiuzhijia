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

Future<int> RequestEnterpriseList(int zone, int sector, int level, int enttype, int field, bool? financial, String name, int page) async {
	var response = await dio.post(parseurl(url_query_enterprise), data: {
		"zone": zone,
		"sector": sector,
		"level": level,
		"enttype": enttype,
		"field": field,
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
		enterprise.tags = [];
		item["tag"].split(',').forEach((tag) {
			if (tag.trim().isEmpty) return;
			enterprise.tags.add(tag);
		});
		enterprise.website1 = item["website1"];
		enterprise.website2 = item["website2"];
		enterprise.icon = item["icon"];
		var images = item["images"].split(',');
		for (var image in images) {
			if (image.trim().isEmpty) continue;
			enterprise.images.add(image.trim());
		}
		if (item["enttype"] != '国企') enterprise.enttype = 1;
		if (item["enttype"] == '央企') enterprise.enttype = 2;
		enterprise.financial = item["financial"] == "是";
		for (var article in item["article1"]) {
			enterprise.article1.add(Article(article[0], article[1]));
		}
		for (var article in item["article2"]) {
			enterprise.article2.add(Article(article[0], article[1]));
		}
		enterpriselist.add(enterprise);
	});
	return json.length;
}

Future<List<Enterprise>> RequestEnterprise(int zone, int sector, int level, int enttype, int field, bool? financial, String name, int page) async {
	var response = await dio.post(parseurl(url_query_enterprise), data: {
		"zone": zone,
		"sector": sector,
		"level": level,
		"enttype": enttype,
		"field": field,
		"financial": financial,
		"name": name,
		"page": page,
	});
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	var json = response.data["data"]["enterpriselist"];
	var list = <Enterprise>[];
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
		var images = item["images"].split(',');
		for (var image in images) {
			if (image.trim().isEmpty) continue;
			enterprise.images.add(image.trim());
		}
		if (item["enttype"] != '国企') enterprise.enttype = 1;
		if (item["enttype"] == '央企') enterprise.enttype = 2;
		enterprise.financial = item["financial"] == "是";
		for (var article in item["article1"]) {
			enterprise.article1.add(Article(article[0], article[1]));
		}
		for (var article in item["article2"]) {
			enterprise.article2.add(Article(article[0], article[1]));
		}
		list.add(enterprise);
	});
	return list;
}

Future<Enterprise> RequestEnterpriseDetail(int id) async {
	var response = await dio.post(parseurl(url_query_enterprise_detail), data: {"id": id});
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	var item = response.data["data"]["enterprise"];
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
	var images = item["images"].split(',');
	for (var image in images) {
		if (image.trim().isEmpty) continue;
		enterprise.images.add(image.trim());
	}
	if (item["enttype"] != '国企') enterprise.enttype = 1;
	if (item["enttype"] == '央企') enterprise.enttype = 2;
	enterprise.financial = item["financial"] == "是";
	for (var article in item["article1"]) {
		enterprise.article1.add(Article(article[0], article[1]));
	}
	for (var article in item["article2"]) {
		enterprise.article2.add(Article(article[0], article[1]));
	}
	return enterprise;
}

Future<int> RequestArticle1() async {
	var response = await dio.get(parseurl(url_query_article1));
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	article1.clear();
	var json = response.data["data"]["link"];
	json.forEach((item) {
		article1.add(new Article(item[0], item[1]));
	});
	article1.sort((a, b) => b.update.compareTo(a.update));
	return json.length;
}

Future<int> RequestArticle2() async {
	var response = await dio.get(parseurl(url_query_article2));
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	article2.clear();
	var json = response.data["data"]["link"];
	json.forEach((item) {
		article2.add(new Article(item[0], item[1]));
	});
	return json.length;
}

Future<int> RequestCaseList(int enterprise, int level, int sector, int field, int stag1, int stag2, int year, int page) async {
	var response = await dio.post(parseurl(url_query_case), data: {
		"enterprise": enterprise,
		"level": level,
		"sector": sector,
		"field": field,
		"stag1": stag1,
		"stag2": stag2,
		"year": year,
		"page": page,
	});
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	var json = response.data["data"]["caselist"];
	json.forEach((item) {
		Case c = Case(id: item["id"], name: item["name"]);
		c.entid = item["entid"];
		c.enticon = item["enticon"];
		c.entname = item["entname"];
		c.field = fieldlist.firstWhere((e) => e.id == item["field"]);
		c.tags = List<String>.from(item["tags"]);
		c.student = item["student"];
		c.school1 = item["school1"]; c.stag1 = item["stag1"]; c.field1 = item["field1"];
		c.school2 = item["school2"]; c.stag2 = item["stag2"]; c.field2 = item["field2"];
		c.year = item["year"];
		c.detail = item["detail"];
		c.dep = item["dep"];
		caselist.add(c);
	});
	return json.length;
}

Future<List<Case>> RequestCase(int enterprise, int level, int sector, int field, int stag1, int stag2, int year, int page) async {
	var response = await dio.post(parseurl(url_query_case), data: {
		"enterprise": enterprise,
		"level": level,
		"sector": sector,
		"field": field,
		"stag1": stag1,
		"stag2": stag2,
		"year": year,
		"page": page,
	});
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	var json = response.data["data"]["caselist"];
	var list = <Case>[];
	json.forEach((item) {
		Case c = Case(id: item["id"], name: item["name"]);
		c.entid = item["entid"];
		c.enticon = item["enticon"];
		c.entname = item["entname"];
		c.field = fieldlist.firstWhere((e) => e.id == item["field"]);
		c.tags = List<String>.from(item["tags"]);
		c.student = item["student"];
		c.school1 = item["school1"]; c.stag1 = item["stag1"]; c.field1 = item["field1"];
		c.school2 = item["school2"]; c.stag2 = item["stag2"]; c.field2 = item["field2"];
		c.year = item["year"];
		c.detail = item["detail"];
		c.dep = item["dep"];
		list.add(c);
	});
	return list;
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

Future<void> RequestWxCode(String code) async {
	var response = await dio.post(parseurl(url_query_wxcode), data: {
		"code": code,
	});
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	var json = response.data["data"];
	accountinfo = AccountInfo();
	accountinfo!.id = json["id"];
	accountinfo!.openid = json["openid"];
	accountinfo!.nickname = json["nickname"] ?? "微信名称";
	if (accountinfo!.nickname.isEmpty) {
		accountinfo!.nickname = "微信名称";
	}
	accountinfo!.avatar = json["avatar"] ?? "";
	accountinfo!.field = Set<int>.from(json["field"] ?? []);
	accountinfo!.enterprise = Set<int>.from(json["enterprise"] ?? []);
}

Future<void> RequestUserInfo() async {
	if (accountinfo == null) {
		throw Exception('User not logged in');
	}
	await dio.post(parseurl(url_query_userinfo), data: {
		"openid": accountinfo!.openid,
		"avatar": accountinfo!.avatar,
		"nickname": accountinfo!.nickname,
		"field": accountinfo!.field.toList(),
		"enterprise": accountinfo!.enterprise.toList(),
	});
}

Future<void> RequestFavorite() async {
	if (accountinfo == null) {
		throw Exception('User not logged in');
	}
	var response = await dio.post(parseurl(url_query_favorite), data: {
		"enterprise": accountinfo!.enterprise.toList(),
		"field": accountinfo!.field.toList(),
	});
	if (response.data['code'] != 0) {
		throw Exception('Error code: ${response.data['code']} status: ${response.data['status']}');
	}
	var json1 = response.data["data"]["field"];
	json1.forEach((item) {
		myfieldlist.add(Field(id: item["id"], value: item["name"], mapping: List<String>.from(item["mapping"]), type: item["type"], star: item["star"], content: item["content"]));
	});
	var json2 = response.data["data"]["enterprise"];
	json2.forEach((item) {
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
		var images = item["images"].split(',');
		for (var image in images) {
			if (image.trim().isEmpty) continue;
			enterprise.images.add(image.trim());
		}
		if (item["enttype"] != '国企') enterprise.enttype = 1;
		if (item["enttype"] == '央企') enterprise.enttype = 2;
		enterprise.financial = item["financial"] == "是";
		for (var article in item["article1"]) {
			enterprise.article1.add(Article(article[0], article[1]));
		}
		for (var article in item["article2"]) {
			enterprise.article2.add(Article(article[0], article[1]));
		}
		myenterpriselist.add(enterprise);
	});
}

Future<void> RequestChatAIAuth() async {
	if (accountinfo == null) {
		throw Exception('User not logged in');
	}
	var response = await dio.post(parseurl(url_query_chatai_auth), data: {
		"openid": accountinfo!.openid,
		"unionid": accountinfo!.unionid,
		"nickname": accountinfo!.nickname,
		"avatar": accountinfo!.avatar,
		"phone": accountinfo!.openid,
		"email": accountinfo!.email,
		"realname": accountinfo!.realname,
		"useridentity": accountinfo!.useridentity,
		"usersource": accountinfo!.usersource,
		"miniappid": miniappid,
	});
	if (response.data['code'] != 0) {
		throw Exception(response.data['status'] ?? '鉴权失败');
	}
	var json = response.data['data'];
	chataiToken = json['token'];
	chataiTokenExpiresAt = json['expiresAt'];
}

Future<String> RequestChatAIChat(String message, {String? agent}) async {
	if (accountinfo == null) {
		throw Exception('User not logged in');
	}
	if (chataiToken == null || chataiToken!.isEmpty) {
		throw Exception('未鉴权');
	}
	final agentKey = agent ?? chataiAgent;
	var data = <String, dynamic>{
		"openid": accountinfo!.openid,
		"token": chataiToken,
		"message": message,
		"agent": agentKey,
	};
	if (chataiConversationId != null && chataiConversationId!.isNotEmpty) {
		data["conversationId"] = chataiConversationId;
	}
	var response = await dio.post(parseurl(url_query_chatai_chat), data: data);
	if (response.data['code'] != 0) {
		throw Exception(response.data['status'] ?? '对话失败');
	}
	var json = response.data['data'];
	chataiConversationId = json['conversationId'];
	chataiAgent = agentKey;
	return json['response'] ?? '';
}

class AIChatHistoryResult {
	final List<ChatItem> messages;
	final bool hasMore;
	AIChatHistoryResult({required this.messages, required this.hasMore});
}

Future<AIChatHistoryResult> RequestAIChatHistory({
	String? agent,
	int? before,
	int limit = 10,
}) async {
	if (accountinfo == null) {
		throw Exception('User not logged in');
	}
	final agentKey = agent ?? chataiAgent;
	final queryParameters = <String, dynamic>{
		"openid": accountinfo!.openid,
		"agent": agentKey,
		"limit": limit,
	};
	if (before != null) {
		queryParameters["before"] = before;
	}
	var response = await dio.get(parseurl(url_query_aichat_history), queryParameters: queryParameters);
	if (response.data['code'] != 0) {
		throw Exception(response.data['status'] ?? '加载聊天记录失败');
	}
	var json = response.data['data'];
	if (before == null) {
		chataiConversationId = json['conversationId'];
		chataiAgent = agentKey;
	}
	var list = <ChatItem>[];
	for (var item in json['messages'] ?? []) {
		list.add(ChatItem(
			isuser: item['isuser'] == true,
			detail: item['detail'] ?? '',
			timestamp: item['timestamp'] ?? 0,
		));
	}
	return AIChatHistoryResult(
		messages: list,
		hasMore: json['hasMore'] == true,
	);
}

Future<List<String>> RequestQuestions(String agent) async {
	var response = await dio.get(parseurl(url_query_questions), queryParameters: {
		"agent": agent,
	});
	if (response.data['code'] != 0) {
		throw Exception(response.data['status'] ?? '加载问题失败');
	}
	var list = <String>[];
	for (var item in response.data['data']['questions'] ?? []) {
		final question = item['question']?.toString() ?? '';
		if (question.isNotEmpty) list.add(question);
	}
	return list;
}
