export const DBTI_STORAGE_KEY = "dbti_test_progress";
export const DBTI_COMPLETED_KEY = "dbti_test_completed";
export const DBTI_RESULT_SNAPSHOT_KEY = "dbti_result_snapshot";
export const DBTI_REPORT_PHONE_KEY = "dbti_report_phone";
export const DBTI_REPORT_AGREED_KEY = "dbti_report_agreed";
export const DBTI_REPORT_UNLOCK_URL = "/pages/lanmu/dbti/report-unlock";
export const DBTI_RESULT_URL = "/pages/lanmu/dbti/result";

/** 清除答题进度与结果，用于「重新开始测试」 */
export function clearDbtiTestStorage(): void {
	const keys = [
		DBTI_STORAGE_KEY,
		DBTI_COMPLETED_KEY,
		DBTI_RESULT_SNAPSHOT_KEY,
		DBTI_REPORT_PHONE_KEY,
		DBTI_REPORT_AGREED_KEY,
	];
	for (const k of keys) {
		try {
			uni.removeStorageSync(k);
		} catch (e) {
			console.error("clearDbtiTestStorage", k, e);
		}
	}
}

/** 已保存合法手机号（与解锁页校验一致） */
export function hasDbtiReportPhoneInStorage(): boolean {
	try {
		const phone = String(uni.getStorageSync(DBTI_REPORT_PHONE_KEY) ?? "").trim();
		return /^1[3-9]\d{9}$/.test(phone);
	} catch {
		return false;
	}
}

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
