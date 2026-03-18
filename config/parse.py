import json
import openpyxl
import mysql.connector
import requests

from tapah import const
from tapah import data
from tapah import function
from tapah import reserved

data.mysql_conn = mysql.connector.connect(
	host		= reserved.mysql_host,
	port		= reserved.mysql_port,
	user		= reserved.mysql_username,
	password	= reserved.mysql_password,
	database	= reserved.mysql_database,
	auth_plugin = 'caching_sha2_password',
)
data.mysql_conn.connect()

wb = openpyxl.load_workbook('企业列表.xlsx')

globalpage = wb['全局设置']
zone = []
for i in range(2, globalpage.max_row + 1):
	cell_value = function.getcell_str(globalpage, i, 1)
	if cell_value == "": continue
	zone.append(cell_value)

sector = []
for i in range(2, globalpage.max_row + 1):
	cell_value = function.getcell_str(globalpage, i, 3)
	if cell_value == "": continue
	sector.append(cell_value)

level = []
for i in range(2, globalpage.max_row + 1):
	cell_value = function.getcell_str(globalpage, i, 2)
	if cell_value == "": continue
	level.append(cell_value)

field = []
for i in range(2, wb['学科列表'].max_row + 1):
	name = function.getcell_str(wb['学科列表'], i, 1)
	field_item = next((item for item in field if item['name'] == name), None)
	mapname = function.getcell_str(wb['学科列表'], i, 2)
	if field_item is None:
		sector1 = function.getcell_str(wb['学科列表'], i, 3)
		star = function.getcell_int(wb['学科列表'], i, 4)
		content = function.getcell_str(wb['学科列表'], i, 5)
		field.append({
			"name": name,
			"sector": sector1,
			"star": star,
			"content": content,
			"mapname": [mapname],
		})
	else:
		field_item['mapname'].append(mapname)

try:
	print(const.url_setzone)
	r = requests.post(function.url(const.url_setzone), json = zone, headers = const.request_headers, timeout = 15)
	r.raise_for_status()
	print(const.url_setsector)
	r = requests.post(function.url(const.url_setsector), json = sector, headers = const.request_headers, timeout = 15)
	r.raise_for_status()
	print(const.url_setlevel)
	r = requests.post(function.url(const.url_setlevel), json = level, headers = const.request_headers, timeout = 15)
	r.raise_for_status()
	print(const.url_setfield)
	r = requests.post(function.url(const.url_setfield), json = field, headers = const.request_headers, timeout = 15)
	r.raise_for_status()
except requests.RequestException as err:
	print(f"设置失败 : {err}")

for i in range(3, len(wb.sheetnames) + 1):
	sheet = wb[wb.sheetnames[i - 1]]
	for row in range(2, sheet.max_row + 1):
		enterprise = {
			"zone": function.getcell_str(sheet, row, const.column_zone),				# 地区
			"city": function.getcell_str(sheet, row, const.column_city),				# 城市
			"name": function.getcell_str(sheet, row, const.column_name),				# 公司名称
			"shortname": function.getcell_str(sheet, row, const.column_short),			# 公司简称
			"brief": function.getcell_str(sheet, row, const.column_brief),				# 公司简介
			"upper": function.getcell_str(sheet, row, const.column_upper),				# 上级单位
			"sector": function.getcell_str(sheet, row, const.column_sector),			# 公司大类
			"level": function.getcell_str(sheet, row, const.column_level),				# 公司层级
			"field": function.getcell_str(sheet, row, const.column_offer),				# 主要招聘学科
			"website1": function.getcell_str(sheet, row, const.column_website1),		# 官网
			"website2": function.getcell_str(sheet, row, const.column_website2),		# 校招官网
		}
		tag1 = function.getcell_str(sheet, row, const.column_tag1)				# 标签1
		tag2 = function.getcell_str(sheet, row, const.column_tag2)				# 标签2
		tag3 = function.getcell_str(sheet, row, const.column_tag3)				# 标签3
		tag4 = function.getcell_str(sheet, row, const.column_tag4)				# 标签4
		tag5 = function.getcell_str(sheet, row, const.column_tag5)				# 标签5
		tag = []
		if tag1 != "": tag.append(tag1)
		if tag2 != "": tag.append(tag2)
		if tag3 != "": tag.append(tag3)
		if tag4 != "": tag.append(tag4)
		if tag5 != "": tag.append(tag5)
		enterprise['tag'] = ','.join(tag)
		if enterprise['zone'] not in zone:
			print(f"地区不合法: {enterprise['zone']} 企业: {enterprise['name']}")
			continue
		if enterprise['sector'] not in sector:
			print(f"公司大类不合法: {enterprise['sector']} 企业: {enterprise['name']}")
			continue
		if enterprise['level'] not in level:
			print(f"公司层级不合法: {enterprise['level']} 企业: {enterprise['name']}")
			continue
		fields = enterprise['field'].split(',')
		valid_fields = []
		for f in fields:
			find = False
			for field_item in field:
				if f in field_item['mapname']:
					find = True
					break
			if not find and f != "":
				print(f"主要招聘学科不合法: {f} 企业: {enterprise['name']}")
			else:
				valid_fields.append(f)
		if len(fields) != len(valid_fields):
			continue

		try:
			r = requests.post(function.url(const.url_insert_enterprise), json = enterprise, headers = const.request_headers, timeout = 15)
			r.raise_for_status()
			rj = json.loads(r.text)
			if 'code' not in rj or rj['code'] != 0:
				print(f"已失败: {enterprise['name']} response code {r.status_code} content: {r.text}")
		except requests.RequestException as err:
			print(f"上传失败 {enterprise['name']}: {err}")

wb.close()
