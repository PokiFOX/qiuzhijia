<template>
	<view class="result-page">
		<view class="test-bg" />
		<view class="page-nav" :style="navBarStyle">
			<view class="nav-side nav-side-left">
				<view class="nav-back" :style="navSideStyle" @tap="onBack">
					<text class="nav-back-icon">‹</text>
				</view>
			</view>
			<text class="nav-title" :style="navTitleStyle">DBTI职业性格测试</text>
			<view class="nav-side nav-side-right" />
		</view>

		<scroll-view class="result-scroll" scroll-y :show-scrollbar="false" :style="scrollStyle">
			<view v-if="!resolved" class="result-loading">
				<text class="result-loading-text">加载中…</text>
			</view>

			<template v-else>
				<!-- 主卡：类型 + 简介 + 四维 -->
				<view class="hero-wrap">
					<view class="hero-card">
						<text class="hero-title-line">
							<text class="hero-title-you">你是</text>
							<text class="hero-title-accent">{{ resultRow?.title ?? "" }}</text>
						</text>
						<text class="hero-intro">{{ resultRow?.personalityIntro ?? "" }}</text>
						<image
							class="hero-banner-img"
							:src="parseDbtiResultHero(typeCode, resultRow?.title ?? '')"
							mode="widthFix"
						/>

						<view class="section-head-row">
							<view class="section-blue-bar" />
							<text class="section-head-text">四维偏好</text>
						</view>

						<view v-for="dim in dimensionRows" :key="dim.key" class="dim-block">
							<view class="dim-label-row">
								<text class="dim-label-left">{{ dim.leftLabel }}</text>
								<text class="dim-label-right">{{ dim.rightLabel }}</text>
							</view>
							<view
								class="dim-bar-track"
								:style="{
									background: `linear-gradient(90deg, #2D7BFF 0%, #2D7BFF ${dim.leftPct}%, #FDE063 ${dim.leftPct}%, #FDE063 100%)`,
								}"
							/>
							<view class="dim-pct-row">
								<text class="dim-pct">{{ dim.leftPct }}%</text>
								<text class="dim-pct dim-pct-r">{{ dim.rightPct }}%</text>
							</view>
							<view v-if="dim.key !== 'jp'" class="dim-gap" />
						</view>
					</view>
				</view>

				<!-- 匹配岗位 -->
				<view class="jobs-panel">
					<text class="jobs-panel-title">匹配职位建议</text>
					<view
						v-for="(name, ji) in jobNames"
						:key="name + ji"
						class="job-card"
					>
						<view class="job-card-inner">
							<view class="job-head-row">
								<image
									class="job-avatar"
									:src="parseDbtiJobAvatar(name)"
									mode="aspectFill"
								/>
								<view class="job-head-texts">
									<text class="job-name">{{ name }}</text>
									<text class="job-summary">{{ jobMeta(name)?.summary ?? "" }}</text>
								</view>
							</view>
							<view class="job-dash" />
							<text class="job-content">{{ jobMeta(name)?.content ?? "" }}</text>
						</view>
					</view>
				</view>

				<!-- 求职准备建议 -->
				<view class="advice-panel">
					<view class="advice-panel-head">
						<view class="section-blue-bar" />
						<text class="section-head-text">求职准备建议</text>
					</view>

					<view class="advice-subcard">
						<view class="advice-block">
							<view class="advice-block-title-row">
								<image
									class="advice-block-icon"
									:src="parseimage('DBTI/业务知识.png')"
									mode="aspectFit"
								/>
								<text class="advice-block-title">业务知识</text>
							</view>
							<template v-for="(item, idx) in bizSlice" :key="'biz' + idx">
								<view class="advice-pill-row">
									<view class="advice-pill">{{ item.topic }}</view>
									<text class="advice-pill-desc">{{ item.content }}</text>
								</view>
								<view v-if="idx < bizSlice.length - 1" class="advice-inner-dash" />
								<view v-else class="advice-block-gap" />
							</template>
							<view class="advice-section-dash" />
						</view>

						<view class="advice-block advice-block-gap-before">
							<view class="advice-block-title-row">
								<image
									class="advice-block-icon"
									:src="parseimage('DBTI/建议积累.png')"
									mode="aspectFit"
								/>
								<text class="advice-block-title">建议积累的经历</text>
							</view>
							<template v-for="(item, idx) in (resultRow?.experienceSuggestions ?? []).slice(0, 3)" :key="'exp' + idx">
								<view class="advice-pill-row">
									<view class="advice-pill advice-pill-exp">{{ item.topic }}</view>
									<text class="advice-pill-desc">{{ item.content }}</text>
								</view>
								<view v-if="idx < Math.min(3, (resultRow?.experienceSuggestions ?? []).length) - 1" class="advice-inner-dash" />
								<view v-else class="advice-block-gap" />
							</template>
							<view class="advice-section-dash" />
						</view>

						<view class="advice-block advice-block-gap-before">
							<view class="advice-block-title-row">
								<image
									class="advice-block-icon"
									:src="parseimage('DBTI/准备方向.png')"
									mode="aspectFit"
								/>
								<text class="advice-block-title">笔面试准备的方向</text>
							</view>
							<template v-for="(item, idx) in (resultRow?.interviewPrep ?? []).slice(0, 3)" :key="'prep' + idx">
								<view class="advice-pill-row">
									<view class="advice-pill advice-pill-prep">{{ item.topic }}</view>
									<text class="advice-pill-desc">{{ item.content }}</text>
								</view>
								<view
									v-if="idx < Math.min(3, (resultRow?.interviewPrep ?? []).length) - 1"
									class="advice-inner-dash"
								/>
							</template>
						</view>
					</view>
				</view>

				<!-- 底部操作 -->
				<view class="footer-actions">
					<button class="btn-primary-full" @tap="onAppointment">预约求职方向诊断</button>
					<view class="btn-row-half">
						<button class="btn-outline-half" open-type="share">分享测试结果</button>
						<button class="btn-outline-half" @tap="onDownload">下载测试结果</button>
					</view>
					<text class="footer-disclaimer">
						本结果用于职业探索，不代表招聘录用结论。岗位选择还需结合专业、学历、经历、技能和个人目标综合判断。
					</text>
				</view>
			</template>
		</scroll-view>

		<!-- 预约求职方向诊断 -->
		<view v-if="showAppointmentModal" class="appt-mask" @tap="closeAppointmentModal">
			<view class="appt-modal-stack" @tap.stop>
				<view class="appt-card">
				<view class="appt-head-row">
					<view class="appt-blue-bar" />
					<text class="appt-head-title">预约求职方向诊断</text>
				</view>
				<text class="appt-subtitle">请填写以下信息，顾问将优先联系你</text>

				<view class="appt-section">
					<text class="appt-section-label">目标方向</text>
					<view class="appt-chip-grid">
						<view
							v-for="t in appointmentTargetOptions"
							:key="t"
							class="appt-chip"
							:class="{ 'appt-chip-on': appointmentTarget === t }"
							@tap="appointmentTarget = t"
						>
							<text class="appt-chip-text">{{ t }}</text>
						</view>
					</view>
				</view>

				<view class="appt-section appt-section-gap">
					<text class="appt-section-label">当前阶段</text>
					<view class="appt-chip-grid appt-chip-grid-3">
						<view
							v-for="t in appointmentStageOptions"
							:key="t"
							class="appt-chip"
							:class="{ 'appt-chip-on': appointmentStage === t }"
							@tap="appointmentStage = t"
						>
							<text class="appt-chip-text">{{ t }}</text>
						</view>
					</view>
				</view>

				<view class="appt-section appt-section-gap">
					<text class="appt-section-label">当前困难</text>
					<view class="appt-chip-grid">
						<view
							v-for="t in appointmentDifficultyOptions"
							:key="t"
							class="appt-chip"
							:class="{ 'appt-chip-on': difficultySelected(t) }"
							@tap="toggleDifficulty(t)"
						>
							<text class="appt-chip-text">{{ t }}</text>
						</view>
					</view>
				</view>

				<view class="appt-section appt-section-gap">
					<text class="appt-section-label">方便联系的时间</text>
					<view class="appt-chip-grid appt-chip-grid-2">
						<view
							v-for="t in appointmentTimeOptions"
							:key="t"
							class="appt-chip"
							:class="{ 'appt-chip-on': appointmentTime === t }"
							@tap="appointmentTime = t"
						>
							<text class="appt-chip-text">{{ t }}</text>
						</view>
					</view>
				</view>

				<button class="appt-submit" @tap="submitAppointment">预约</button>
				</view>
				<view class="appt-cancel" @tap="closeAppointmentModal">
					<text class="appt-cancel-text">暂不预约，返回结果</text>
				</view>
			</view>
		</view>

		<!-- 预约提交成功（底部抽屉） -->
		<view v-if="showAppointmentSuccess" class="appt-success-mask" @tap="closeAppointmentSuccess">
			<view class="appt-success-sheet" @tap.stop>
				<image
					class="appt-success-icon"
					:src="parseimage('底部按钮/打钩.png')"
					mode="aspectFit"
				/>
				<text class="appt-success-title">预约信息已提交</text>
				<text class="appt-success-sub">顾问会优先联系主动预约用户，请留意电话或微信消息</text>

				<view class="appt-success-table">
					<view
						v-for="(row, ri) in appointmentSuccessRows"
						:key="ri"
						class="appt-success-row"
					>
						<text class="appt-success-label">{{ row.label }}</text>
						<text class="appt-success-value">{{ row.value }}</text>
					</view>
				</view>

				<button class="appt-success-btn" @tap="closeAppointmentSuccess">返回结果页</button>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import { onLoad, onShareAppMessage } from "@dcloudio/uni-app";

