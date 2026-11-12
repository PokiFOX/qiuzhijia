export const DBTI_STORAGE_KEY = "dbti_test_progress";
export const DBTI_COMPLETED_KEY = "dbti_test_completed";
export const DBTI_RESULT_SNAPSHOT_KEY = "dbti_result_snapshot";
export const DBTI_REPORT_UNLOCK_URL = "/pages/lanmu/dbti/report-unlock";

/** 本地已标记完成且答题记录齐全（不依赖题库接口是否已返回） */
export function isDbtiTestCompletedInStorage(): boolean {
	try {
		const completed =
			uni.getStorageSync(DBTI_COMPLETED_KEY) === "1" ||
			uni.getStorageSync(DBTI_COMPLETED_KEY) === true;
		if (!completed) return false;
		const raw = uni.getStorageSync(DBTI_STORAGE_KEY);
		if (!raw) return false;
		const parsed = JSON.parse(String(raw)) as { answers?: unknown[] };
		const answers = Array.isArray(parsed.answers) ? parsed.answers : [];
		if (answers.length === 0) return false;
		return answers.every((a) => a === "A" || a === "B");
	} catch {
		return false;
	}
}
