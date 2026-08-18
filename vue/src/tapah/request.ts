import {
	url_query_zonelist,
	url_query_levellist,
	url_query_sectorlist,
	url_query_fieldlist,
	url_query_enterprise,
	url_query_enterprise_detail,
	url_query_case,
	url_query_case_display,
	url_query_article1,
	url_query_article2,
	url_query_wxcode,
	url_query_userinfo,
	url_query_favorite,
	url_query_chatai_auth,
	url_query_chatai_chat,
	url_query_aichat_history,
	url_query_questions,
	miniappid,
} from "./const";
import {
	Zone,
	Sector,
	Level,
	Field,
	Enterprise,
	Case,
	Article,
	AccountInfo,
	ChatItem,
} from "./class";
import {
	zonelist,
	sectorlist,
	levellist,
	fieldlist,
	myfieldlist,
	enterpriselist,
	myenterpriselist,
	caselist,
	article1,
	article2,
	accountinfo,
	chataiToken,
	chataiTokenExpiresAt,
	chataiConversationId,
	chataiAgent,
} from "./data";
import { parseurl } from "./function";

function request<T = any>(options: {
	url: string;
	method?: "GET" | "POST";
	data?: any;
	header?: any;
}): Promise<{ code: number; status?: string; data: T }> {
	return new Promise((resolve, reject) => {
		uni.request({
			url: options.url,
			method: options.method || "GET",
			data: options.data,
			header: options.header,
			success: (res) => {
				if (res.statusCode === 200) {
					resolve(res.data as any);
				} else {
					reject(new Error(`HTTP Error: ${res.statusCode}`));
				}
			},
			fail: (err) => {
				reject(err);
			},
		});
	});
}

function _splitCsv(value: any): string[] {
	if (value === null || value === undefined) return [];
	if (Array.isArray(value)) {
		return value.map((e) => String(e).trim()).filter((e) => e.length > 0);
	}
	return String(value)
		.split(",")
		.map((e) => e.trim())
		.filter((e) => e.length > 0);
}

function parseEnterpriseItem(item: any): Enterprise {
	const enterprise = new Enterprise({ id: item.id });
	enterprise.zone = zonelist.value.find((e) => e.id === item.zone);
	enterprise.city = item.city;
	enterprise.name = item.name;
	enterprise.shortname = item.shortname;
	enterprise.englishname = item.englishname;
	enterprise.brief = item.brief;
	enterprise.upper = item.upper;
	enterprise.sector = sectorlist.value.find((e) => e.id === item.sector);
	enterprise.level = levellist.value.find((e) => e.id === item.level);

	if (Array.isArray(item.field)) {
		item.field.forEach((fId: any) => {
			const f = fieldlist.value.find((e) => e.id === fId);
			if (f) enterprise.fields.push(f);
		});
	}

	enterprise.tags = _splitCsv(item.tag);
	enterprise.website1 = item.website1;
	enterprise.website2 = item.website2;
	enterprise.icon = item.icon;
	enterprise.images = _splitCsv(item.images);

	if (item.enttype !== "国企") enterprise.enttype = 1;
	if (item.enttype === "央企") enterprise.enttype = 2;
	enterprise.financial = item.financial === "是";
	enterprise.growth = item.growth === "是";

	if (Array.isArray(item.article1)) {
		enterprise.article1 = item.article1.map((article: any) => Article.fromJson(article));
	}
	if (Array.isArray(item.article2)) {
		enterprise.article2 = item.article2.map((article: any) => Article.fromJson(article));
	}
	return enterprise;
}