import { mbtiJobs, mbtiQuestions, mbtiResults } from "../../../tapah/data";
import { parseimage, parseDbtiJobAvatar, parseDbtiResultHero, getWechatNavMetrics } from "../../../tapah/function";
import { RequestQueryMbti, RequestSubmitDbtiAppointment } from "../../../tapah/request";
import type { MbtiJob, MbtiResult } from "../../../tapah/class";

import { computeMbtiResult, type Choice } from "./mbtiScore";
import { DBTI_REPORT_PHONE_KEY } from "./dbtiStorage";

const DBTI_STORAGE_KEY = "dbti_test_progress";
const SNAPSHOT_KEY = "dbti_result_snapshot";

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

const scrollStyle = computed(() => ({
	paddingTop: `${metrics.value.navBarHeight}px`,
	height: "100vh",
	boxSizing: "border-box" as const,
}));

const resolved = ref(false);
const typeCode = ref("");
const pcts = ref({ e: 50, i: 50, s: 50, n: 50, t: 50, f: 50, j: 50, p: 50 });

function normalizeMbtiType(s: string): string {
	return String(s || "")
		.replace(/\s+/g, "")
		.toUpperCase();
}

const resultRow = computed<MbtiResult | null>(() => {
	const t = normalizeMbtiType(typeCode.value);
	if (!t) return null;
	return (
		mbtiResults.value.find((r) => normalizeMbtiType(r.type) === t) ?? null
	);
});

