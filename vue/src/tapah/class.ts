import type { InternshipExperience } from "./caseExperience";
import { SceneID, EventType } from "./enum";

export class EventInfo {
	sceneid: SceneID;
	key?: any;
	list: Map<EventType, Function> = new Map();

	constructor(sceneid: SceneID, key?: any) {
		this.sceneid = sceneid;
		this.key = key;
	}

	add(event: EventType, func: Function) {
		this.list.set(event, func);
	}

	del(event: EventType) {
		this.list.delete(event);
	}
}

class EventManagerClass {
	private static _instance: EventManagerClass;
	public eventmap: Map<SceneID, EventInfo> = new Map();

	private constructor() {}

	public static getInstance(): EventManagerClass {
		if (!EventManagerClass._instance) {
			EventManagerClass._instance = new EventManagerClass();
		}
		return EventManagerClass._instance;
	}

	init(sceneid: SceneID, key?: any) {
		if (this.eventmap.has(sceneid)) return;
		this.eventmap.set(sceneid, new EventInfo(sceneid, key));
	}

	uninit(sceneid: SceneID) {
		this.eventmap.delete(sceneid);
	}

	add(sceneid: SceneID, event: EventType, func: Function) {
		const info = this.eventmap.get(sceneid);
		if (!info) return;
		info.add(event, func);
	}

	del(sceneid: SceneID, event: EventType = EventType.none) {
		if (!this.eventmap.has(sceneid)) return;
		if (event === EventType.none) {
			this.eventmap.delete(sceneid);
		} else {
			this.eventmap.get(sceneid)!.del(event);
		}
	}

	call(sceneid: SceneID, event: EventType, param?: any[]) {
		if (sceneid === SceneID.none) {
			for (const scene of this.eventmap.values()) {
				if (scene.list.has(event)) {
					const func = scene.list.get(event);
					if (func) {
						func(...(param || []));
					}
				}
			}
		} else {
			const info = this.eventmap.get(sceneid);
			if (!info) return;
			if (!info.list.has(event)) return;
			const func = info.list.get(event);
			if (func) {
				func(param);
			}
		}
	}
}

export function EventManager() {
	return EventManagerClass.getInstance();
}

export class Callback {
	sceneid: SceneID = SceneID.none;

	initCallback(sceneid: SceneID, key?: any) {
		this.sceneid = sceneid;
		EventManager().init(sceneid, key);
	}

	uninitCallback() {
		EventManager().uninit(this.sceneid);
	}

	addCallback(event: EventType, func: Function) {
		EventManager().add(this.sceneid, event, func);
	}

	delCallback(event: EventType = EventType.none) {
		EventManager().del(this.sceneid, event);
	}

	callback(sceneid: SceneID, event: EventType, param?: any[]) {
		EventManager().call(sceneid, event, param);
	}
}

export class Zone {
	id: number;
	value: string;
	constructor({ id, value }: { id: number; value: string }) {
		this.id = id;
		this.value = value;
	}
}

export class Level {
	id: number;
	value: string;
	constructor({ id, value }: { id: number; value: string }) {
		this.id = id;
		this.value = value;
	}
}

export class Sector {
	id: number;
	value: string;
	constructor({ id, value }: { id: number; value: string }) {
		this.id = id;
		this.value = value;
	}
}

export class Field {
	id: number;
	value: string;
	mapping: string[];
	type: string;
	star: number;
	content: string;
	constructor({
		id,
		value,
		mapping,
		type,
		star,
		content,
	}: {
		id: number;
		value: string;
		mapping: string[];
		type: string;
		star: number;
		content: string;
	}) {
		this.id = id;
		this.value = value;
		this.mapping = mapping;
		this.type = type;
		this.star = star;
		this.content = content;
	}
}

export class Article {
	article: string;
	update: number;
	title: string;
	description: string;
	accountName: string;
	accountIcon: string;
	publishTime: number;

	constructor({
		article,
		update,
		title = "",
		description = "",
		accountName = "",
		accountIcon = "",
		publishTime = 0,
	}: {
		article: string;
		update: number;
		title?: string;
		description?: string;
		accountName?: string;
		accountIcon?: string;
		publishTime?: number;
	}) {
		this.article = article;
		this.update = update;
		this.title = title;
		this.description = description;
		this.accountName = accountName;
		this.accountIcon = accountIcon;
		this.publishTime = publishTime;
	}

	static fromJson(json: any): Article {
		if (Array.isArray(json)) {
			return new Article({
				article: json.length > 0 ? String(json[0]) : "",
				update: json.length > 1
					? (typeof json[1] === "number" ? json[1] : parseInt(String(json[1]), 10) || 0)
					: 0,
			});
		}
		const map = (json && typeof json === "object") ? json : {};
		return new Article({
			article: String(map.article ?? ""),
			update: typeof map.update === "number" ? map.update : parseInt(String(map.update ?? ""), 10) || 0,
			title: String(map.title ?? ""),
			description: String(map.description ?? ""),
			accountName: String(map.accountName ?? ""),
			accountIcon: String(map.accountIcon ?? ""),
			publishTime: typeof map.publishTime === "number"
				? map.publishTime
				: parseInt(String(map.publishTime ?? ""), 10) || 0,
		});
	}
}

export class Enterprise {
	id: number;
	zone?: Zone;
	city?: string;
	name?: string;
	shortname?: string;
	englishname?: string;
	brief?: string;
	upper?: string;
	sector?: Sector;
	level?: Level;
	tags: string[] = [];
	fields: Field[] = [];
	website1?: string;
	website2?: string;
	icon?: string;
	images: string[] = [];
	enttype: number = 0;
	financial: boolean = false;
	growth: boolean = false;
	article1: Article[] = [];
	article2: Article[] = [];

	constructor({ id }: { id: number }) {
		this.id = id;
	}
}

export class Case {
	id: number;
	name: string;
	dep?: string;
	entid?: number;
	enticon?: string;
	entname?: string;
	field?: Field;
	tags: string[] = [];
	student?: string;
	school1?: string;
	field1?: string;
	school2?: string;
	field2?: string;
	stag1?: number;
	stag2?: number;
	year?: number;
	detail?: string;
	experiences?: InternshipExperience[];

	constructor({ id, name }: { id: number; name: string }) {
		this.id = id;
		this.name = name;
	}
}

export class AccountInfo {
	id: number = 0;
	openid: string = "";
	nickname: string = "微信名称";
	avatar: string = "";
	email: string = "";
	phone: string = "";
	realname: string = "";
	unionid: string = "";
	useridentity: string = "学生";
	usersource: string = "求职+";
	field: Set<number> = new Set();
	enterprise: Set<number> = new Set();
}

export class ChatItem {
	isuser: boolean;
	detail: string;
	timestamp: number;

	constructor({
		isuser,
		detail,
		timestamp,
	}: {
		isuser: boolean;
		detail: string;
		timestamp: number;
	}) {
		this.isuser = isuser;
		this.detail = detail;
		this.timestamp = timestamp;
	}
}
