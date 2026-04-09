import asyncio
import datetime
import re
from contextlib import asynccontextmanager
import shutil
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import faulthandler
import httpx

from tapah import data
from tapah import function
from tapah.struct import Linq, Zone, Level, Sector, Field, Enterprise, Case

@asynccontextmanager
async def lifespan(app: FastAPI):
	function.init_config()
	faulthandler.enable()
	yield

app = FastAPI(lifespan = lifespan)
app.add_middleware(
	CORSMiddleware,
	allow_origins = ["*"],
	allow_credentials = True,
	allow_methods = ["*"],
	allow_headers = ["*"],
)

@app.get("/")
async def entry():
	return {"message": "求职家后台."}

@app.get("/query_zonelist")
async def query_zonelist(req: Request):
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
		"data": {
			"zonelist": {zone.id: zone.name for zone in data.zonelist},
		},
	})

@app.get("/query_levellist")
async def query_levellist(req: Request):
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
		"data": {
			"levellist": {level.id: level.name for level in data.levellist},
		},
	})

@app.get("/query_sectorlist")
async def query_sectorlist(req: Request):
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
		"data": {
			"sectorlist": {sector.id: sector.name for sector in data.sectorlist},
		},
	})

@app.get("/query_fieldlist")
async def query_fieldlist(req: Request):
	fieldlist = []
	for field in data.fieldlist:
		fieldlist.append({
			"id": field.id,
			"name": field.name,
			"mapping": field.mapping,
			"type": field.type,
			"star": field.star,
			"content": field.content,
		})
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
		"data": {
			"fieldlist": fieldlist,
		},
	})

@app.post("/query_enterprise")
async def query_enterprise(req: Request):
	json = await req.json()
	zone_id = json.get("zone")
	level_id = json.get("level")
	sector_id = json.get("sector")
	enttype = json.get("enttype")
	financial = json.get("financial")
	enterprise_name = json.get("name", "").strip()
	page = json.get("page", 1)

	if Linq(data.zonelist).find(lambda z: z.id == zone_id) is None and zone_id != 0:
		return JSONResponse(content = {
			"code": 1,
			"status": "zone_not_found",
		})

	if Linq(data.levellist).find(lambda l: l.id == level_id) is None and level_id != 0:
		return JSONResponse(content = {
			"code": 1,
			"status": "level_not_found",
		})

	if Linq(data.sectorlist).find(lambda s: s.id == sector_id) is None and sector_id != 0:
		return JSONResponse(content = {
			"code": 1,
			"status": "sector_not_found",
		})

	enterpriselist = []
	count = 0
	for i in range(len(data.enterpriselist)):
		enterprise = data.enterpriselist[i]
		if zone_id != 0 and enterprise.zone != zone_id: continue
		if sector_id != 0 and enterprise.sector != sector_id: continue
		if level_id != 0 and enterprise.level != level_id: continue
		if enttype == 1 and enterprise.enttype != '国企': continue
		if enttype == 2 and enterprise.enttype != '央企': continue
		if financial == True and enterprise.financial != '是': continue
		if financial == False and enterprise.financial != '否': continue
		if enterprise_name and enterprise_name not in enterprise.name: continue
		count += 1
		if page > 0 and count <= (page - 1) * 20: continue
		if page > 0 and count > page * 20: break
		enterpriselist.append({
			"id": enterprise.id,
			"zone": enterprise.zone,
			"city": enterprise.city,
			"name": enterprise.name,
			"brief": enterprise.brief,
			"upper": enterprise.upper,
			"level": enterprise.level,
			"sector": enterprise.sector,
			"field": enterprise.field,
			"tag": enterprise.tag,
			"website1": enterprise.website1,
			"website2": enterprise.website2,
			"shortname": enterprise.shortname,
			"icon": enterprise.icon,
			"images": enterprise.images,
			"enttype": enterprise.enttype,
			"financial": enterprise.financial,
			"article1": enterprise.article1,
			"article2": enterprise.article2,

		})

	return JSONResponse(content = {
		"code": 0,
		"status": "success",
		"data": {
			"enterpriselist": enterpriselist,
		},
	})

