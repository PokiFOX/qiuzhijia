import json
import re

from tapah import data
from tapah.struct import Linq

DEPT_POS_RE = re.compile(
	r"^(.*?(?:部|中心|室|处|组|办|局|实验室|调度中心))(.+)$"
)


def _parse_pipe_segment(segment: str) -> tuple[str, str, str] | None:
	parts = [p.strip() for p in segment.split("|")]
	if len(parts) != 3:
		return None
	company, department, position = parts
	if not company or not department or not position:
		return None
	return company, department, position


def parse_pipe_detail(text: str, ent_name_to_id: dict[str, int]) -> list[dict]:
	if not text or not str(text).strip():
		return []
	result = []
	for segment in str(text).split(","):
		segment = segment.strip()
		if not segment:
			continue
		parsed = _parse_pipe_segment(segment)
		if parsed is None:
			raise ValueError(f"invalid pipe segment: {segment}")
		company, department, position = parsed
		ent_id = ent_name_to_id.get(company)
		if ent_id is None:
			raise ValueError(f"enterprise not found: {company}")
		result.append({
			"enterpriseId": ent_id,
			"enterpriseName": company,
			"department": department,
			"position": position,
		})
	return result


def _build_ent_name_map(enterpriselist) -> dict[str, int]:
	return {e.name: e.id for e in enterpriselist}


def _is_json_array(text: str) -> bool:
	text = str(text or "").strip()
	return text.startswith("[") and text.endswith("]")


def _validate_experience_item(item: dict, ent_name_to_id: dict[str, int]) -> dict:
	if not isinstance(item, dict):
		raise ValueError("experience item must be an object")
	name = str(item.get("enterpriseName", "")).strip()
	ent_id = item.get("enterpriseId")
	department = str(item.get("department", "")).strip()
	position = str(item.get("position", "")).strip()
	if not name:
		raise ValueError("enterpriseName required")
	if ent_id is None:
		ent_id = ent_name_to_id.get(name)
	if ent_id is None:
		raise ValueError(f"enterprise not found: {name}")
	return {
		"enterpriseId": int(ent_id),
		"enterpriseName": name,
		"department": department,
		"position": position,
	}


def normalize_detail_for_storage(detail, enterpriselist) -> str:
	text = str(detail or "").strip()
	if not text:
		return "[]"

	ent_name_to_id = _build_ent_name_map(enterpriselist)

	if _is_json_array(text):
		items = json.loads(text)
		if not isinstance(items, list):
			raise ValueError("detail json must be an array")
		normalized = [_validate_experience_item(item, ent_name_to_id) for item in items]
		return json.dumps(normalized, ensure_ascii=False)

	if "|" in text:
		experiences = parse_pipe_detail(text, ent_name_to_id)
		return json.dumps(experiences, ensure_ascii=False)

	return text


def parse_stored_detail(text) -> list[dict]:
	text = str(text or "").strip()
	if not text:
		return []
	if not _is_json_array(text):
		return []
	try:
		items = json.loads(text)
	except json.JSONDecodeError:
		return []
	if not isinstance(items, list):
		return []
	result = []
	for item in items:
		if not isinstance(item, dict):
			continue
		result.append({
			"enterpriseId": item.get("enterpriseId"),
			"enterpriseName": str(item.get("enterpriseName", "")).strip(),
			"department": str(item.get("department", "")).strip(),
			"position": str(item.get("position", "")).strip(),
		})
	return result


def enrich_experiences(exps) -> list[dict]:
	if not exps:
		return []
	result = []
	for exp in exps:
		ent_id = exp.get("enterpriseId")
		name = str(exp.get("enterpriseName", "")).strip()
		if ent_id is not None and not name:
			ent = Linq(data.enterpriselist).find(lambda e: e.id == ent_id, None)
			if ent is not None:
				name = ent.name
		result.append({
			"enterpriseId": ent_id,
			"enterpriseName": name,
			"department": str(exp.get("department", "")).strip(),
			"position": str(exp.get("position", "")).strip(),
		})
	return result
