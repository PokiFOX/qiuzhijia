<template>
	<view class="report-page">
		<view class="test-bg" />

		<view class="page-nav" :style="navBarStyle">
			<view class="nav-side nav-side-left">
				<view class="nav-back" :style="navSideStyle" @tap="onBack">
					<text class="nav-back-icon">‹</text>
				</view>
			</view>
			<text class="nav-title" :style="navTitleStyle">DBTI职业性格测试</text>
			<view class="nav-side nav-side-right"></view>
		</view>

		<view class="report-content" :style="contentPadStyle">
			<view class="report-complete-card">
				<image
					class="report-complete-illustration"
					:src="parseimage('DBTI/报告生成.png')"
					mode="widthFix"
				/>
				<text class="report-complete-title">测试完成，你的职业报告已经生成</text>
				<text class="report-complete-desc">
					报告包含：职业性格类型、四维比例、具体岗位推荐、求职准备建议
				</text>

				<input
					class="report-phone-input"
					type="number"
					maxlength="11"
					:value="reportPhone"
					placeholder="请输入手机号"
					placeholder-class="report-phone-placeholder"
					@input="onPhoneInput"
				/>

				<view class="report-agree-row" @tap="toggleReportAgree">
					<view class="report-agree-check" :class="{ 'report-agree-check-on': reportAgreed }">
						<view v-if="reportAgreed" class="report-agree-check-dot" />
					</view>
					<text class="report-agree-text">
						我已阅读并同意手机号仅用于解锁本次报告，以及在我主动预约后由求职顾问联系。
					</text>
				</view>

				<view class="report-unlock-btn" @tap="onUnlockReport">
					<text class="report-unlock-btn-text">解锁完整报告</text>
				</view>

				<text class="report-skip-text" @tap="onSkipReport">暂不提供</text>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { onShow } from "@dcloudio/uni-app";

import { parseimage, getWechatNavMetrics } from "../../../tapah/function";
import { mbtiQuestions } from "../../../tapah/data";
import { RequestQueryMbti } from "../../../tapah/request";
import { computeMbtiResult, type Choice } from "./mbtiScore";

const DBTI_STORAGE_KEY = "dbti_test_progress";
const DBTI_RESULT_SNAPSHOT_KEY = "dbti_result_snapshot";
const DBTI_RESULT_URL = "/pages/lanmu/dbti/result";

const DBTI_REPORT_PHONE_KEY = "dbti_report_phone";
const DBTI_REPORT_AGREED_KEY = "dbti_report_agreed";

const reportPhone = ref("");
const reportAgreed = ref(false);

const metrics = computed(() => getWechatNavMetrics());

const navBarStyle = computed(() => ({
	height: `${metrics.value.navBarHeight}px`,
	paddingTop: `${metrics.value.statusBarHeight}px`,
	paddingLeft: `${metrics.value.paddingHorizontal}px`,
	paddingRight: `${metrics.value.paddingHorizontal}px`,
	boxSizing: "border-box" as const,
}));

const navSideStyle = computed(() => {
	const capsuleTopOffset = metrics.value.capsuleTop - metrics.value.statusBarHeight;
	return {
		height: `${metrics.value.capsuleHeight}px`,
		marginTop: `${capsuleTopOffset}px`,
	};
});

const navTitleStyle = computed(() => {
	const capsuleTopOffset = metrics.value.capsuleTop - metrics.value.statusBarHeight;
	return {
		height: `${metrics.value.capsuleHeight}px`,
		lineHeight: `${metrics.value.capsuleHeight}px`,
		marginTop: `${capsuleTopOffset}px`,
	};
});

/** 与 test 页一致：navBarHeight 已含状态栏 */
const contentPadStyle = computed(() => ({
	paddingTop: `${metrics.value.navBarHeight}px`,
}));

function persistReportPrefs() {
	try {
		uni.setStorageSync(DBTI_REPORT_PHONE_KEY, reportPhone.value);
		uni.setStorageSync(DBTI_REPORT_AGREED_KEY, reportAgreed.value ? "1" : "0");
	} catch (e) {
		console.error("dbti report prefs persist failed", e);
	}
}

function loadReportPrefs() {
	try {
		const phone = uni.getStorageSync(DBTI_REPORT_PHONE_KEY);
		if (phone != null && phone !== "") reportPhone.value = String(phone);
		const agreed = uni.getStorageSync(DBTI_REPORT_AGREED_KEY);
		reportAgreed.value = agreed === "1" || agreed === true;
	} catch (e) {
		console.error("dbti report prefs load failed", e);
	}
}

function onPhoneInput(e: UniApp.InputEvent) {
	const v = e.detail?.value ?? "";
	reportPhone.value = String(v).replace(/\D/g, "").slice(0, 11);
	persistReportPrefs();
}

function toggleReportAgree() {
	reportAgreed.value = !reportAgreed.value;
	persistReportPrefs();
}