export async function RequestZoneList(): Promise<void> {
	const response = await request<{ zonelist: Record<string, string> }>({
		url: parseurl(url_query_zonelist),
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code}`);
	}
	const json = response.data.zonelist;
	const list = [new Zone({ id: 0, value: "不限" })];
	Object.entries(json).forEach(([key, item]) => {
		list.push(new Zone({ id: parseInt(key, 10), value: item }));
	});
	zonelist.value = list;
}

export async function RequestSectorList(): Promise<void> {
	const response = await request<{ sectorlist: Record<string, string> }>({
		url: parseurl(url_query_sectorlist),
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}
	const json = response.data.sectorlist;
	const list = [new Sector({ id: 0, value: "不限" })];
	Object.entries(json).forEach(([key, item]) => {
		list.push(new Sector({ id: parseInt(key, 10), value: item }));
	});
	sectorlist.value = list;
}

export async function RequestLevelList(): Promise<void> {
	const response = await request<{ levellist: Record<string, string> }>({
		url: parseurl(url_query_levellist),
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}
	const json = response.data.levellist;
	const list = [new Level({ id: 0, value: "不限" })];
	Object.entries(json).forEach(([key, item]) => {
		list.push(new Level({ id: parseInt(key, 10), value: item }));
	});
	levellist.value = list;
}

export async function RequestFieldList(): Promise<void> {
	const response = await request<{ fieldlist: any[] }>({
		url: parseurl(url_query_fieldlist),
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}
	const json = response.data.fieldlist;
	const list: Field[] = [];
	json.forEach((item) => {
		list.push(
			new Field({
				id: item.id,
				value: item.name,
				mapping: Array.isArray(item.mapping) ? item.mapping.map(String) : [],
				type: item.type,
				star: item.star,
				content: item.content,
			})
		);
	});
	fieldlist.value = list;
}

export type FilterParam = number | number[];

export function serializeFilterParam(ids: number[]): FilterParam {
	if (ids.length === 0) return 0;
	if (ids.length === 1) return ids[0];
	return ids;
}

export async function RequestEnterpriseList(
	zone: FilterParam,
	sector: FilterParam,
	level: FilterParam,
	enttype: number,
	field: number,
	financial: boolean | null,
	growth: boolean | null,
	name: string,
	page: number
): Promise<[number, number]> {
	const response = await request<{ enterpriselist: any[]; pagesize: any }>({
		url: parseurl(url_query_enterprise),
		method: "POST",
		data: { zone, sector, level, enttype, field, financial, growth, name, page },
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}
	const data = response.data;
	const json = data.enterpriselist;
	const pagesize = typeof data.pagesize === "number" ? data.pagesize : parseInt(String(data.pagesize), 10) || 20;

	const list = [...enterpriselist.value];
	json.forEach((item) => {
		list.push(parseEnterpriseItem(item));
	});
	enterpriselist.value = list;

	return [json.length, pagesize];
}

export async function RequestEnterprise(
	zone: FilterParam,
	sector: FilterParam,
	level: FilterParam,
	enttype: number,
	field: number,
	financial: boolean | null,
	growth: boolean | null,
	name: string,
	page: number
): Promise<Enterprise[]> {
	const response = await request<{ enterpriselist: any[] }>({
		url: parseurl(url_query_enterprise),
		method: "POST",
		data: { zone, sector, level, enttype, field, financial, growth, name, page },
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}
	const json = response.data.enterpriselist;
	return json.map(parseEnterpriseItem);
}

export async function RequestEnterpriseDetail(id: number): Promise<Enterprise> {
	const response = await request<{ enterprise: any }>({
		url: parseurl(url_query_enterprise_detail),
		method: "POST",
		data: { id },
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}
	const item = response.data.enterprise;
	return parseEnterpriseItem(item);
}

export async function RequestArticle1(): Promise<number> {
	const response = await request<{ link: any[] }>({
		url: parseurl(url_query_article1),
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}
	const json = response.data.link;
	const list = json.map((item) => Article.fromJson(item));
	list.sort((a, b) => b.update - a.update);
	article1.value = list;
	return json.length;
}

export async function RequestArticle2(): Promise<number> {
	const response = await request<{ link: any[] }>({
		url: parseurl(url_query_article2),
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}
	const json = response.data.link;
	article2.value = json.map((item) => Article.fromJson(item));
	return json.length;
}

export async function RequestCaseList(
	enterprise: number,
	level: number,
	sector: number,
	field: number,
	stag1: number,
	stag2: number,
	year: number,
	page: number
): Promise<[number, number]> {
	const response = await request<{ caselist: any[]; pagesize: any }>({
		url: parseurl(url_query_case),
		method: "POST",
		data: { enterprise, level, sector, field, stag1, stag2, year, page },
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}
	const data = response.data;
	const json = data.caselist;
	const pagesize = typeof data.pagesize === "number" ? data.pagesize : parseInt(String(data.pagesize), 10) || 20;

	const list = [...caselist.value];
	json.forEach((item) => {
		const c = new Case({ id: item.id, name: item.name });
		c.entid = item.entid;
		c.enticon = item.enticon;
		c.entname = item.entname;
		c.field = fieldlist.value.find((e) => e.id === item.field);
		c.tags = Array.isArray(item.tags) ? item.tags.map(String) : [];
		c.student = item.student;
		c.school1 = item.school1;
		c.stag1 = item.stag1;
		c.field1 = item.field1;
		c.school2 = item.school2;
		c.stag2 = item.stag2;
		c.field2 = item.field2;
		c.year = item.year;
		c.detail = item.detail;
		c.dep = item.dep;
		list.push(c);
	});
	caselist.value = list;
	return [json.length, pagesize];
}

function parseCaseItem(item: any): Case {
	const c = new Case({ id: item.id, name: item.name });
	c.entid = item.entid;
	c.enticon = item.enticon;
	c.entname = item.entname;
	c.field = fieldlist.value.find((e) => e.id === item.field);
	c.tags = Array.isArray(item.tags) ? item.tags.map(String) : [];
	c.student = item.student;
	c.school1 = item.school1;
	c.stag1 = item.stag1;
	c.field1 = item.field1;
	c.school2 = item.school2;
	c.stag2 = item.stag2;
	c.field2 = item.field2;
	c.year = item.year;
	c.detail = item.detail;
	c.dep = item.dep;
	return c;
}

export interface CaseDisplayResult {
	primary: Case | null;
	similar: Case[];
	similarTotal: number;
	pageSize: number;
}

export async function RequestCaseDisplay(
	enterprise: number,
	level: number,
	sector: number,
	field: number,
	stag1: number,
	stag2: number,
	year: number,
	page: number,
	options?: { excludeId?: number; referenceId?: number },
): Promise<CaseDisplayResult> {
	const response = await request<{ primary: any; similarlist: any[]; similar_total: number; pagesize: number }>({
		url: parseurl(url_query_case_display),
		method: "POST",
		data: {
			enterprise,
			level,
			sector,
			field,
			stag1,
			stag2,
			year,
			page,
			exclude_id: options?.excludeId ?? 0,
			reference_id: options?.referenceId ?? 0,
		},
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}
	const data = response.data;
	const primary = data.primary ? parseCaseItem(data.primary) : null;
	const similar = (data.similarlist ?? []).map(parseCaseItem);
	return {
		primary,
		similar,
		similarTotal: data.similar_total ?? 0,
		pageSize: typeof data.pagesize === "number" ? data.pagesize : parseInt(String(data.pagesize), 10) || 20,
	};
}

export async function RequestCase(
	enterprise: number,
	level: number,
	sector: number,
	field: number,
	stag1: number,
	stag2: number,
	year: number,
	page: number
): Promise<Case[]> {
	const response = await request<{ caselist: any[] }>({
		url: parseurl(url_query_case),
		method: "POST",
		data: { enterprise, level, sector, field, stag1, stag2, year, page },
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}
	const json = response.data.caselist;
	return json.map(parseCaseItem);
}

export async function RequestWxCode(code: string): Promise<void> {
	const response = await request<any>({
		url: parseurl(url_query_wxcode),
		method: "POST",
		data: { code },
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}
	const json = response.data;
	const info = new AccountInfo();
	info.id = json.id;
	info.openid = json.openid;
	info.nickname = json.nickname || "微信名称";
	if (info.nickname.length === 0) {
		info.nickname = "微信名称";
	}
	info.avatar = json.avatar || "";
	info.field = new Set(Array.isArray(json.field) ? json.field.map(Number) : []);
	info.enterprise = new Set(Array.isArray(json.enterprise) ? json.enterprise.map(Number) : []);
	accountinfo.value = info;
}

export async function RequestUserInfo(): Promise<void> {
	if (!accountinfo.value) {
		throw new Error("User not logged in");
	}
	await request<void>({
		url: parseurl(url_query_userinfo),
		method: "POST",
		data: {
			openid: accountinfo.value.openid,
			avatar: accountinfo.value.avatar,
			nickname: accountinfo.value.nickname,
			field: Array.from(accountinfo.value.field),
			enterprise: Array.from(accountinfo.value.enterprise),
		},
	});
}

export async function RequestFavorite(): Promise<void> {
	if (!accountinfo.value) {
		throw new Error("User not logged in");
	}
	const response = await request<{ field: any[]; enterprise: any[] }>({
		url: parseurl(url_query_favorite),
		method: "POST",
		data: {
			enterprise: Array.from(accountinfo.value.enterprise),
			field: Array.from(accountinfo.value.field),
		},
	});
	if (response.code !== 0) {
		throw new Error(`Error code: ${response.code} status: ${response.status}`);
	}

	const json1 = response.data.field;
	const list1: Field[] = [];
	json1.forEach((item) => {
		list1.push(
			new Field({
				id: item.id,
				value: item.name,
				mapping: Array.isArray(item.mapping) ? item.mapping.map(String) : [],
				type: item.type,
				star: item.star,
				content: item.content,
			})
		);
	});
	myfieldlist.value = list1;

	const json2 = response.data.enterprise;
	const list2: Enterprise[] = json2.map(parseEnterpriseItem);
	myenterpriselist.value = list2;
}

export async function RequestChatAIAuth(): Promise<void> {
	if (!accountinfo.value) {
		throw new Error("User not logged in");
	}
	const response = await request<any>({
		url: parseurl(url_query_chatai_auth),
		method: "POST",
		data: {
			openid: accountinfo.value.openid,
			unionid: accountinfo.value.unionid,
			nickname: accountinfo.value.nickname,
			avatar: accountinfo.value.avatar,
			phone: accountinfo.value.openid,
			email: accountinfo.value.email,
			realname: accountinfo.value.realname,
			useridentity: accountinfo.value.useridentity,
			usersource: accountinfo.value.usersource,
			miniappid: miniappid,
		},
	});
	if (response.code !== 0) {
		throw new Error(response.status || "鉴权失败");
	}
	const json = response.data;
	chataiToken.value = json.token;
	chataiTokenExpiresAt.value = json.expiresAt;
}

export async function RequestChatAIChat(message: string, agent?: string): Promise<string> {
	if (!accountinfo.value) {
		throw new Error("User not logged in");
	}
	if (!chataiToken.value) {
		throw new Error("未鉴权");
	}
	const agentKey = agent || chataiAgent.value;
	const data: Record<string, any> = {
		openid: accountinfo.value.openid,
		token: chataiToken.value,
		message: message,
		agent: agentKey,
	};
	if (chataiConversationId.value) {
		data.conversationId = chataiConversationId.value;
	}
	const response = await request<any>({
		url: parseurl(url_query_chatai_chat),
		method: "POST",
		data: data,
	});
	if (response.code !== 0) {
		throw new Error(response.status || "对话失败");
	}
	const json = response.data;
	chataiConversationId.value = json.conversationId;
	chataiAgent.value = agentKey;
	return json.response || "";
}

export class AIChatHistoryResult {
	messages: ChatItem[];
	hasMore: boolean;
	constructor({ messages, hasMore }: { messages: ChatItem[]; hasMore: boolean }) {
		this.messages = messages;
		this.hasMore = hasMore;
	}
}

export async function RequestAIChatHistory({
	agent,
	before,
	limit = 10,
}: {
	agent?: string;
	before?: number;
	limit?: number;
}): Promise<AIChatHistoryResult> {
	if (!accountinfo.value) {
		throw new Error("User not logged in");
	}
	const agentKey = agent || chataiAgent.value;
	const queryParameters: Record<string, any> = {
		openid: accountinfo.value.openid,
		agent: agentKey,
		limit: limit,
	};
	if (before !== undefined) {
		queryParameters.before = before;
	}

	const queryString = Object.entries(queryParameters)
		.map(([key, val]) => `${encodeURIComponent(key)}=${encodeURIComponent(String(val))}`)
		.join("&");
	const url = `${parseurl(url_query_aichat_history)}?${queryString}`;

	const response = await request<any>({ url });
	if (response.code !== 0) {
		throw new Error(response.status || "加载聊天记录失败");
	}
	const json = response.data;
	if (before === undefined) {
		chataiConversationId.value = json.conversationId;
		chataiAgent.value = agentKey;
	}
	const list: ChatItem[] = [];
	for (const item of json.messages || []) {
		list.push(
			new ChatItem({
				isuser: item.isuser === true,
				detail: item.detail || "",
				timestamp: item.timestamp || 0,
			})
		);
	}
	return new AIChatHistoryResult({
		messages: list,
		hasMore: json.hasMore === true,
	});
}

export async function RequestQuestions(agent: string): Promise<string[]> {
	const url = `${parseurl(url_query_questions)}?agent=${encodeURIComponent(agent)}`;
	const response = await request<any>({ url });
	if (response.code !== 0) {
		throw new Error(response.status || "加载问题失败");
	}
	const list: string[] = [];
	for (const item of response.data.questions || []) {
		const question = item.question?.toString() || "";
		if (question) list.push(question);
	}
	return list;
}
