export function internshipCount(detail?: string): number {
	if (!detail?.trim()) return 0;
	return detail
		.split(",")
		.map((s) => s.trim())
		.filter((s) => s.length > 0).length;
}

export function formatInternship(detail?: string): string {
	const n = internshipCount(detail);
	return n > 0 ? `${n}段实习经历` : "--";
}
