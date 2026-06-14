import json

from tapah import function

def generate_signature(body: dict, timestamp: int, secret_key: str, path: str) -> str:
	body_str = json.dumps(body, separators=(",", ":"), ensure_ascii=False, sort_keys=True)
	body_md5 = function.md5_hex(body_str)
	sign_text = f"{timestamp}:POST:{path}:{body_md5}:{secret_key}"
	return function.md5_hex(sign_text)

def build_auth_body(req: dict) -> dict:
	openid = req.get("openid", "")
	phone = req.get("phone") or openid
	body = {
		"miniProgramOpenId": openid,
		"phone": phone,
		"userIdentity": req.get("useridentity") or "学生",
		"userSource": req.get("usersource") or "求职+",
	}
	nickname = req.get("nickname", "")
	if nickname: body["nickName"] = nickname
	avatar = req.get("avatar", "")
	if avatar: body["avatarUrl"] = avatar
	email = req.get("email", "")
	if email: body["email"] = email
	realname = req.get("realname", "")
	if realname: body["realName"] = realname
	unionid = req.get("unionid", "")
	if unionid: body["unionId"] = unionid
	return body

def get_api_key(agent: str) -> str:
	from tapah import data
	return data.chatai_agents.get(agent, data.chatai_agents["resume"])

def load_aichat_history(openid: str, agent: str) -> tuple[list, str]:
	from tapah import data
	conn = data.mysql_pool.apply()
	cursor = conn.cursor()
	cursor.execute(
		"SELECT isuser, detail, timestamp FROM qzj_aichat_message WHERE openid=%s AND agent=%s ORDER BY timestamp ASC LIMIT 10",
		(openid, agent),
	)
	rows = cursor.fetchall()
	messages = [{"isuser": bool(row[0]), "detail": row[1], "timestamp": row[2]} for row in rows]
	cursor.execute(
		"SELECT conversation_id FROM qzj_aichat_session WHERE openid=%s AND agent=%s",
		(openid, agent),
	)
	row = cursor.fetchone()
	conversation_id = row[0] if row else ""
	cursor.close()
	data.mysql_pool.release(conn)
	return messages, conversation_id

def save_aichat_messages(openid: str, agent: str, message: str, reply: str, timestamp: int):
	from tapah import data
	conn = data.mysql_pool.apply()
	cursor = conn.cursor()
	cursor.execute(
		"INSERT INTO qzj_aichat_message (openid, agent, isuser, detail, timestamp) VALUES (%s, %s, %s, %s, %s)",
		(openid, agent, 1, message, timestamp),
	)
	cursor.execute(
		"INSERT INTO qzj_aichat_message (openid, agent, isuser, detail, timestamp) VALUES (%s, %s, %s, %s, %s)",
		(openid, agent, 0, reply, timestamp),
	)
	cursor.close()
	data.mysql_pool.release(conn)

def save_aichat_session(openid: str, agent: str, conversation_id: str, timestamp: int):
	from tapah import data
	conn = data.mysql_pool.apply()
	cursor = conn.cursor()
	cursor.execute(
		"INSERT INTO qzj_aichat_session (openid, agent, conversation_id, updated_at) VALUES (%s, %s, %s, %s) "
		"ON DUPLICATE KEY UPDATE conversation_id=VALUES(conversation_id), updated_at=VALUES(updated_at)",
		(openid, agent, conversation_id, timestamp),
	)
	cursor.close()
	data.mysql_pool.release(conn)
