import mysql.connector
import threading
import time

from tapah import reserved

class MySQLConn:
	def __init__(self):
		self.conn = mysql.connector.connect(
			host		= reserved.mysql_host,
			port		= reserved.mysql_port,
			user		= reserved.mysql_username,
			password	= reserved.mysql_password,
			database	= reserved.mysql_database,
			autocommit	= True
		)

	def ping(self):
		try:
			self.conn.ping(reconnect = True, attempts = 1, delay = 0)
			return True
		except:
			return False

	def close(self):
		try:
			self.conn.close()
		except:
			pass

	def cursor(self):
		return self.conn.cursor()

class MySQLPool:
	def __init__(self):
		self.idle = None
		self.lock = threading.Lock()

		self.add()

		threading.Thread(target = self.loop, daemon = True).start()

	def add(self):
		self.idle = MySQLConn()

	def apply(self):
		with self.lock:
			if self.idle is not None:
				conn = self.idle
				self.add()
				return conn
		return MySQLConn()

	def release(self, conn: MySQLConn):
		conn.close()

	def loop(self):
		while True:
			time.sleep(60)
			with self.lock:
				if self.idle.ping() == False:
					self.add()

class Linq:
	def __init__(self, iterable):
		self.items = iterable

	def where(self, predicate):
		self.items = (x for x in self.items if predicate(x))
		return self

	def select(self, selector):
		self.items = (selector(x) for x in self.items)
		return self

	def find(self, predicate, default = None):
		for x in self.items:
			if predicate(x):
				return x
		return default

	def to_list(self):
		return list(self.items)

	def any(self, predicate = None):
		for x in self.items:
			if predicate is None or predicate(x):
				return True
		return False

class Zone:
	def __init__(self, id, name):
		self.id = id
		self.name = name

class Sector:
	def __init__(self, id, name):
		self.id = id
		self.name = name

class Level:
	def __init__(self, id, name):
		self.id = id
		self.name = name

class Field:
	def __init__(self, id, name, mapping, type, star, content):
		self.id = id
		self.name = name
		self.mapping = mapping
		self.type = type
		self.star = star
		self.content = content

class Enterprise:
	def __init__(self, id, zone, city, name, shortname, brief, upper, sector, level, website1, website2, tag, icon, images, enttype, financial, article1, article2):
		self.id = id
		self.zone = zone
		self.city = city
		self.name = name
		self.shortname = shortname
		self.brief = brief
		self.upper = upper
		self.sector = sector
		self.level = level
		self.website1 = website1
		self.website2 = website2
		self.tag = tag
		self.icon = icon
		self.images = images
		self.enttype = enttype
		self.financial = financial
		self.article1 = article1
		self.article2 = article2
		self.field = []

	def addfield(self, field):
		self.field.append(field)

class Case:
	def __init__(self, id, name, enterprise, field, tags, student, school1, field1, school2, field2, detail):
		self.id = id
		self.name = name
		self.enterprise = enterprise
		self.field = field
		self.tags = tags
		self.student = student
		self.school1 = school1
		self.field1 = field1
		self.school2 = school2
		self.field2 = field2
		self.detail = detail
