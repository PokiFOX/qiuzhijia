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
		"INSERT INTO qzj_enterprise (zone, city, name, brief, upper, level, sector, tag, website1, website2) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
		(zone_id, city, name, brief, upper, level_id, sector_id, tag, website1, website2)
	)
	enterprise_id = cursor.lastrowid
	for fid in fieldlist:
		cursor.execute(
			"INSERT IGNORE INTO qzj_enterprise_field (enterprise_id, field) VALUES (%s, %s)",
			(enterprise_id, fid)
		)

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {"status": "success"})

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
		"data": {
			"zonelist": zonelist},
		}
	)

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
		"data": {
			"levellist": levellist},
		}
	)

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
		"data": {
			"sectorlist": sectorlist},
		}
	)

@app.get("/query_fieldlist")
async def query_fieldlist(req: Request):
	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("SELECT * FROM qzj_field")
	result = cursor.fetchall()
	fieldlist = {row[0]: row[1] for row in result}

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"data": {
			"fieldlist": fieldlist},
		}
	)

@app.post("/query_enterprise")
async def query_enterprise(req: Request):
	json = await req.json()
	zone_id = json.get("zone")
	level_id = json.get("level")
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
	if level_id != 0:
		cursor.execute("SELECT id FROM qzj_level WHERE level=%s", (level_id,))
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
	if level_id != 0:
		conds.append("level=%s")
		params.append(level_id)
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
			"level": row[6],
			"sector": row[7],
			"field": fieldnames,
			"tag": row[8],
			"website1": row[9],
			"website2": row[10],
		})

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {
		"code": 0,
		"data": {
			"enterpriselist": enterpriselist},
		}
	)

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
	return JSONResponse(content = {"status": "success"})

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
	return JSONResponse(content = {"status": "success"})

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
	return JSONResponse(content = {"status": "success"})

@app.post("/set_field")
async def set_field(req: Request):
	json = await req.json()
	field_list = json

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	for field in field_list:
		cursor.execute("INSERT IGNORE INTO qzj_field (field) VALUES (%s)", (field,))

	cursor.close()
	data.mysql_pool.release(conn)
	return JSONResponse(content = {"status": "success"})
