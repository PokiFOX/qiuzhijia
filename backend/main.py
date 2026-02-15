from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import faulthandler

from tapah import data
from tapah import function

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

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("SELECT id FROM qzj_enterprise WHERE name = %s", (name,))
	result = cursor.fetchone()
	if result is not None:
		cursor.close()
		data.mysql_pool.release(conn)
		return JSONResponse(content = {"status": "exists"})

	cursor.execute("SELECT id FROM qzj_zone WHERE zone=%s", (zone,))
	result = cursor.fetchone()
	if result is None:
		cursor.close()
		data.mysql_pool.release(conn)
		return JSONResponse(content = {"status": f"zone_not_found: {zone}"})

	zone_id = result[0]
	cursor.execute("SELECT id FROM qzj_level WHERE level=%s", (level,))
	result = cursor.fetchone()
	if result is None:
		cursor.close()
		data.mysql_pool.release(conn)
		return JSONResponse(content = {"status": f"level_not_found: {level}"})

	level_id = result[0]

	cursor.execute("SELECT id FROM qzj_sector WHERE sector=%s", (sector,))
	result = cursor.fetchone()
	if result is None:
		cursor.close()
		data.mysql_pool.release(conn)
		return JSONResponse(content = {"status": f"sector_not_found: {sector}"})
	sector_id = result[0]

	fieldlist = []
	for f in field.split("；"):
		if f.strip() == "": continue
		cursor.execute("SELECT id FROM qzj_field WHERE field=%s", (f.strip(),))
		result = cursor.fetchone()
		if result is None:
			cursor.close()
			data.mysql_pool.release(conn)
			return JSONResponse(content = {"status": f"field_not_found: {f}"})
		fieldlist.append(result[0])

	cursor.execute(
		"INSERT INTO qzj_enterprise (zone, city, name, shortname, brief, upper, level, sector, tag, website1, website2) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
		(zone_id, city, name, shortname, brief, upper, level_id, sector_id, tag, website1, website2)
	)
	enterprise_id = cursor.lastrowid
	for fid in fieldlist:
		cursor.execute(
			"INSERT IGNORE INTO qzj_enterprise_field (enterprise_id, field) VALUES (%s, %s)",
			(enterprise_id, fid)
		)

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})

@app.get("/query_zonelist")
async def query_zonelist(req: Request):
	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("SELECT * FROM qzj_zone")
	result = cursor.fetchall()
	zonelist = {row[0]: row[1] for row in result}

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
		"data": {
			"zonelist": zonelist,
		},
	})

@app.get("/query_levellist")
async def query_levellist(req: Request):
	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("SELECT * FROM qzj_level")
	result = cursor.fetchall()
	levellist = {row[0]: row[1] for row in result}

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
		"data": {
			"levellist": levellist,
		},
	})

@app.get("/query_sectorlist")
async def query_sectorlist(req: Request):
	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("SELECT * FROM qzj_sector")
	result = cursor.fetchall()
	sectorlist = {row[0]: row[1] for row in result}

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
		"data": {
			"sectorlist": sectorlist,
		},
	})

@app.get("/query_fieldlist")
async def query_fieldlist(req: Request):
	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("SELECT * FROM qzj_field")
	result = cursor.fetchall()
	fieldlist = []
	for row in result:
		fieldlist.append({
			"id": row[0],
			"name": row[1],
			"sector": row[2],
			"star": row[3],
			"content": row[4],
		})

	cursor.close()
	data.mysql_pool.release(conn)
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
	levels = json.get("levels")
	sector_id = json.get("sector")

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	if zone_id != 0:
		cursor.execute("SELECT id FROM qzj_zone WHERE zone=%s", (zone_id,))
		result = cursor.fetchall()
		if result is None:
			cursor.close()
			data.mysql_pool.release(conn)
			return JSONResponse(content = {
				"code": 1,
				"status": "zone_not_found",
			})
	if len(levels) != 0:
		for level in levels:
			cursor.execute("SELECT id FROM qzj_level WHERE level=%s", (level,))
			result = cursor.fetchall()
			if result is None:
				cursor.close()
				data.mysql_pool.release(conn)
				return JSONResponse(content = {
				"code": 1,
				"status": "level_not_found",
			})
	if sector_id != 0:
		cursor.execute("SELECT id FROM qzj_sector WHERE sector=%s", (sector_id,))
		result = cursor.fetchall()
		if result is None:
			cursor.close()
			data.mysql_pool.release(conn)
			return JSONResponse(content = {
				"code": 1,
				"status": "sector_not_found",
			})

	params = []
	conds = []
	if zone_id != 0:
		conds.append("zone=%s")
		params.append(zone_id)
	if len(levels) != 0:
		conds.append(f"level IN ({','.join(['%s'] * len(levels))})")
		params.extend(levels)
	if sector_id != 0:
		conds.append("sector=%s")
		params.append(sector_id)
	if conds:
		sql = "SELECT * FROM qzj_enterprise WHERE " + " AND ".join(conds)
		cursor.execute(sql, tuple(params))
	else:
		cursor.execute("SELECT * FROM qzj_enterprise")
	result = cursor.fetchall()
	enterpriselist = []
	for row in result:
		cursor.execute("SELECT * FROM qzj_enterprise_field WHERE enterprise_id=%s", (row[0],))
		fieldresult = cursor.fetchall()
		fieldnames = []
		for fieldrow in fieldresult:
			fieldnames.append(fieldrow[2])
		enterpriselist.append({
			"id": row[0],
			"zone": row[1],
			"city": row[2],
			"name": row[3],
			"brief": row[4],
			"upper": row[5],
			"level": row[7],
			"sector": row[6],
			"field": fieldnames,
			"tag": row[8],
			"website1": row[9],
			"website2": row[10],
			"shortname": row[11],
		})

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
		"data": {
			"enterpriselist": enterpriselist,
		},
	})