const jobNames = computed(() => resultRow.value?.jobs ?? []);

function jobMeta(name: string): MbtiJob | undefined {
	return mbtiJobs.value.find((j) => j.name === name);
}

/** 配置里业务知识最多 4 条（Excel G–N） */
const bizSlice = computed(() => (resultRow.value?.businessKnowledge ?? []).slice(0, 4));

const dimensionRows = computed(() => {
	const p = pcts.value;
	return [
		{
			key: "ei",
			leftLabel: "E 外向",
			rightLabel: "I 内向",
			leftPct: p.e,
			rightPct: p.i,
		},
		{
			key: "sn",
			leftLabel: "S 感觉",
			rightLabel: "N 直觉",
			leftPct: p.s,
			rightPct: p.n,
		},
		{
			key: "tf",
			leftLabel: "T 思考",
			rightLabel: "F 情感",
			leftPct: p.t,
			rightPct: p.f,
		},
		{
			key: "jp",
			leftLabel: "J 判断",
			rightLabel: "P 感知",
			leftPct: p.j,
			rightPct: p.p,
		},
	];
});

function loadSnapshot(): boolean {
	try {
		const raw = uni.getStorageSync(SNAPSHOT_KEY);
		if (!raw) return false;
		const o = JSON.parse(String(raw)) as { typeCode?: string; pcts?: typeof pcts.value };
		if (!o.typeCode || !o.pcts) return false;
		typeCode.value = normalizeMbtiType(String(o.typeCode));
		pcts.value = { ...pcts.value, ...o.pcts };
		return true;
	} catch {
		return false;
	}
}

