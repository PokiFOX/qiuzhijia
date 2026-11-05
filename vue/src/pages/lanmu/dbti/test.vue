<template>
	<view class="test-page">
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

		<view v-if="loading" class="test-loading">
			<text class="test-loading-text">加载题目…</text>
		</view>

		<view v-else-if="currentQuestion" class="test-body">
			<view class="progress-header">
				<text class="progress-index">第{{ currentIndex + 1 }}/{{ total }}题</text>
				<text class="progress-percent">{{ progressPercent }}%</text>
			</view>

			<view class="progress-track">
				<view class="progress-fill" :style="{ width: progressPercent + '%' }" />
			</view>

			<view class="question-card glass-panel">
				<text class="question-label">QUESTION</text>
				<view class="question-text-wrap">
					<text class="question-text">{{ currentQuestion.text }}</text>
				</view>
			</view>

			<view
				class="option-row"
				:class="selectedChoice === 'A' ? 'option-row-selected' : 'glass-panel'"
				@tap="selectChoice('A')"
			>
				<image
					class="option-badge"
					:src="parseimage(selectedChoice === 'A' ? 'DBTI/A2.png' : 'DBTI/A1.png')"
					mode="aspectFit"
				/>
				<text class="option-text" :class="{ 'option-text-selected': selectedChoice === 'A' }">
					{{ currentQuestion.optionA }}
				</text>
			</view>

			<view
				class="option-row option-row-gap"
				:class="selectedChoice === 'B' ? 'option-row-selected' : 'glass-panel'"
				@tap="selectChoice('B')"
			>
				<image
					class="option-badge"
					:src="parseimage(selectedChoice === 'B' ? 'DBTI/B2.png' : 'DBTI/B1.png')"
					mode="aspectFit"
				/>
				<text class="option-text" :class="{ 'option-text-selected': selectedChoice === 'B' }">
					{{ currentQuestion.optionB }}
				</text>
			</view>

			<view class="nav-footer">
				<view v-if="currentIndex > 0" class="footer-btn" @tap="goPrev">
					<text class="footer-arrow">‹</text>
					<text class="footer-label">上一题</text>
				</view>
				<view v-else class="footer-side-placeholder" />

				<view class="footer-btn footer-btn-right" @tap="onFooterPrimary">
					<template v-if="!isLastQuestion">
						<text class="footer-label">下一题</text>
						<text class="footer-arrow">›</text>
					</template>
					<text v-else class="footer-label">完成</text>
				</view>
			</view>
		</view>

		<view v-else class="test-loading">
			<text class="test-loading-text">暂无题目</text>
		</view>
	</view>
</template>

<script setup lang="ts">
import { computed, ref, watch } from "vue";
import { onLoad } from "@dcloudio/uni-app";

import { mbtiQuestions } from "../../../tapah/data";
import { parseimage, getWechatNavMetrics } from "../../../tapah/function";
import { RequestQueryMbti } from "../../../tapah/request";

const DBTI_STORAGE_KEY = "dbti_test_progress";

type Choice = "A" | "B" | null;

interface StoredProgress {
	currentIndex: number;
	answers: Choice[];
}

const loading = ref(true);
const currentIndex = ref(0);
const answers = ref<Choice[]>([]);

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

const total = computed(() => mbtiQuestions.value.length);

const currentQuestion = computed(() => {
	const list = mbtiQuestions.value;
	if (currentIndex.value < 0 || currentIndex.value >= list.length) return null;
	return list[currentIndex.value];
});

const progressPercent = computed(() => {
	if (total.value <= 0) return 0;
	return Math.round(((currentIndex.value + 1) / total.value) * 100);
});

const selectedChoice = computed(() => {
	const a = answers.value[currentIndex.value];
	return a === "A" || a === "B" ? a : null;
});

const isLastQuestion = computed(() => {
	return total.value > 0 && currentIndex.value >= total.value - 1;
});

function ensureAnswersLength(n: number) {
	while (answers.value.length < n) {
		answers.value.push(null);
	}
}

function persistProgress() {
	const payload: StoredProgress = {
		currentIndex: currentIndex.value,
		answers: answers.value.slice(0, total.value),
	};
	try {
		uni.setStorageSync(DBTI_STORAGE_KEY, JSON.stringify(payload));
	} catch (e) {
		console.error("dbti persist failed", e);
	}
}

function loadStoredProgress() {
	try {
		const raw = uni.getStorageSync(DBTI_STORAGE_KEY);
		if (!raw) return;
		const parsed = JSON.parse(String(raw)) as StoredProgress;
		if (typeof parsed.currentIndex === "number") {
			currentIndex.value = Math.max(0, parsed.currentIndex);
		}
		if (Array.isArray(parsed.answers)) {
			answers.value = parsed.answers.map((v) => (v === "A" || v === "B" ? v : null));
		}
	} catch (e) {
		console.error("dbti load progress failed", e);
	}
}

