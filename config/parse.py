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
)
data.mysql_conn.connect()

wb = openpyxl.load_workbook('企业列表.xlsx')

for i in range(2, len(wb.sheetnames) + 1):
	sheet = wb[wb.sheetnames[i - 1]]
	for row in range(2, sheet.max_row + 1):
		headers = {
			"Content-Type": "application/json",
		}

		enterprise = {
			"zone": function.getcell_str(sheet, row, const.column_zone),				# 地区
			"city": function.getcell_str(sheet, row, const.column_city),				# 城市
			"name": function.getcell_str(sheet, row, const.column_name),				# 公司名称
			"brief": function.getcell_str(sheet, row, const.column_brief),				# 公司简介
			"upper": function.getcell_str(sheet, row, const.column_upper),				# 上级单位
			"sector": function.getcell_str(sheet, row, const.column_sector),			# 公司大类
			"level": function.getcell_str(sheet, row, const.column_level),				# 公司层级
			"field": function.getcell_str(sheet, row, const.column_offer),				# 主要招聘学科
			"tag": function.getcell_str(sheet, row, const.column_tag),					# 标签
			"website1": function.getcell_str(sheet, row, const.column_website1),		# 官网
			"website2": function.getcell_str(sheet, row, const.column_website2),		# 校招官网
		}

		try:
			r = requests.post(function.url(const.url_insert_enterprise), json = enterprise, headers = headers, timeout = 15)
			r.raise_for_status()
			print(f"已上传: {enterprise['name']} response code {r.status_code} content: {r.text}")
		except requests.RequestException as err:
			print(f"上传失败 {enterprise['name']}: {err}")

wb.close()
