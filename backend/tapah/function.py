import hashlib
import re
import threading
import time

import requests

from tapah import data
from tapah import reserved
from tapah.struct import MySQLPool, Zone, Sector, Level, Field, Question, Article, Enterprise, Case, User

def keep_mysql_alive():
	while True:
		time.sleep(reserved.mysql_keepalive_interval)
		try:
			data.mysql_conn.ping(reconnect = True)
		except:
			pass

def fetch_article_meta(url):
	title = ""
	description = ""
	if not url or not str(url).strip():
		return title, description
	try:
		resp = requests.get(
			url,
			headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"},
			timeout = 10.0,
			allow_redirects = True,
		)
		html = resp.text
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
	except Exception:
		pass
	return title, description

def create_article(url, update = None):
	url = (url or "").strip()
	if update is None:
		update = int(time.time())
	title, description = fetch_article_meta(url)
	return Article(url, int(update), title, description)

def articles_to_json(articles):
	return [article.to_dict() for article in articles]

def init_config():
	data.mysql_pool = MySQLPool() 

	threading.Thread(target  = keep_mysql_alive, daemon = True).start()

	conn = data.mysql_pool.apply()
	cursor = conn.cursor()

	cursor.execute("SELECT * FROM qzj_zone")
	result = cursor.fetchall()
	for row in result:
		zone = Zone(row[0], row[1])
		data.zonelist.append(zone)
	print(f'zone: {len(data.zonelist)}')

	cursor.execute("SELECT * FROM qzj_sector")
	result = cursor.fetchall()
	for row in result:
		sector = Sector(row[0], row[1])
		data.sectorlist.append(sector)
	print(f'sector: {len(data.sectorlist)}')

	cursor.execute("SELECT * FROM qzj_level")
	result = cursor.fetchall()
	for row in result:
		level = Level(row[0], row[1])
		data.levellist.append(level)
	print(f'level: {len(data.levellist)}')

	cursor.execute("SELECT * FROM qzj_field")
	result = cursor.fetchall()
	for row in result:
		field = Field(row[0], row[1], row[2].split(','), row[3], row[4], row[5])
		data.fieldlist.append(field)
	print(f'field: {len(data.fieldlist)}')

	cursor.execute("SELECT id, agent, question FROM qzj_questions ORDER BY id")
	result = cursor.fetchall()
	for row in result:
		data.questionlist.append(Question(row[0], row[1], row[2]))
	print(f'question: {len(data.questionlist)}')

	cursor.execute("SELECT * FROM qzj_enterprise")
	result = cursor.fetchall()
	for row in result:
		enterprise = Enterprise(row[0], row[1], row[2], row[3], row[11], row[4], row[5], row[6], row[7], row[9], row[10], row[8], row[12], row[13], row[14], row[15], row[16], row[17] if len(row) > 17 else "")
		data.enterpriselist.append(enterprise)

	cursor.execute("SELECT * FROM qzj_enterprise_field")
	result = cursor.fetchall()
	for row in result:
		for enterprise in data.enterpriselist:
			if enterprise.id == row[1]:
				enterprise.addfield(row[2])
		print(f'addfield: {row[1]} {row[2]}')
	cursor.execute("SELECT * FROM qzj_enterprise_article")
	article_rows = cursor.fetchall()
	for article in article_rows:
		for enterprise in data.enterpriselist:
			if enterprise.id == article[1]:
				info = create_article(article[3], article[4])
				if article[2] == 1:
					enterprise.article1.append(info)
				elif article[2] == 2:
					enterprise.article2.append(info)
				break
		print(f'addarticle: {article[1]} {article[2]} {article[3]} {article[4]}')
	print(f'enterprise: {len(data.enterpriselist)}')

	cursor.execute("SELECT * FROM qzj_case")
	result = cursor.fetchall()
	for row in result:
		case = Case(row[0], row[1], row[2], row[3], row[4].split(','), row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14])
		data.caselist.append(case)
	print(f'case: {len(data.caselist)}')

	cursor.execute("SELECT * FROM qzj_user")
	result = cursor.fetchall()
	for row in result:
		user = User(row[0], row[1])
		user.nickname = row[2]
		user.avatar = row[3]
		user.field = row[4].split(',') if row[4] else []
		user.enterprise = row[5].split(',') if row[5] else []
		data.userlist[user.openid] = user
	print(f'user: {len(data.userlist)}')

	cursor.close()
	data.mysql_pool.release(conn)

def md5_hex(text: str) -> str:
	return hashlib.md5(text.encode("utf-8")).hexdigest()