@app.post("/query_case")
async def query_case(req: Request):
	json = await req.json()
	enterprise_id = json.get("enterprise")
	zone = json.get("zone")
	sector = json.get("sector")
	stag = json.get("stag")
	year = json.get("year")
	page = json.get("page", 1)
	caselist = []
	enterprise = Linq(data.enterpriselist).find(lambda e: e.id == enterprise_id, None)
	if enterprise_id != 0 and enterprise is None:
		return JSONResponse(content = {
			"code": 1,
			"status": "enterprise_not_found",
		})

	count = 0
	for case in data.caselist:
		ent = Linq(data.enterpriselist).find(lambda e: e.id == case.enterprise)
		if ent is None: continue
		if zone != 0 and ent.zone != zone: continue
		if sector != 0 and ent.sector != sector: continue
		if enterprise_id != 0 and enterprise != None and enterprise.id != case.id and case.field not in enterprise.field: continue
		if stag != 0 and case.stag1 != stag and case.stag2 != stag: continue
		if year == 1 and case.year != 2026: continue
		if year == 2 and case.year == 2026: continue
		count += 1
		if page > 0 and count <= (page - 1) * 20: continue
		if page > 0 and count > page * 20: break
		caselist.append({
			"id": case.id,
			"name": case.name,
			"enterprise": case.enterprise,
			"enticon": ent.icon,
			"entname": ent.name,
			"field": case.field,
			"tags": case.tags,
			"student": case.student,
			"school1": case.school1,
			"stag1": case.stag1,
			"field1": case.field1,
			"school2": case.school2,
			"stag2": case.stag2,
			"field2": case.field2,
			"year": case.year,
			"detail": case.detail,
		})
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
		"data": {
			"caselist": caselist,
		},
	})

