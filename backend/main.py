import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import faulthandler

from tapah import data
from tapah import function
from tapah.struct import Linq, Zone, Level, Sector, Field, Enterprise

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
			"sector": field.sector,
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
	for enterprise in data.enterpriselist:
		if zone_id != 0 and enterprise.zone != zone_id: continue
		if sector_id != 0 and enterprise.sector != sector_id: continue
		if level_id != 0 and enterprise.level != level_id: continue
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
		})

	return JSONResponse(content = {
		"code": 0,
		"status": "success",
		"data": {
			"enterpriselist": enterpriselist,
		},
	})

@app.post("/insert_enterprise")
async def insert_enterprise(req: Request):
	json = await req.json()
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
		"INSERT INTO qzj_enterprise (zone, city, name, shortname, brief, upper, level, sector, tag, website1, website2) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
		(zone_item.id, city, name, shortname, brief, upper, level_item.id, sector_item.id, tag, website1, website2)
	)
	enterprise_id = cursor.lastrowid
	enterprise = Enterprise(enterprise_id, zone_item.id, city, name, shortname, brief, upper, level_item.id, sector_item.id, website1, website2, tag.split(','))
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
		cursor.execute("INSERT IGNORE INTO qzj_field (field, mapping, sector, star, content) VALUES (%s,%s,%s,%s,%s)", (field['name'], ','.join(field['mapname']), field['sector'], field['star'], field['content']))
		last_id = cursor.lastrowid
		if last_id != 0: data.fieldlist.append(Field(last_id, field['name'], field['mapname'], field['sector'], field['star'], field['content']))

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
	sector = json.get("sector")
	star = json.get("star")
	content = json.get("content")

	field_item = Linq(data.fieldlist).find(lambda f: f.id == id, None)
	if field_item is None: return JSONResponse(content = {"status": "not exists"})

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("UPDATE qzj_field SET field=%s, mapping=%s, sector=%s, star=%s, content=%s WHERE id=%s", (field, ','.join(mapping), sector, star, content, id))
	field_item.name = field
	field_item.mapname = mapping
	field_item.sector = sector
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
		"UPDATE qzj_enterprise SET zone=%s, city=%s, name=%s, shortname=%s, brief=%s, upper=%s, level=%s, sector=%s, tag=%s, website1=%s, website2=%s WHERE id=%s",
		(zone_id, city, name, shortname, brief, upper, level_id, sector_id, tag, website1, website2, id)
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

@app.post("/import_excel")
async def import_excel(req: Request):
	json = await req.json()
	filename = json.get("filename")
	filedata = json.get("filedata")

	with open(f'./upload/企业列表.xlsx', 'wb') as f:
		f.write(filedata.encode('latin1'))

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