async function ensureConfig() {
	try {
		await RequestQueryMbti();
	} catch (e) {
		console.error(e);
	}
}

/** 从答题进度现场计算（快照缺失时） */
function tryComputeFromProgress(): boolean {
	try {
		const raw = uni.getStorageSync(DBTI_STORAGE_KEY);
		if (!raw) return false;
		const parsed = JSON.parse(String(raw)) as {
			answers?: Choice[];
		};
		if (!parsed.answers || !Array.isArray(parsed.answers)) return false;
		const qs = mbtiQuestions.value;
		if (!qs?.length) return false;
		const comp = computeMbtiResult(qs, parsed.answers);
		if (!comp) return false;
		typeCode.value = normalizeMbtiType(comp.typeCode);
		pcts.value = comp.pcts;
		uni.setStorageSync(
			SNAPSHOT_KEY,
			JSON.stringify({ typeCode: comp.typeCode, pcts: comp.pcts, counts: comp.counts }),
		);
		return true;
	} catch {
		return false;
	}
}

onShareAppMessage(() => {
	const r = resultRow.value;
	const t = typeCode.value;
	const jobs = (r?.jobs ?? []).join("、");
	const title = r ? `我的 DBTI：${t}（${r.title}）推荐：${jobs}` : "我的 DBTI 测试结果";
	return {
		title,
		path: "/pages/lanmu/dbti/dbti",
	};
});

const showAppointmentModal = ref(false);
const showAppointmentSuccess = ref(false);

interface AppointmentSuccessRow {
	label: string;
	value: string;
}

const appointmentSuccessRows = ref<AppointmentSuccessRow[]>([]);

function maskPhone(p: string): string {
	const d = String(p || "").replace(/\D/g, "");
	if (d.length === 11) return `${d.slice(0, 3)}****${d.slice(7)}`;
	if (!d) return "—";
	return p || "—";
}

function closeAppointmentSuccess() {
	showAppointmentSuccess.value = false;
}

/** 与 PRD 3.6 一致；设计稿 ×2 → rpx */
const appointmentTargetOptions = ["央企国企", "银行", "券商投行", "基金资管", "暂不确定"] as const;
const appointmentStageOptions = ["本科在读", "研究生在读", "已毕业"] as const;
const appointmentDifficultyOptions = ["选定岗位", "简历实习", "网申投递", "笔试", "面试", "整体规划"] as const;
const appointmentTimeOptions = ["工作日白天", "工作日晚上", "周末", "均可"] as const;

const appointmentTarget = ref<string>("");
const appointmentStage = ref<string>("");
const appointmentDifficulties = ref<string[]>([]);
const appointmentTime = ref<string>("");

function onAppointment() {
	showAppointmentModal.value = true;
}

function closeAppointmentModal() {
	showAppointmentModal.value = false;
}

function difficultySelected(t: string): boolean {
	return appointmentDifficulties.value.includes(t);
}

function toggleDifficulty(t: string) {
	const arr = [...appointmentDifficulties.value];
	const i = arr.indexOf(t);
	if (i >= 0) arr.splice(i, 1);
	else arr.push(t);
	appointmentDifficulties.value = arr;
}

