export interface InternshipExperience {
	enterpriseId?: number;
	enterpriseName: string;
	department: string;
	position: string;
	deptRole: string;
	company: string;
}

function buildDeptRole(department: string, position: string): string {
	const parts = [department, position].filter((s) => s.trim().length > 0);
	return parts.join("·");
}

function fromStructuredItem(item: Record<string, unknown>): InternshipExperience | null {
	const enterpriseName = String(item.enterpriseName ?? item.company ?? "").trim();
	const department = String(item.department ?? "").trim();
	const position = String(item.position ?? "").trim();
	const enterpriseId =
		item.enterpriseId != null ? Number(item.enterpriseId) : undefined;
	const deptRole =
		String(item.deptRole ?? "").trim() || buildDeptRole(department, position);

	if (!enterpriseName && !deptRole) return null;

	return {
		enterpriseId: Number.isFinite(enterpriseId) ? enterpriseId : undefined,
		enterpriseName,
		department,
		position,
		deptRole,
		company: enterpriseName,
	};
}

function parseJsonExperiences(detail: string): InternshipExperience[] | null {
	try {
		const parsed = JSON.parse(detail);
		if (!Array.isArray(parsed)) return null;
		return parsed
			.map((item) => fromStructuredItem(item as Record<string, unknown>))
			.filter((item): item is InternshipExperience => item != null);
	} catch {
		return null;
	}
}

function parsePipeExperiences(detail: string): InternshipExperience[] {
	const result: InternshipExperience[] = [];
	for (const segment of detail.split(",")) {
		const parts = segment
			.split("|")
			.map((s) => s.trim())
			.filter((s) => s.length > 0);
		if (parts.length !== 3) continue;
		const [enterpriseName, department, position] = parts;
		result.push({
			enterpriseName,
			department,
			position,
			deptRole: buildDeptRole(department, position),
			company: enterpriseName,
		});
	}
	return result;
}

function isDeptRole(text: string): boolean {
	return text.includes("·") || text.includes("/");
}

function parseLegacyExperiences(detail: string): InternshipExperience[] {
	const segments = detail
		.split(",")
		.map((s) => s.trim())
		.filter((s) => s.length > 0);

	if (segments.length === 0) return [];

	const result: InternshipExperience[] = [];

	if (segments.length === 1) {
		const only = segments[0];
		if (isDeptRole(only)) {
			result.push({
				enterpriseName: "",
				department: "",
				position: "",
				deptRole: only,
				company: "",
			});
		} else {
			result.push({
				enterpriseName: only,
				department: "",
				position: "",
				deptRole: "",
				company: only,
			});
		}
		return result;
	}

	for (let i = 0; i < segments.length; i += 2) {
		const company = segments[i] ?? "";
		const deptRole = segments[i + 1] ?? "";
		if (company || deptRole) {
			result.push({
				enterpriseName: company,
				department: "",
				position: "",
				deptRole,
				company,
			});
		}
	}

	return result;
}

export function parseInternshipExperiences(
	detail?: string,
	experiences?: InternshipExperience[],
): InternshipExperience[] {
	if (experiences && experiences.length > 0) {
		return experiences.map((exp) => ({
			...exp,
			company: exp.enterpriseName || exp.company || "",
			deptRole: exp.deptRole || buildDeptRole(exp.department, exp.position),
		}));
	}

	if (!detail?.trim()) return [];

	const trimmed = detail.trim();
	if (trimmed.startsWith("[")) {
		const parsed = parseJsonExperiences(trimmed);
		if (parsed) return parsed;
	}

	if (trimmed.includes("|")) {
		const parsed = parsePipeExperiences(trimmed);
		if (parsed.length > 0) return parsed;
	}

	return parseLegacyExperiences(trimmed);
}

export function experienceCount(
	detail?: string,
	experiences?: InternshipExperience[],
): number {
	return parseInternshipExperiences(detail, experiences).length;
}
