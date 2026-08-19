from tapah import const
from tapah import data
from tapah.case_experience import enrich_experiences, parse_stored_detail
from tapah.struct import Linq


def _education_level(case) -> int:
	return 1 if case.school2 and str(case.school2).strip() else 0


def _best_stag_rank(case) -> int:
	stags = [s for s in (case.stag1, case.stag2) if s is not None and s > 0]
	if not stags:
		return 999
	return min(stags)


def _compare_primary(a, b) -> int:
	year_a = a.year or 0
	year_b = b.year or 0
	if year_b != year_a:
		return year_b - year_a

	edu_a = _education_level(a)
	edu_b = _education_level(b)
	if edu_b != edu_a:
		return edu_b - edu_a

	stag_a = _best_stag_rank(a)
	stag_b = _best_stag_rank(b)
	if stag_a != stag_b:
		return stag_a - stag_b

	return a.id - b.id


def pick_primary_case(cases):
	if not cases:
		return None
	return sorted(cases, key=lambda c: (
		-(c.year or 0),
		-_education_level(c),
		_best_stag_rank(c),
		c.id,
	))[0]


def _shares_school(candidate, reference) -> bool:
	if reference is None:
		return False
	ref_schools = [s for s in (reference.school1, reference.school2) if s and str(s).strip()]
	if not ref_schools:
		return False
	return any(s == candidate.school1 or s == candidate.school2 for s in ref_schools)


def sort_similar_cases(similar, reference):
	if not similar:
		return similar
	if reference is None:
		return sorted(similar, key=lambda c: c.id)
	return sorted(similar, key=lambda c: (not _shares_school(c, reference), c.id))


def filter_cases(
	enterprise_id,
	level,
	sector,
	field,
	stag1,
	stag2,
	year,
):
	enterprise = Linq(data.enterpriselist).find(lambda e: e.id == enterprise_id, None)
	if enterprise_id != 0 and enterprise is None:
		return None, []

	matched = []
	for case in data.caselist:
		ent = Linq(data.enterpriselist).find(lambda e: e.id == case.enterprise)
		if ent is None:
			continue
		if level != 0 and ent.level != level:
			continue
		if sector != 0 and ent.sector != sector:
			continue
		if field != 0 and case.field != field:
			continue
		if enterprise_id != 0 and enterprise is not None and enterprise.id != case.enterprise:
			continue
		if stag1 != 0 and case.stag1 != stag1:
			continue
		if stag2 != 0 and case.stag2 != stag2:
			continue
		if year == 1 and case.year != 2026:
			continue
		if year == 2 and case.year == 2026:
			continue
		matched.append((case, ent))
	return enterprise, matched


def serialize_case(case, ent):
	experiences = enrich_experiences(parse_stored_detail(case.detail))
	return {
		"id": case.id,
		"name": case.name,
		"enterprise": case.enterprise,
		"enticon": ent.icon,
		"entname": ent.name,
		"field": case.field,
		"tags": case.tags,
		"student": case.student,
		"school1": case.school1,
		"stag1": case.stag1,
		"field1": case.field1,
		"school2": case.school2,
		"stag2": case.stag2,
		"field2": case.field2,
		"year": case.year,
		"experiences": experiences,
		"detail": case.detail,
		"dep": case.dep,
	}


def _find_case_by_id(case_id):
	for case in data.caselist:
		if case.id == case_id:
			ent = Linq(data.enterpriselist).find(lambda e: e.id == case.enterprise)
			if ent is None:
				return None, None
			return case, ent
	return None, None


def query_case_display(
	enterprise_id,
	level,
	sector,
	field,
	stag1,
	stag2,
	year,
	page,
	exclude_id=0,
	reference_id=0,
):
	enterprise, matched = filter_cases(
		enterprise_id, level, sector, field, stag1, stag2, year,
	)
	if enterprise_id != 0 and enterprise is None:
		return None

	cases = [item[0] for item in matched]
	ent_map = {item[0].id: item[1] for item in matched}

	primary = None
	if page == 1 and exclude_id == 0:
		primary = pick_primary_case(cases)

	reference = None
	if reference_id != 0:
		ref_case, _ = _find_case_by_id(reference_id)
		reference = ref_case
	elif primary is not None:
		reference = primary

	exclude_ids = set()
	if primary is not None:
		exclude_ids.add(primary.id)
	if exclude_id != 0:
		exclude_ids.add(exclude_id)

	similar_raw = [c for c in cases if c.id not in exclude_ids]
	similar_sorted = sort_similar_cases(similar_raw, reference)
	similar_total = len(similar_sorted)

	start = (page - 1) * const.page_size
	end = page * const.page_size
	page_items = similar_sorted[start:end]

	primary_dict = None
	if primary is not None:
		ent = ent_map.get(primary.id)
		if ent is not None:
			primary_dict = serialize_case(primary, ent)

	similarlist = []
	for case in page_items:
		ent = ent_map.get(case.id)
		if ent is not None:
			similarlist.append(serialize_case(case, ent))

	return {
		"primary": primary_dict,
		"similarlist": similarlist,
		"similar_total": similar_total,
		"pagesize": const.page_size,
	}


def query_case_detail(case_id):
	case, ent = _find_case_by_id(case_id)
	if case is None or ent is None:
		return None

	case_dict = serialize_case(case, ent)

	display = query_case_display(
		case.enterprise, 0, 0, 0, 0, 0, 0,
		1, case.id, case.id,
	)
	similarlist = display["similarlist"] if display else []
	similar_total = display["similar_total"] if display else 0

	if similar_total == 0 and case.field:
		fallback = query_case_display(
			0, 0, 0, case.field, 0, 0, 0,
			1, case.id, case.id,
		)
		if fallback:
			similarlist = fallback["similarlist"]
			similar_total = fallback["similar_total"]

	return {
		"case": case_dict,
		"similarlist": similarlist,
		"similar_total": similar_total,
		"pagesize": const.page_size,
	}