async function submitAppointment() {
	if (!appointmentTarget.value) {
		uni.showToast({ title: "请选择目标方向", icon: "none" });
		return;
	}
	if (!appointmentStage.value) {
		uni.showToast({ title: "请选择当前阶段", icon: "none" });
		return;
	}
	if (appointmentDifficulties.value.length === 0) {
		uni.showToast({ title: "请选择当前困难", icon: "none" });
		return;
	}
	if (!appointmentTime.value) {
		uni.showToast({ title: "请选择方便联系的时间", icon: "none" });
		return;
	}
	let phoneRaw = "";
	try {
		phoneRaw = String(uni.getStorageSync(DBTI_REPORT_PHONE_KEY) ?? "");
	} catch {
		phoneRaw = "";
	}
	const digits = phoneRaw.replace(/\D/g, "");
	if (!/^1[3-9]\d{9}$/.test(digits)) {
		uni.showToast({ title: "请先在解锁页填写手机号", icon: "none" });
		return;
	}
	const jobs = resultRow.value?.jobs ?? [];
	try {
		await RequestSubmitDbtiAppointment({
			phone: digits,
			mbtiType: typeCode.value || "",
			recommendedJobs: jobs,
			targetDirection: appointmentTarget.value,
			currentStage: appointmentStage.value,
			difficulties: [...appointmentDifficulties.value],
			contactTime: appointmentTime.value,
			leadLevel: "high",
		});
	} catch (e) {
		const msg = e instanceof Error ? e.message : String(e);
		uni.showToast({ title: msg.length > 40 ? "提交失败，请重试" : msg, icon: "none" });
		return;
	}
	appointmentSuccessRows.value = [
		{ label: "手机号", value: maskPhone(phoneRaw) },
		{ label: "MBTI类型", value: typeCode.value || "—" },
		{ label: "推荐岗位", value: jobs.length ? jobs.join("、") : "—" },
		{ label: "目标方向", value: appointmentTarget.value },
		{ label: "当前阶段", value: appointmentStage.value },
		{ label: "当前困难", value: appointmentDifficulties.value.join("、") },
		{ label: "联系时间", value: appointmentTime.value },
	];
	closeAppointmentModal();
	showAppointmentSuccess.value = true;
}

function onDownload() {
	uni.showToast({ title: "可长按保存或截图", icon: "none" });
}

const onBack = () => {
	uni.navigateBack();
};

onLoad(async () => {
	await ensureConfig();
	if (!loadSnapshot()) {
		tryComputeFromProgress();
	}
	if (!typeCode.value) {
		uni.showToast({ title: "暂无测试结果", icon: "none" });
		setTimeout(() => uni.navigateBack(), 1500);
		return;
	}
	if (!resultRow.value) {
		uni.showToast({
			title: `未找到类型「${typeCode.value}」的配置，请后台上传 MBTI.xlsx`,
			icon: "none",
			duration: 3500,
		});
	}
	resolved.value = true;
});
</script>

<style scoped>
.result-page {
	position: relative;
	width: 100vw;
	min-height: 100vh;
	background: #f5f8ff;
}

.test-bg {
	position: fixed;
	left: 0;
	top: 0;
	width: 100%;
	height: 100%;
	z-index: 0;
	pointer-events: none;
	background: linear-gradient(
		180deg,
		rgba(45, 123, 255, 0.35) 0%,
		rgba(45, 123, 255, 0.12) 35%,
		#f5f8ff 55%,
		#f5f8ff 100%
	);
}

.page-nav {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	z-index: 10;
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
}

.result-scroll {
	position: relative;
	z-index: 1;
	box-sizing: border-box;
}

.result-loading {
	padding: 120rpx 0;
	display: flex;
	justify-content: center;
}

.result-loading-text {
	font-size: 28rpx;
	color: #38436c;
}

/* 设计稿 ×2 */
.hero-wrap {
	padding: 0 22rpx;
	margin-top: 90rpx;
}

.hero-card {
	width: 672rpx;
	max-width: 100%;
	margin: 0 auto;
	box-sizing: border-box;
	padding: 40rpx 44rpx 36rpx;
	border-radius: 30rpx;
	border: 2rpx solid #ffffff;
	background: linear-gradient(180deg, rgba(45, 123, 255, 0.2) 0%, rgba(45, 123, 255, 0.14) 35%, rgba(45, 123, 255, 0.01) 55%, rgba(45, 123, 255, 0.01) 100%);
	box-shadow: 0 4rpx 24rpx rgba(45, 123, 255, 0.1);
}

.hero-title-line {
	display: block;
	text-align: center;
	margin-bottom: 18rpx;
	font-size: 48rpx;
	line-height: 70rpx;
	font-weight: 700;
}