@app.post("/set_zone")
async def set_zone(req: Request):
	json = await req.json()
	zone_list = json

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	for zone in zone_list:
		cursor.execute("INSERT IGNORE INTO qzj_zone (zone) VALUES (%s)", (zone,))

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
		cursor.execute("INSERT IGNORE INTO qzj_level (level) VALUES (%s)", (level,))

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
		cursor.execute("INSERT IGNORE INTO qzj_sector (sector) VALUES (%s)", (sector,))

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
		cursor.execute("INSERT IGNORE INTO qzj_field (field, sector, star, content) VALUES (%s,%s,%s,%s)", (field['name'], field['sector'], field['star'], field['content']))

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

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("UPDATE qzj_zone SET zone=%s WHERE id=%s", (zone, id))

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

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("DELETE FROM qzj_zone WHERE id=%s", (id,))

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

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("UPDATE qzj_level SET level=%s WHERE id=%s", (level, id))

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

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("DELETE FROM qzj_level WHERE id=%s", (id,))

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

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("UPDATE qzj_sector SET sector=%s WHERE id=%s", (sector, id))

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

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("DELETE FROM qzj_sector WHERE id=%s", (id,))

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
	sector = json.get("sector")
	star = json.get("star")
	content = json.get("content")

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("UPDATE qzj_field SET field=%s, sector=%s, star=%s, content=%s WHERE id=%s", (field, sector, star, content, id))

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

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("DELETE FROM qzj_field WHERE id=%s", (id,))

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

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("SELECT id FROM qzj_zone WHERE zone=%s", (zone,))
	result = cursor.fetchone()
	if result is None:
		cursor.close()
		data.mysql_pool.release(conn)
		return JSONResponse(content = {"status": f"zone_not_found: {zone}"})

	zone_id = result[0]
	cursor.execute("SELECT id FROM qzj_level WHERE level=%s", (level,))
	result = cursor.fetchone()
	if result is None:
		cursor.close()
		data.mysql_pool.release(conn)
		return JSONResponse(content = {"status": f"level_not_found: {level}"})

	level_id = result[0]

	cursor.execute("SELECT id FROM qzj_sector WHERE sector=%s", (sector,))
	result = cursor.fetchone()
	if result is None:
		cursor.close()
		data.mysql_pool.release(conn)
		return JSONResponse(content = {"status": f"sector_not_found: {sector}"})
	sector_id = result[0]

	fieldlist = []
	for f in field.split("；"):
		if f.strip() == "": continue
		cursor.execute("SELECT id FROM qzj_field WHERE field=%s", (f.strip(),))
		result = cursor.fetchone()
		if result is None:
			cursor.close()
			data.mysql_pool.release(conn)
			return JSONResponse(content = {"status": f"field_not_found: {f}"})
		fieldlist.append(result[0])

	cursor.execute(
		"UPDATE qzj_enterprise SET zone=%s, city=%s, name=%s, shortname=%s, brief=%s, upper=%s, level=%s, sector=%s, tag=%s, website1=%s, website2=%s WHERE id=%s",
		(zone_id, city, name, shortname, brief, upper, level_id, sector_id, tag, website1, website2, id)
	)
	cursor.execute("DELETE FROM qzj_enterprise_field WHERE enterprise_id=%s", (id,))
	for fid in fieldlist:
		cursor.execute(
			"INSERT IGNORE INTO qzj_enterprise_field (enterprise_id, field) VALUES (%s, %s)",
			(id, fid)
		)
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

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("DELETE FROM qzj_enterprise WHERE id=%s", (id,))
	cursor.execute("DELETE FROM qzj_enterprise_field WHERE enterprise_id=%s", (id,))

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"status": "success",
	})
