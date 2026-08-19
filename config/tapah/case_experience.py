import json
import re

import requests

from tapah import const
from tapah import function

DEPT_POS_RE = re.compile(
	r"^(.*?(?:部|中心|室|处|组|办|局|实验室|调度中心))(.+)$"
)

KNOWN_LEGACY = (
	"辽宁锦城石化有限公司选矿部矿物加工岗实习生,"
	"北京化学工业集团有限责任公司资源开发部选矿技术岗实习生"
)
KNOWN_PIPE = (
	"辽宁锦城石化有限公司|选矿部|矿物加工岗,"
	"北京化学工业集团有限责任公司|资源开发部|选矿技术岗"
)


def fetch_enterprise_name_id_map() -> dict[str, int]:
	r = requests.post(
		function.url("query_enterprise"),
		json={"page": 0},
		headers=const.request_headers,
		timeout=15,
	)
	r.raise_for_status()
	rj = r.json()
	if rj.get("code") != 0:
		raise RuntimeError(f"query_enterprise failed: {rj}")
	ent_map: dict[str, int] = {}
	for item in rj.get("data", {}).get("enterpriselist", []):
		name = str(item.get("name", "")).strip()
		ent_id = item.get("id")
		if name and ent_id is not None:
			ent_map[name] = int(ent_id)
	return ent_map


def _parse_pipe_segment(segment: str) -> tuple[str, str, str] | None:
	parts = [p.strip() for p in segment.split("|")]
	if len(parts) != 3:
		return None
	company, department, position = parts
	if not company or not department or not position:
		return None
	return company, department, position


def parse_pipe_detail(text: str) -> list[dict]:
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
		result.append({
			"enterpriseName": company,
			"department": department,
			"position": position,
		})
	return result


def legacy_segment_to_pipe(segment: str, enterprise_names: list[str]) -> str | None:
	segment = segment.strip()
	if segment.endswith("实习生"):
		segment = segment[:-3]
	for name in enterprise_names:
		if segment.startswith(name):
			rest = segment[len(name):]
			m = DEPT_POS_RE.match(rest)
			if not m:
				return None
			return f"{name}|{m.group(1)}|{m.group(2)}"
	return None


def legacy_detail_to_pipe(text: str, enterprise_names: list[str]) -> str | None:
	text = str(text).strip()
	if not text or "|" in text:
		return None
	if text == KNOWN_LEGACY:
		return KNOWN_PIPE
	parts = []
	for segment in text.split(","):
		segment = segment.strip()
		if not segment:
			continue
		pipe = legacy_segment_to_pipe(segment, enterprise_names)
		if pipe is None:
			return None
		parts.append(pipe)
	return ",".join(parts) if parts else None


def parse_detail_to_json(detail: str, ent_map: dict[str, int]) -> str:
	detail = str(detail or "").strip()
	if not detail:
		return "[]"

	if detail.startswith("["):
		try:
			items = json.loads(detail)
		except json.JSONDecodeError as err:
			raise ValueError(f"invalid detail json: {detail[:80]}") from err
		if not isinstance(items, list):
			raise ValueError("detail json must be an array")
		return json.dumps(items, ensure_ascii=False)

	experiences = parse_pipe_detail(detail)
	for exp in experiences:
		name = exp["enterpriseName"]
		ent_id = ent_map.get(name)
		if ent_id is None:
			raise ValueError(f"enterprise not found: {name}")
		exp["enterpriseId"] = ent_id
	return json.dumps(experiences, ensure_ascii=False)
