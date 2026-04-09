import threading
import time

from tapah import data
from tapah import reserved
from tapah.struct import MySQLPool, Zone, Sector, Level, Field, Enterprise, Case

def keep_mysql_alive():
	while True:
		time.sleep(reserved.mysql_keepalive_interval)
		try:
			data.mysql_conn.ping(reconnect = True)
		except:
			pass

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

	cursor.execute("SELECT * FROM qzj_sector")
	result = cursor.fetchall()
	for row in result:
		sector = Sector(row[0], row[1])
		data.sectorlist.append(sector)

	cursor.execute("SELECT * FROM qzj_level")
	result = cursor.fetchall()
	for row in result:
		level = Level(row[0], row[1])
		data.levellist.append(level)

	cursor.execute("SELECT * FROM qzj_field")
	result = cursor.fetchall()
	for row in result:
		field = Field(row[0], row[1], row[2].split(','), row[3], row[4], row[5])
		data.fieldlist.append(field)

	cursor.execute("SELECT * FROM qzj_enterprise")
	result = cursor.fetchall()
	for row in result:
		enterprise = Enterprise(row[0], row[1], row[2], row[3], row[11], row[4], row[5], row[6], row[7], row[9], row[10], row[8], row[12], row[13], row[14], row[15], row[16], row[17])
		data.enterpriselist.append(enterprise)

	cursor.execute("SELECT * FROM qzj_enterprise_field")
	result = cursor.fetchall()
	for row in result:
		for enterprise in data.enterpriselist:
			if enterprise.id == row[1]:
				enterprise.addfield(row[2])

	cursor.execute("SELECT * FROM qzj_case")
	result = cursor.fetchall()
	for row in result:
		case = Case(row[0], row[1], row[2], row[3], row[4].split(','), row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13])
		data.caselist.append(case)

	cursor.close()
	data.mysql_pool.release(conn)