.hero-title-you {
	color: #000000;
}

.hero-title-accent {
	color: #2d7bff;
}

.hero-intro {
	display: block;
	margin: 0 0 16rpx;
	padding: 0;
	font-size: 24rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #38436c;
	text-align: left;
}

.hero-banner-img {
	width: 100%;
	margin-top: 8rpx;
	margin-bottom: 24rpx;
	border-radius: 16rpx;
}

.section-head-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-top: 0;
	margin-bottom: 14rpx;
	padding-left: 0;
}

.section-blue-bar {
	width: 8rpx;
	height: 36rpx;
	background: #2d7bff;
	border-radius: 4rpx;
	margin-right: 24rpx;
	flex-shrink: 0;
}

.section-head-text {
	font-size: 40rpx;
	line-height: 58rpx;
	font-weight: 700;
	color: #000000;
}

.dim-block {
	margin-top: 0;
}

.dim-label-row {
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 10rpx;
}

.dim-label-left,
.dim-label-right {
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 500;
	color: #2a2a2a;
}

.dim-bar-track {
	height: 20rpx;
	border-radius: 20rpx;
	overflow: hidden;
}

.dim-pct-row {
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	margin-top: 4rpx;
}

.dim-pct {
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 500;
	color: #8f8e95;
}

.dim-pct-r {
	text-align: right;
}

.dim-gap {
	height: 16rpx;
}

.jobs-panel {
	width: 754rpx;
	max-width: 100%;
	margin: 50rpx auto 0;
	box-sizing: border-box;
	padding: 26rpx 22rpx 40rpx;
	background: #f2f6ff;
	box-shadow: 0 -4rpx 30rpx rgba(45, 123, 255, 0.15);
}

.jobs-panel-title {
	display: block;
	font-size: 40rpx;
	line-height: 58rpx;
	font-weight: 500;
	color: #000000;
	margin-bottom: 28rpx;
}

.job-card {
	margin-bottom: 28rpx;
}

.job-card-inner {
	width: 672rpx;
	max-width: 100%;
	margin: 0 auto;
	box-sizing: border-box;
	padding: 22rpx 44rpx 16rpx;
	border-radius: 30rpx;
	border: 2rpx solid #ffffff;
	background: #ffffff;
	box-shadow: 0 4rpx 30rpx rgba(45, 123, 255, 0.15);
}

.job-head-row {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
}

.job-avatar {
	width: 92rpx;
	height: 92rpx;
	border-radius: 50%;
	flex-shrink: 0;
	background: #e8eef8;
}

.job-head-texts {
	flex: 1;
	margin-left: 26rpx;
	display: flex;
	flex-direction: column;
}

.job-name {
	font-size: 44rpx;
	line-height: 64rpx;
	font-weight: 700;
	color: #000000;
}

.job-summary {
	margin-top: 4rpx;
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 400;
	color: #2d7bff;
}

.job-dash {
	margin: 12rpx 0;
	height: 0;
	border-top: 2rpx dashed #2d7bff;
}

.job-content {
	font-size: 24rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #454545;
}

.advice-panel {
	width: 750rpx;
	max-width: 100%;
	margin: 0 auto;
	padding: 20rpx 22rpx 0;
	box-sizing: border-box;
	background: transparent;
}

.advice-panel-head {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-bottom: 22rpx;
}

.advice-subcard {
	width: 666rpx;
	max-width: 100%;
	margin: 0 auto;
	box-sizing: border-box;
	padding: 26rpx 0 32rpx;
	border-radius: 20rpx;
	background: #ffffff;
	box-shadow: 0 0 10rpx rgba(195, 195, 195, 0.6);
}

.advice-block-title-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	padding: 0 30rpx 0;
	margin-bottom: 24rpx;
}

.advice-block-icon {
	width: 40rpx;
	height: 40rpx;
	margin-right: 22rpx;
	flex-shrink: 0;
}

.advice-block-title {
	font-size: 32rpx;
	line-height: 40rpx;
	font-weight: 500;
	color: #000000;
}

.advice-pill-row {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	padding: 0 44rpx 0 30rpx;
	flex-wrap: wrap;
}