function selectChoice(choice: "A" | "B") {
	ensureAnswersLength(total.value);
	answers.value[currentIndex.value] = choice;
	persistProgress();
}

function goPrev() {
	if (currentIndex.value <= 0) return;
	currentIndex.value -= 1;
	persistProgress();
}

function goNext() {
	if (!selectedChoice.value) {
		uni.showToast({ title: "请先选择一个选项", icon: "none" });
		return;
	}
	if (currentIndex.value >= total.value - 1) return;
	currentIndex.value += 1;
	persistProgress();
}

function onComplete() {
	if (!selectedChoice.value) {
		uni.showToast({ title: "请先选择一个选项", icon: "none" });
		return;
	}
	uni.showToast({ title: "已完成全部题目", icon: "none" });
}

function onFooterPrimary() {
	if (isLastQuestion.value) {
		onComplete();
	} else {
		goNext();
	}
}

const onBack = () => {
	uni.navigateBack();
};

watch(total, (n) => {
	if (n > 0) {
		ensureAnswersLength(n);
		if (currentIndex.value >= n) currentIndex.value = n - 1;
	}
});

onLoad(async () => {
	loading.value = true;
	loadStoredProgress();
	try {
		await RequestQueryMbti();
		ensureAnswersLength(mbtiQuestions.value.length);
		if (currentIndex.value >= mbtiQuestions.value.length) {
			currentIndex.value = Math.max(0, mbtiQuestions.value.length - 1);
		}
	} catch (e) {
		console.error(e);
		uni.showToast({ title: "加载失败", icon: "none" });
	} finally {
		loading.value = false;
	}
});
</script>

<style scoped>
.test-page {
	position: relative;
	width: 100vw;
	height: 100vh;
	overflow: hidden;
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

.test-body {
	position: relative;
	z-index: 1;
	box-sizing: border-box;
	padding-top: 218rpx;
	padding-bottom: 48rpx;
}

.progress-header {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: space-between;
	padding: 0 42rpx;
}

.progress-index,
.progress-percent {
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 500;
	color: #2a2a2a;
}

.progress-track {
	height: 16rpx;
	margin: 10rpx 42rpx 0;
	border-radius: 8rpx;
	background-color: #ffffff;
	overflow: hidden;
}

.progress-fill {
	height: 100%;
	background-color: #2d7bff;
	border-radius: 8rpx;
	transition: width 0.2s ease;
}

.glass-panel {
	background: linear-gradient(180deg, rgba(255, 255, 255, 0.8) 0%, rgba(255, 255, 255, 0.5) 100%);
}

.question-card {
	display: flex;
	flex-direction: column;
	height: 200rpx;
	margin: 44rpx 40rpx 0;
	border-radius: 30rpx;
	box-sizing: border-box;
	overflow: hidden;
}

.question-label {
	align-self: flex-start;
	margin-top: 24rpx;
	margin-left: 36rpx;
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 500;
	color: #2a2a2a;
}

.question-text-wrap {
	flex: 1;
	display: flex;
	align-items: flex-start;
	justify-content: flex-start;
	padding: 24rpx 36rpx;
	box-sizing: border-box;
	min-height: 0;
}

.question-text {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 400;
	color: #000000;
	text-align: left;
}

.option-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	height: 92rpx;
	margin: 36rpx 40rpx 0;
	padding: 0 30rpx;
	border-radius: 30rpx;
	box-sizing: border-box;
}

.option-row-gap {
	margin-top: 40rpx;
}

.option-row-selected {
	height: 92rpx;
	margin-left: 40rpx;
	margin-right: 40rpx;
	padding: 0 28rpx;
	background-color: #ffffff;
	border: 2rpx solid #2d7bff;
	border-radius: 20rpx;
}

.option-badge {
	width: 48rpx;
	height: 48rpx;
	flex-shrink: 0;
}

.option-text {
	flex: 1;
	margin-left: 20rpx;
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #2a2a2a;
}

.option-text-selected {
	color: #2d7bff;
}

.nav-footer {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: space-between;
	margin-top: 40rpx;
	padding: 0 42rpx;
}

.footer-side-placeholder {
	min-width: 1rpx;
	flex: 1;
}

.footer-btn {
	display: flex;
	flex-direction: row;
	align-items: center;
	flex-shrink: 0;
}

.footer-btn-right {
	flex-direction: row;
	margin-left: auto;
}

.footer-arrow {
	font-size: 32rpx;
	line-height: 1;
	font-weight: 500;
	color: #2d7bff;
}

.footer-label {
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 500;
	color: #2d7bff;
}

.footer-btn .footer-arrow + .footer-label {
	margin-left: 4rpx;
}

.footer-btn-right .footer-label + .footer-arrow {
	margin-left: 4rpx;
}

.test-loading {
	position: relative;
	z-index: 1;
	display: flex;
	align-items: center;
	justify-content: center;
	height: 100vh;
}

.test-loading-text {
	font-size: 28rpx;
	color: #2a2a2a;
}
</style>
