import threading
import time

from tapah import data
from tapah import reserved
from tapah.struct import MySQLPool

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
