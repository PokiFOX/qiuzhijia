from typing import List

from tapah.struct import MySQLPool, Zone, Sector, Level, Field, Enterprise

mysql_pool : MySQLPool = None

zonelist : List[Zone] = []
sectorlist : List[Sector] = []
levellist : List[Level] = []
fieldlist : List[Field] = []
enterpriselist : List[Enterprise] = []
