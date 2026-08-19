import type { InternshipExperience } from "./caseExperience";
import { experienceCount } from "./caseExperience";

export function internshipCount(
	detail?: string,
	experiences?: InternshipExperience[],
): number {
	return experienceCount(detail, experiences);
}

export function formatInternship(
	detail?: string,
	experiences?: InternshipExperience[],
): string {
	const n = internshipCount(detail, experiences);
	return n > 0 ? `${n}段实习经历` : "--";
}