async function onUnlockReport() {
	const phone = reportPhone.value.trim();
	if (!/^1[3-9]\d{9}$/.test(phone)) {
		uni.showToast({ title: "请输入11位手机号", icon: "none" });
		return;
	}
	if (!reportAgreed.value) {
		uni.showToast({ title: "请先阅读并勾选同意", icon: "none" });
		return;
	}
	persistReportPrefs();
	try {
		if (mbtiQuestions.value.length === 0) {
			await RequestQueryMbti();
		}
		const raw = uni.getStorageSync(DBTI_STORAGE_KEY);
		if (!raw) {
			uni.showToast({ title: "未找到答题记录", icon: "none" });
			return;
		}
		const parsed = JSON.parse(String(raw)) as { answers?: Choice[] };
		const ans = Array.isArray(parsed.answers) ? parsed.answers : [];
		const comp = computeMbtiResult(mbtiQuestions.value, ans);
		if (!comp) {
			uni.showToast({ title: "答题未完成", icon: "none" });
			return;
		}
		uni.setStorageSync(
			DBTI_RESULT_SNAPSHOT_KEY,
			JSON.stringify({
				typeCode: comp.typeCode,
				pcts: comp.pcts,
				counts: comp.counts,
			}),
		);
	} catch (e) {
		console.error(e);
		uni.showToast({ title: "加载失败", icon: "none" });
		return;
	}
	uni.navigateTo({ url: DBTI_RESULT_URL });
}

function onSkipReport() {
	uni.navigateBack();
}

const onBack = () => {
	uni.navigateBack();
};

onShow(() => {
	loadReportPrefs();
});
</script>

<style scoped>
.report-page {
	position: relative;
	width: 100vw;
	min-height: 100vh;
	box-sizing: border-box;
	background-color: #ffffff;
}

.test-bg {
	position: absolute;
	left: 0;
	top: 0;
	width: 100%;
	height: 100%;
	z-index: 0;
	pointer-events: none;
	background: linear-gradient(
		180deg,
		rgba(45, 123, 255, 0.6) 0%,
		rgba(45, 123, 255, 0.4) 20%,
		rgba(45, 123, 255, 0.29) 40%,
		rgba(45, 123, 255, 0.03) 60%,
		rgba(45, 123, 255, 0.03) 80%,
		rgba(45, 123, 255, 0.15) 100%
	);
}

.page-nav {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	z-index: 2;
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	justify-content: space-between;
	box-sizing: border-box;
	background-color: transparent;
}

.nav-side {
	display: flex;
	align-items: center;
	min-width: 64rpx;
}

.nav-back-icon {
	font-size: 48rpx;
	line-height: 1;
	color: #000000;
}

.nav-title {
	flex: 1;
	text-align: center;
	font-size: 34rpx;
	font-weight: 500;
	color: #000000;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.report-content {
	position: relative;
	z-index: 1;
	box-sizing: border-box;
	min-height: 100vh;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	padding-left: 24rpx;
	padding-right: 24rpx;
	padding-bottom: 48rpx;
}

/* 设计稿尺寸已 ×2 为 rpx */
.report-complete-card {
	width: 654rpx;
	max-width: 100%;
	box-sizing: border-box;
	padding: 20rpx 40rpx 40rpx;
	background-color: #ffffff;
	border-radius: 50rpx;
	box-shadow: 0 20rpx 60rpx rgba(45, 123, 255, 0.2);
	display: flex;
	flex-direction: column;
	align-items: center;
}

.report-complete-illustration {
	width: 574rpx;
	margin-top: 0;
}

.report-complete-title {
	margin-top: 20rpx;
	width: 100%;
	text-align: center;
	font-size: 36rpx;
	line-height: 52rpx;
	font-weight: 500;
	color: #000000;
}

.report-complete-desc {
	margin-top: 22rpx;
	width: 100%;
	text-align: center;
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 400;
	color: #8f8e95;
}

.report-phone-input {
	width: 574rpx;
	height: 76rpx;
	margin-top: 50rpx;
	padding: 0 24rpx;
	box-sizing: border-box;
	background-color: #ffffff;
	border: 2rpx solid #d7d7d7;
	border-radius: 20rpx;
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #000000;
}

.report-phone-placeholder {
	color: #8f8e95;
	font-size: 28rpx;
	line-height: 40rpx;
}

.report-agree-row {
	width: 574rpx;
	margin-top: 26rpx;
	display: flex;
	flex-direction: row;
	align-items: flex-start;
}

.report-agree-check {
	width: 20rpx;
	height: 20rpx;
	margin-top: 6rpx;
	flex-shrink: 0;
	box-sizing: border-box;
	border: 2rpx solid #8f8e95;
	border-radius: 50%;
	background-color: #ffffff;
	display: flex;
	align-items: center;
	justify-content: center;
}

.report-agree-check-on {
	border-color: #8f8e95;
}

.report-agree-check-dot {
	width: 12rpx;
	height: 12rpx;
	border-radius: 50%;
	background-color: #2d7bff;
}

.report-agree-text {
	margin-left: 4rpx;
	flex: 1;
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 400;
	color: #8f8e95;
}

.report-unlock-btn {
	width: 574rpx;
	height: 90rpx;
	margin-top: 32rpx;
	border-radius: 20rpx;
	background-color: #2d7bff;
	box-shadow: 0 16rpx 48rpx rgba(45, 123, 255, 0.3);
	display: flex;
	align-items: center;
	justify-content: center;
}

.report-unlock-btn-text {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 700;
	color: #ffffff;
}

.report-skip-text {
	margin-top: 16rpx;
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 400;
	color: #838388;
}
</style>
