from typing import List, Dict

from tapah.struct import MySQLPool, Zone, Sector, Level, Field, Question, Enterprise, Case, User

mysql_pool : MySQLPool = None

zonelist : List[Zone] = []
sectorlist : List[Sector] = []
levellist : List[Level] = []
fieldlist : List[Field] = []
questionlist : List[Question] = []
enterpriselist : List[Enterprise] = []
caselist : List[Case] = []
userlist : Dict[str, User] = {}

appid = 'wxb0b1ae0733a3c160'
appsecret = '10f6523f47ff45987af35a4caeff15c7'

chatai_base_url = "https://ai.fxeasy168.com:3100"
chatai_provider_code = "sys_job_hunting"
chatai_secret_key = "rhzn_qzj_419ce962"
chatai_auth_path = "/consoleapi/third-party/auth"
chatai_chat_path = "/consoleapi/v1/chat"
chatai_agents = {
	"resume": "ak_5966c4fcd60a57ff096e9d9f364ad196",
	"joblevel": "ak_7c12da60fe92d9b24ed043b5a0c1cccf",
}
