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