@app.post("/query_article_meta")
async def query_article_meta(req: Request):
	json = await req.json()
	url = json.get("url", "")
	if not url:
		return JSONResponse(content = {"code": 1, "status": "url_required"})
	try:
		async with httpx.AsyncClient(follow_redirects=True, timeout=10.0) as client:
			resp = await client.get(url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"})
			html = resp.text
		title = ""
		description = ""
		image = ""
		m = re.search(r'<meta\s+property=["\']og:title["\']\s+content=["\'](.*?)["\']', html)
		if m: title = m.group(1)
		if not title:
			m = re.search(r'<title>(.*?)</title>', html)
			if m: title = m.group(1)
		m = re.search(r'<meta\s+property=["\']og:description["\']\s+content=["\'](.*?)["\']', html)
		if m: description = m.group(1)
		if not description:
			m = re.search(r'<meta\s+name=["\']description["\']\s+content=["\'](.*?)["\']', html)
			if m: description = m.group(1)
		m = re.search(r'<meta\s+property=["\']og:image["\']\s+content=["\'](.*?)["\']', html)
		if m: image = m.group(1)
		if not image:
			m = re.search(r'var\s+msg_cdn_url\s*=\s*["\'](.*?)["\']', html)
			if m: image = m.group(1)
		return JSONResponse(content = {
			"code": 0,
			"status": "success",
			"data": {
				"title": title,
				"description": description,
				"image": image,
			},
		})
	except Exception as e:
		return JSONResponse(content = {"code": 1, "status": str(e)})

@app.post("/insert_enterprise")
async def insert_enterprise(req: Request):
	json = await req.json()
	zone = json.get("zone")
	city = json.get("city")
	name = json.get("name")
	shortname = json.get("shortname")
	brief = json.get("brief")
	upper = json.get("upper")
	sector = json.get("sector")
	level = json.get("level")
	field = json.get("field")
	tag = json.get("tag")
	website1 = json.get("website1")
	website2 = json.get("website2")
	icon = json.get("icon")
	images = json.get("images")
	enttype = json.get("enttype")
	financial = json.get("financial")
	article1 = json.get("article1")
	article2 = json.get("article2")

	enterprise = Linq(data.enterpriselist).find(lambda e: e.name == name)
	if enterprise is not None:
		return JSONResponse(content = {"status": "enterprise exists"})

	zone_item = Linq(data.zonelist).find(lambda z: z.name == zone, None)
	if zone_item is None:
		return JSONResponse(content = {"status": f"zone_not_found: {zone}"})

	level_item = Linq(data.levellist).find(lambda l: l.name == level, None)
	if level_item is None:
		return JSONResponse(content = {"status": f"level_not_found: {level}"})

	sector_item = Linq(data.sectorlist).find(lambda s: s.name == sector, None)
	if sector_item is None:
		return JSONResponse(content = {"status": f"sector_not_found: {sector}"})

	fieldlist = []
	for f in field.split(','):
		if f.strip() == "": continue
		field_item = Linq(data.fieldlist).find(lambda fld: f.strip() in fld.mapping, None)
		if field_item is None:
			return JSONResponse(content = {"status": f"field_not_found: {f}"})
		if field_item.id not in fieldlist: fieldlist.append(field_item.id)

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute(
		"INSERT INTO qzj_enterprise (zone, city, name, shortname, brief, upper, level, sector, tag, website1, website2, icon, images, enttype, financial, article1, article2) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
		(zone_item.id, city, name, shortname, brief, upper, level_item.id, sector_item.id, tag, website1, website2, icon, images, enttype, financial, article1, article2)
	)
	enterprise_id = cursor.lastrowid
	enterprise = Enterprise(enterprise_id, zone_item.id, city, name, shortname, brief, upper, sector_item.id, level_item.id, website1, website2, tag.split(','), icon, images, enttype, financial, article1, article2)
	for fid in fieldlist:
		cursor.execute(
			"INSERT IGNORE INTO qzj_enterprise_field (enterprise_id, field) VALUES (%s, %s)",
			(enterprise_id, fid)
		)
		enterprise.addfield(fid)
	data.enterpriselist.append(enterprise)

	cursor.close()
	data.mysql_pool.release(conn)

	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/insert_case")
async def insert_case(req: Request):
	json = await req.json()
	name = json.get("name")
	enterprise = json.get("enterprise")
	field = json.get("field")
	tags = json.get("tags")
	student = json.get("student")
	school1 = json.get("school1")
	tag = json.get("school1_tag")
	stag1 = 0
	if tag == '985': stag1 = 1
	if tag == '211': stag1 = 2
	if tag == '普通': stag1 = 3
	if tag == '海外': stag1 = 4
	field1 = json.get("field1")
	school2 = json.get("school2")
	tag = json.get("school2_tag")
	stag2 = 0
	if tag == '985': stag2 = 1
	if tag == '211': stag2 = 2
	if tag == '普通': stag2 = 3
	if tag == '海外': stag2 = 4
	field2 = json.get("field2")
	year = json.get("year")
	detail = json.get("detail")

	einfo = Linq(data.enterpriselist).find(lambda e: e.name == enterprise)
	if einfo is None:
		return JSONResponse(content = {"status": "enterprise_not_found"})

	finfo = Linq(data.fieldlist).find(lambda f: f.name == field)
	if finfo is None:
		return JSONResponse(content = {"status": "field_not_found"})

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute(
		"INSERT INTO qzj_case (name, enterprise, field, tags, student, school1, stag1, field1, school2, stag2, field2, year, detail) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
		(name, einfo.id, finfo.id, tags, student, school1, stag1, field1, school2, stag2, field2, year, detail)
	)
	case_id = cursor.lastrowid
	data.caselist.append(Case(case_id, name, einfo.id, finfo.id, tags, student, school1, stag1, field1, school2, stag2, field2, year, detail))

	cursor.close()
	data.mysql_pool.release(conn)

	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/set_zone")
async def set_zone(req: Request):
	json = await req.json()
	zone_list = json

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	for zone in zone_list:
		if Linq(data.zonelist).find(lambda z: z.name == zone) is not None: continue
		cursor.execute("INSERT IGNORE INTO qzj_zone (zone) VALUES (%s)", (zone,))
		last_id = cursor.lastrowid
		if last_id != 0: data.zonelist.append(Zone(last_id, zone))

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/set_level")
async def set_level(req: Request):
	json = await req.json()
	level_list = json

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	for level in level_list:
		if Linq(data.levellist).find(lambda l: l.name == level, None) is not None: continue
		cursor.execute("INSERT IGNORE INTO qzj_level (level) VALUES (%s)", (level,))
		last_id = cursor.lastrowid
		if last_id != 0: data.levellist.append(Level(last_id, level))

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/set_sector")
async def set_sector(req: Request):
	json = await req.json()
	sector_list = json

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	for sector in sector_list:
		if Linq(data.sectorlist).find(lambda s: s.name == sector, None) is not None: continue
		cursor.execute("INSERT IGNORE INTO qzj_sector (sector) VALUES (%s)", (sector,))
		last_id = cursor.lastrowid
		if last_id != 0: data.sectorlist.append(Sector(last_id, sector))

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/set_field")
async def set_field(req: Request):
	json = await req.json()
	field_list = json

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	for field in field_list:
		if field['name'].strip() == "": continue
		if Linq(data.fieldlist).find(lambda fld: field['name'].strip() in fld.mapping, None) is not None: continue
		cursor.execute("INSERT IGNORE INTO qzj_field (field, mapping, type, star, content) VALUES (%s,%s,%s,%s,%s)", (field['name'], ','.join(field['mapname']), field['type'], field['star'], field['content']))
		last_id = cursor.lastrowid
		if last_id != 0: data.fieldlist.append(Field(last_id, field['name'], field['mapname'], field['type'], field['star'], field['content']))

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/edit_zone")
async def edit_zone(req: Request):
	json = await req.json()
	id = json.get("id")
	zone = json.get("zone")

	zone_item = Linq(data.zonelist).find(lambda z: z.id == id, None)
	if zone_item is None: return JSONResponse(content = {"status": "not exists"})

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("UPDATE qzj_zone SET zone=%s WHERE id=%s", (zone, id))
	zone_item.name = zone

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/delete_zone")
async def delete_zone(req: Request):
	json = await req.json()
	id = json.get("id")

	zone_item = Linq(data.zonelist).find(lambda z: z.id == id, None)
	if zone_item is None: return JSONResponse(content = {"status": "not exists"})

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("DELETE FROM qzj_zone WHERE id=%s", (id,))
	data.zonelist.remove(zone_item)

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/edit_level")
async def edit_level(req: Request):
	json = await req.json()
	id = json.get("id")
	level = json.get("level")

	level_item = Linq(data.levellist).find(lambda l: l.id == id, None)
	if level_item is None: return JSONResponse(content = {"status": "not exists"})

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("UPDATE qzj_level SET level=%s WHERE id=%s", (level, id))
	level_item.name = level

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/delete_level")
async def delete_level(req: Request):
	json = await req.json()
	id = json.get("id")

	level_item = Linq(data.levellist).find(lambda l: l.id == id, None)
	if level_item is None: return JSONResponse(content = {"status": "not exists"})


	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("DELETE FROM qzj_level WHERE id=%s", (id,))
	data.levellist.remove(level_item)

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/edit_sector")
async def edit_sector(req: Request):
	json = await req.json()
	id = json.get("id")
	sector = json.get("sector")

	sector_item = Linq(data.sectorlist).find(lambda s: s.id == id, None)
	if sector_item is None: return JSONResponse(content = {"status": "not exists"})

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("UPDATE qzj_sector SET sector=%s WHERE id=%s", (sector, id))
	sector_item.name = sector

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/delete_sector")
async def delete_sector(req: Request):
	json = await req.json()
	id = json.get("id")

	sector_item = Linq(data.sectorlist).find(lambda s: s.id == id, None)
	if sector_item is None: return JSONResponse(content = {"status": "not exists"})

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("DELETE FROM qzj_sector WHERE id=%s", (id,))
	data.sectorlist.remove(sector_item)

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/edit_field")
async def edit_field(req: Request):
	json = await req.json()
	id = json.get("id")
	field = json.get("field")
	mapping = json.get("mapping")
	type = json.get("type")
	star = json.get("star")
	content = json.get("content")

	field_item = Linq(data.fieldlist).find(lambda f: f.id == id, None)
	if field_item is None: return JSONResponse(content = {"status": "not exists"})

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("UPDATE qzj_field SET field=%s, mapping=%s, type=%s, star=%s, content=%s WHERE id=%s", (field, ','.join(mapping), type, star, content, id))
	field_item.name = field
	field_item.mapname = mapping
	field_item.type = type
	field_item.star = star
	field_item.content = content

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/delete_field")
async def delete_field(req: Request):
	json = await req.json()
	id = json.get("id")

	field_item = Linq(data.fieldlist).find(lambda f: f.id == id, None)
	if field_item is None: return JSONResponse(content = {"status": "not exists"})

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("DELETE FROM qzj_field WHERE id=%s", (id,))
	data.fieldlist.remove(field_item)

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/edit_enterprise")
async def edit_enterprise(req: Request):
	json = await req.json()
	id = json.get("id")
	zone = json.get("zone")
	city = json.get("city")
	name = json.get("name")
	shortname = json.get("shortname")
	brief = json.get("brief")
	upper = json.get("upper")
	level = json.get("level")
	sector = json.get("sector")
	field = json.get("field")
	tag = json.get("tag")
	website1 = json.get("website1")
	website2 = json.get("website2")
	icon = json.get("icon")
	images = json.get("images")
	enttype = json.get("enttype")
	financial = json.get("financial")
	article1 = json.get("article1")
	article2 = json.get("article2")

	enterprise = Linq(data.enterpriselist).find(lambda e: e.id == id, None)
	if enterprise is None: return JSONResponse(content = {"status": "not exists"})

	zone_id = Linq(data.zonelist).find(lambda z: z.name == zone, None)
	if zone_id is None:
		return JSONResponse(content = {"status": f"zone_not_found: {zone}"})

	level_id = Linq(data.levellist).find(lambda l: l.name == level, None)
	if level_id is None:
		return JSONResponse(content = {"status": f"level_not_found: {level}"})

	sector_id = Linq(data.sectorlist).find(lambda s: s.name == sector, None)
	if sector_id is None:
		return JSONResponse(content = {"status": f"sector_not_found: {sector}"})

	fieldlist = []
	for f in field.split(','):
		if f.strip() == "": continue
		field_item = Linq(data.fieldlist).find(lambda fld: f.strip() in fld.mapping, None)
		if field_item is None:
			return JSONResponse(content = {"status": f"field_not_found: {f}"})
		if field_item.id not in fieldlist: fieldlist.append(field_item.id)

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute(
		"UPDATE qzj_enterprise SET zone=%s, city=%s, name=%s, shortname=%s, brief=%s, upper=%s, level=%s, sector=%s, tag=%s, website1=%s, website2=%s, icon=%s, images=%s, enttype=%s, financial=%s, article1=%s, article2=%s WHERE id=%s",
		(zone_id, city, name, shortname, brief, upper, level_id, sector_id, tag, website1, website2, icon, images, enttype, financial, article1, article2, id)
	)
	enterprise.zone = zone_id
	enterprise.city = city
	enterprise.name = name
	enterprise.shortname = shortname
	enterprise.brief = brief
	enterprise.upper = upper
	enterprise.level = level_id
	enterprise.sector = sector_id
	enterprise.tag = tag
	enterprise.website1 = website1
	enterprise.website2 = website2
	enterprise.icon = icon
	enterprise.images = images
	enterprise.enttype = enttype
	enterprise.financial = financial
	enterprise.article1 = article1
	enterprise.article2 = article2
	cursor.execute("DELETE FROM qzj_enterprise_field WHERE enterprise_id=%s", (id,))
	for fid in fieldlist:
		cursor.execute(
			"INSERT IGNORE INTO qzj_enterprise_field (enterprise_id, field) VALUES (%s, %s)",
			(id, fid)
		)
	enterprise.field = fieldlist

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/delete_enterprise")
async def delete_enterprise(req: Request):
	json = await req.json()
	id = json.get("id")

	enterprise = Linq(data.enterpriselist).find(lambda e: e.id == id, None)
	if enterprise is None: return JSONResponse(content = {"status": "not exists"})

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("DELETE FROM qzj_enterprise WHERE id=%s", (id,))
	cursor.execute("DELETE FROM qzj_enterprise_field WHERE enterprise_id=%s", (id,))
	data.enterpriselist.remove(enterprise)

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post('/delete_case')
async def delete_case(req: Request):
	json = await req.json()
	id = json.get("id")

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("DELETE FROM qzj_case WHERE id=%s", (id,))
	data.caselist = [c for c in data.caselist if c.id != id]

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/edit_case")
async def edit_case(req: Request):
	json = await req.json()
	id = json.get("id")
	name = json.get("name")
	enterprise = json.get("enterprise")
	field = json.get("field")
	tags = json.get("tags")
	student = json.get("student")
	school1 = json.get("school1")
	tag = json.get("school1_tag")
	stag1 = 0
	if tag == '985': stag1 = 1
	if tag == '211': stag1 = 2
	if tag == '普通': stag1 = 3
	if tag == '海外': stag1 = 4
	field1 = json.get("field1")
	school2 = json.get("school2")
	tag = json.get("school2_tag")
	stag2 = 0
	if tag == '985': stag2 = 1
	if tag == '211': stag2 = 2
	if tag == '普通': stag2 = 3
	if tag == '海外': stag2 = 4
	field2 = json.get("field2")
	year = json.get("year")
	detail = json.get("detail")

	case = Linq(data.caselist).find(lambda c: c.id == id, None)
	if case is None: return JSONResponse(content = {"status": "not exists"})

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute(
		"UPDATE qzj_case SET name=%s, enterprise=%s, field=%s, tags=%s, student=%s, school1=%s, school1_tag=%s, field1=%s, school2=%s, school2_tag=%s, field2=%s, year=%s, detail=%s WHERE id=%s",
		(name, enterprise, field, tags, student, school1, stag1, field1, school2, stag2, field2, year, detail, id)
	)
	case.name = name
	case.enterprise = enterprise
	case.field = field
	case.tags = tags
	case.student = student
	case.school1 = school1
	case.stag1 = stag1
	case.field1 = field1
	case.school2 = school2
	case.stag2 = stag2
	case.field2 = field2
	case.year = year
	case.detail = detail

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.post("/import_excel")
async def import_excel(req: Request):
	json = await req.json()
	filename = json.get("filename")
	filedata = json.get("filedata")

	timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
	with open(f'./upload/{timestamp}.xlsx', 'wb') as f:
		f.write(filedata.encode('latin1'))

	shutil.copy(f'./upload/{timestamp}.xlsx', './upload/企业列表.xlsx')

	process = await asyncio.create_subprocess_exec(
		'python3', 'parse.py',
		cwd =  "./upload",
		stdout = asyncio.subprocess.PIPE,
		stderr = asyncio.subprocess.PIPE,
	)
	stdout, stderr = await process.communicate()
	if process.returncode != 0:
		status = f"out: {stdout.decode()} error: {stderr.decode()}"
	else:
		status = "success"

	return JSONResponse(content = {
		"code": 0,
		"status": status,
	})