.advice-pill {
	flex-shrink: 0;
	min-width: 136rpx;
	padding: 0 12rpx;
	height: 40rpx;
	line-height: 40rpx;
	text-align: center;
	font-size: 24rpx;
	font-weight: 500;
	color: #2d7bff;
	background: #f1f4ff;
	border-radius: 8rpx;
	margin-right: 22rpx;
}

.advice-pill-exp {
	color: #f17302;
	background: #fff0e3;
}

.advice-pill-prep {
	color: #189a3d;
	background: #e8f5eb;
}

.advice-pill-desc {
	flex: 1;
	min-width: 200rpx;
	font-size: 24rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #3d3d3d;
	padding-top: 0;
}

.advice-inner-dash {
	margin: 16rpx 44rpx 16rpx 30rpx;
	height: 0;
	border-top: 2rpx dashed #2d7bff;
}

.advice-section-dash {
	margin: 12rpx 44rpx 0;
	height: 0;
	border-top: 2rpx dashed #2d7bff;
}

.advice-block-gap {
	height: 20rpx;
}

.advice-block-gap-before {
	margin-top: 20rpx;
}

.footer-actions {
	padding: 44rpx 44rpx 60rpx;
	box-sizing: border-box;
}

.btn-primary-full {
	width: 666rpx;
	max-width: 100%;
	height: 82rpx;
	line-height: 82rpx;
	margin: 0 auto;
	border-radius: 60rpx;
	background: #2d7bff;
	color: #ffffff;
	font-size: 32rpx;
	font-weight: 700;
	box-shadow: 0 0 16rpx rgba(45, 123, 255, 0.3);
	border: none;
}

.btn-row-half {
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	width: 666rpx;
	max-width: 100%;
	margin: 30rpx auto 0;
	gap: 20rpx;
}

.btn-outline-half {
	flex: 1;
	height: 86rpx;
	line-height: 86rpx;
	border-radius: 60rpx;
	background: #ffffff;
	color: #2d7bff;
	font-size: 32rpx;
	font-weight: 400;
	border: 2rpx solid #2d7bff;
	box-shadow: 0 0 16rpx rgba(45, 123, 255, 0.3);
}

.footer-disclaimer {
	display: block;
	margin-top: 16rpx;
	padding: 0 8rpx;
	font-size: 20rpx;
	line-height: 34rpx;
	font-weight: 400;
	color: #8f8e95;
	text-align: center;
}

/* 预约弹层：327×515 ×2 */
.appt-mask {
	position: fixed;
	left: 0;
	right: 0;
	top: 0;
	bottom: 0;
	z-index: 100;
	background: rgba(0, 0, 0, 0.45);
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	box-sizing: border-box;
	padding: 32rpx;
}

.appt-modal-stack {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	max-height: 90vh;
	width: 654rpx;
	max-width: 100%;
}

.appt-card {
	width: 100%;
	flex-shrink: 1;
	min-height: 0;
	overflow-y: auto;
	box-sizing: border-box;
	padding: 30rpx 32rpx 36rpx;
	background: #ffffff;
	border-radius: 30rpx;
	box-shadow: 0 20rpx 60rpx rgba(45, 123, 255, 0.2);
}

.appt-head-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-bottom: 16rpx;
}

.appt-blue-bar {
	width: 8rpx;
	height: 40rpx;
	background: #2d7bff;
	border-radius: 4rpx;
	margin-right: 16rpx;
	flex-shrink: 0;
}

.appt-head-title {
	font-size: 40rpx;
	line-height: 58rpx;
	font-weight: 700;
	color: #000000;
}

.appt-subtitle {
	display: block;
	font-size: 24rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #454545;
	margin-bottom: 40rpx;
}

.appt-section {
	width: 100%;
}

.appt-section-gap {
	margin-top: 30rpx;
}

.appt-section-label {
	display: block;
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #000000;
	margin-bottom: 8rpx;
}

.appt-chip-grid {
	display: flex;
	flex-direction: row;
	flex-wrap: wrap;
	gap: 16rpx 12rpx;
	margin-top: 8rpx;
}

.appt-chip-grid-3 .appt-chip {
	width: calc((100% - 24rpx) / 3);
	box-sizing: border-box;
}

