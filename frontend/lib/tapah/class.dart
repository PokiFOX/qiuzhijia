import 'package:flutter/material.dart';

import 'package:qiuzhijia/tapah/enum.dart';

class EventInfo {
	SceneID sceneid = SceneID.none;
	late Key key;
	Map<EventType, Function> list = {};
	EventInfo(this.sceneid, this.key);
	void add(EventType event, Function function) {
		list[event] = function;
	}
	void del(EventType event) {
		list.remove(event);
	}
}

class EventManager {
	static final EventManager _singleten = EventManager._internal();

	Map<SceneID, EventInfo> eventmap = {};
	EventManager._internal();
	factory EventManager() {
		return _singleten;
	}
	void init(SceneID sceneid, Key key) {
		if (eventmap.containsKey(sceneid)) return;
		eventmap[sceneid] = EventInfo(sceneid, key);
	}
	void uninit(SceneID sceneid) {
		eventmap.remove(sceneid);
	}
	void add(SceneID sceneid, EventType event, Function function) {
		if (eventmap.containsKey(sceneid) == false) return;
		eventmap[sceneid]!.add(event, function);
	}
	void del(SceneID sceneid, {EventType event = EventType.none} ) {
		if (eventmap.containsKey(sceneid) == false) return;
		if (event == EventType.none) {
			eventmap.remove(sceneid);
		}
		else {
			eventmap[sceneid]!.del(event);
		}
	}
	void call(SceneID sceneid, EventType event, [List<dynamic>? param]) {
		if (sceneid == SceneID.none) {
			for (var scene in eventmap.values) {
				if (scene.list.containsKey(event)) {
					Function.apply(scene.list[event]!, param);
				}
			}
		}
		else {
			if (eventmap.containsKey(sceneid) == false) return;
			if (eventmap[sceneid]!.list.containsKey(event) == false) return;
			Function.apply(eventmap[sceneid]!.list[event]!, param);
		}
	}
}

mixin class Callback {
	SceneID sceneid = SceneID.none;
	void initCallback (SceneID sceneid, Key key) {
		this.sceneid = sceneid;
		EventManager().init(sceneid, key);
	}
	void uninitCallback() {
		EventManager().uninit(sceneid);
	}
	void addCallback(EventType event, Function function) {
		EventManager().add(sceneid, event, function);
	}
	void delCallback({EventType event = EventType.none} ) {
		EventManager().del(sceneid, event: event);
	}
	void callback(SceneID sceneid, EventType event, [List<dynamic>? param]) {
		EventManager().call(sceneid, event, param);
	}
}

class Zone {
	int id;
	String value;
	Zone({required this.id, required this.value});
}

class Level {
	int id;
	String value;
	Level({required this.id, required this.value});
}

class Sector {
	int id;
	String value;
	Sector({required this.id, required this.value});
}

class Field {
	int id;
	String value;
	Field({required this.id, required this.value});
}

class Enterprise {
	int id;
	Zone? zone;
	String? city;
	String? name;
	String? brief;
	String? upper;
	Sector? sector;
	Level? level;
	List<String> tags = [];
	List<Field> fields = [];
	String? website1, website2;

	Enterprise({required this.id});
}
