from typing import List

from tapah.struct import MySQLPool, Zone, Sector, Level, Field, Enterprise, Case

mysql_pool : MySQLPool = None

zonelist : List[Zone] = []
sectorlist : List[Sector] = []
levellist : List[Level] = []
fieldlist : List[Field] = []
enterpriselist : List[Enterprise] = []
caselist : List[Case] = []