.appt-chip-grid:not(.appt-chip-grid-3):not(.appt-chip-grid-2) .appt-chip {
	width: calc((100% - 24rpx) / 3);
	max-width: 184rpx;
	box-sizing: border-box;
}

.appt-chip-grid-2 {
	gap: 16rpx;
}

.appt-chip-grid-2 .appt-chip {
	flex: 1;
	min-width: calc(50% - 8rpx);
	max-width: calc(50% - 8rpx);
	box-sizing: border-box;
}

.appt-chip {
	min-height: 54rpx;
	padding: 8rpx 10rpx;
	box-sizing: border-box;
	display: flex;
	align-items: center;
	justify-content: center;
	border-radius: 10rpx;
	border: 2rpx solid #e0e0e0;
	background: #ffffff;
}

.appt-chip-on {
	border-color: #2d7bff;
	background: rgba(45, 123, 255, 0.08);
}

.appt-chip-text {
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 400;
	color: #454545;
	text-align: center;
}

.appt-chip-on .appt-chip-text {
	color: #2d7bff;
	font-weight: 500;
}

.appt-submit {
	width: 584rpx;
	max-width: 100%;
	height: 66rpx;
	line-height: 66rpx;
	margin: 36rpx auto 0;
	border-radius: 20rpx;
	background: #2d7bff;
	color: #ffffff;
	font-size: 32rpx;
	font-weight: 700;
	box-shadow: 0 0 16rpx rgba(45, 123, 255, 0.3);
	border: none;
}

.appt-cancel {
	width: 100%;
	flex-shrink: 0;
	height: 90rpx;
	margin-top: 28rpx;
	border-radius: 20rpx;
	background: #ffffff;
	box-shadow: 0 0 16rpx rgba(45, 123, 255, 0.3);
	display: flex;
	align-items: center;
	justify-content: center;
	box-sizing: border-box;
}

.appt-cancel-text {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 400;
	color: #2d7bff;
}

/* 预约成功底部抽屉 375×581 ×2 */
.appt-success-mask {
	position: fixed;
	left: 0;
	right: 0;
	top: 0;
	bottom: 0;
	z-index: 110;
	background: rgba(0, 0, 0, 0.45);
	display: flex;
	flex-direction: column;
	justify-content: flex-end;
	align-items: stretch;
	box-sizing: border-box;
}

.appt-success-sheet {
	width: 100%;
	min-height: 1162rpx;
	box-sizing: border-box;
	padding: 90rpx 0 48rpx;
	background: #ffffff;
	border-radius: 40rpx 40rpx 0 0;
	display: flex;
	flex-direction: column;
	align-items: center;
}

.appt-success-icon {
	width: 160rpx;
	height: 160rpx;
	margin-bottom: 24rpx;
}

.appt-success-title {
	font-size: 40rpx;
	line-height: 58rpx;
	font-weight: 700;
	color: #000000;
	text-align: center;
}

.appt-success-sub {
	margin-top: 6rpx;
	padding: 0 48rpx;
	font-size: 26rpx;
	line-height: 38rpx;
	font-weight: 400;
	color: #454545;
	text-align: center;
}

.appt-success-table {
	width: 100%;
	margin-top: 80rpx;
	padding: 0 68rpx;
	box-sizing: border-box;
}

.appt-success-row {
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	align-items: flex-start;
	padding: 12rpx 0;
	border-bottom: 2rpx solid #ededed;
}

.appt-success-label {
	flex-shrink: 0;
	max-width: 42%;
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #8f8e95;
	text-align: left;
}

.appt-success-value {
	flex: 1;
	margin-left: 24rpx;
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #2a2a2a;
	text-align: right;
	word-break: break-all;
}

.appt-success-btn {
	width: 642rpx;
	max-width: calc(100% - 68rpx);
	height: 90rpx;
	line-height: 90rpx;
	margin-top: 68rpx;
	border-radius: 60rpx;
	background: #2d7bff;
	color: #ffffff;
	font-size: 32rpx;
	font-weight: 700;
	box-shadow: 0 0 16rpx rgba(45, 123, 255, 0.3);
	border: none;
}
</style>
