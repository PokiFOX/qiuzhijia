from typing import List, Dict

from tapah.struct import MySQLPool, Zone, Sector, Level, Field, Enterprise, Case, User

mysql_pool : MySQLPool = None

zonelist : List[Zone] = []
sectorlist : List[Sector] = []
levellist : List[Level] = []
fieldlist : List[Field] = []
enterpriselist : List[Enterprise] = []
caselist : List[Case] = []
userlist : Dict[str, User] = {}

appid = 'wxb0b1ae0733a3c160'
appsecret = '10f6523f47ff45987af35a4caeff15c7'
