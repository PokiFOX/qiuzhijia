import type { MbtiQuestion } from "../../../tapah/class";

export type Choice = "A" | "B" | null;

export interface MbtiDimensionPcts {
	e: number;
	i: number;
	s: number;
	n: number;
	t: number;
	f: number;
	j: number;
	p: number;
}

/**
 * PRD：E%=round(E/7×100)，I%=100−E%；平局取每对第一个字母 E、S、T、J
 */
export function computeMbtiResult(
	questions: MbtiQuestion[],
	answers: Choice[],
): { typeCode: string; counts: Record<string, number>; pcts: MbtiDimensionPcts } | null {
	const n = questions.length;
	if (n === 0) return null;
	const counts: Record<string, number> = {
		E: 0,
		I: 0,
		S: 0,
		N: 0,
		T: 0,
		F: 0,
		J: 0,
		P: 0,
	};
	for (let i = 0; i < n; i++) {
		const q = questions[i];
		const a = answers[i];
		if (a !== "A" && a !== "B") return null;
		const dim = a === "A" ? q.dimensionA : q.dimensionB;
		if (counts[dim] === undefined) continue;
		counts[dim]++;
	}
	const pairPct = (a: string, b: string): [number, number] => {
		const ca = counts[a] ?? 0;
		const cb = counts[b] ?? 0;
		const total = ca + cb;
		if (total <= 0) return [50, 50];
		const first = Math.round((ca / total) * 100);
		return [first, 100 - first];
	};
	const [ePct, iPct] = pairPct("E", "I");
	const [sPct, nPct] = pairPct("S", "N");
	const [tPct, fPct] = pairPct("T", "F");
	const [jPct, pPct] = pairPct("J", "P");

	const pick = (x: string, y: string) => ((counts[x] ?? 0) >= (counts[y] ?? 0) ? x : y);
	const typeCode = `${pick("E", "I")}${pick("S", "N")}${pick("T", "F")}${pick("J", "P")}`;

	return {
		typeCode: typeCode.toUpperCase(),
		counts,
		pcts: {
			e: ePct,
			i: iPct,
			s: sPct,
			n: nPct,
			t: tPct,
			f: fPct,
			j: jPct,
			p: pPct,
		},
	};
}
