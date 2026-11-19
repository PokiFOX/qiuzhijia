<template>
	<view class="dbti-page">
		<image class="dbti-bg" :src="parseimage('DBTI/BG.png')" mode="aspectFill" />

		<view class="page-nav" :style="navBarStyle">
			<view class="nav-side nav-side-left">
				<view class="nav-back" :style="navSideStyle" @tap="onBack">
					<text class="nav-back-icon">‹</text>
				</view>
			</view>
			<text class="nav-title" :style="navTitleStyle">DBTI职业性格测试</text>
			<view class="nav-side nav-side-right"></view>
		</view>

		<scroll-view class="dbti-scroll" scroll-y enhanced :show-scrollbar="false">
			<view class="dbti-body">
				<image class="dbti-logo" :src="parseimage('DBTI/DBTI.png')" mode="widthFix" />

				<text class="hero-title">职业性格测试</text>
				<text class="hero-subtitle">探索你的性格，发现你的职业潜能</text>

				<view class="feature-card">
					<image
						class="feature-explain-btn"
						:src="parseimage('DBTI/测试说明.png')"
						mode="aspectFit"
						@tap="onExplainTap"
					/>
					<view class="feature-col" v-for="(item, idx) in featureItems" :key="idx">
						<image class="feature-icon" :src="parseimage(item.icon)" mode="widthFix" />
						<text class="feature-title">{{ item.title }}</text>
						<text class="feature-desc">{{ item.desc }}</text>
					</view>
				</view>

				<view class="btn-primary btn-wide" @tap="onStartTap">
					<text class="btn-primary-text">开始测试</text>
				</view>

				<view class="action-row">
					<view class="btn-outline btn-half" @tap="onQrTap">
						<text class="btn-outline-text">获取二维码</text>
					</view>
					<view class="btn-outline btn-half" @tap="onViewReportTap">
						<text class="btn-outline-text">查看报告</text>
					</view>
				</view>

				<text class="footer-note">结果用于职业探索，不代表招聘录用结论</text>
			</view>
		</scroll-view>

		<view v-if="showExplainSheet" class="explain-mask" @tap="closeExplainSheet">
			<view class="explain-sheet" @tap.stop>
				<text class="explain-title">测试说明</text>
				<text class="explain-intro">
					本测试基于MBTI四维偏好框架，共28道职业情境选择题，帮助你在央国企和金融领域找到更匹配的岗位方向。
				</text>
				<text class="explain-bullet">·共28题，约2分钟完成。</text>
				<text class="explain-bullet">·每题两个选项，选择更符合你日常倾向的一项。</text>
				<text class="explain-bullet">·结果包含职业性格类型、四维偏好比例、具体岗位推荐和求职准备建议。</text>
				<text class="explain-bullet">·答题进度会自动保存，刷新页面不会丢失。</text>
				<text class="explain-disclaimer">本测试用于职业探索，不是官方MBTI测评、医学诊断或招聘结论。</text>
				<view class="explain-confirm-btn" @tap="closeExplainSheet">
					<text class="explain-confirm-text">知道了</text>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";

import { KeFu, parseimage, getWechatNavMetrics } from "../../../tapah/function";
import { RequestQueryMbti } from "../../../tapah/request";
import { mbtiQuestions } from "../../../tapah/data";
import {
	clearDbtiTestStorage,
	DBTI_REPORT_UNLOCK_URL,
	DBTI_RESULT_URL,
	hasDbtiReportPhoneInStorage,
	isDbtiTestCompletedInStorage,
} from "./dbtiStorage";

const featureItems = [
	{
		icon: "DBTI/28道专业题目.png",
		title: "28道专业题目",
		desc: "科学测评",
	},
	{
		icon: "DBTI/科学性格测试.png",
		title: "科学性格测试",
		desc: "多维度解读",
	},
	{
		icon: "DBTI/专属职业建议.png",
		title: "专属职业建议",
		desc: "发现适合方向",
	},
];

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

const onBack = () => {
	uni.navigateBack();
};

const onQrTap = () => {
	KeFu();
};

const showExplainSheet = ref(false);

const onExplainTap = () => {
	showExplainSheet.value = true;
};

const closeExplainSheet = () => {
	showExplainSheet.value = false;
};

const onViewReportTap = () => {
	if (!isDbtiTestCompletedInStorage()) {
		uni.showToast({ title: "请先完成测试", icon: "none" });
		return;
	}
	const url = hasDbtiReportPhoneInStorage() ? DBTI_RESULT_URL : DBTI_REPORT_UNLOCK_URL;
	uni.navigateTo({
		url,
		fail(err) {
			console.error("navigateTo dbti report failed:", err);
			uni.showToast({ title: "无法打开报告", icon: "none" });
		},
	});
};

const onStartTap = async () => {
	clearDbtiTestStorage();
	try {
		if (mbtiQuestions.value.length === 0) {
			await RequestQueryMbti();
		}
		if (mbtiQuestions.value.length === 0) {
			uni.showToast({ title: "暂无题目，请稍后再试", icon: "none" });
			return;
		}
	} catch (e) {
		console.error(e);
		uni.showToast({ title: "题目加载失败", icon: "none" });
		return;
	}
	uni.navigateTo({
		url: "/pages/lanmu/dbti/test",
		fail(err) {
			console.error("navigateTo dbti test failed:", err);
			uni.showToast({ title: "无法打开测试页", icon: "none" });
		},
	});
};
</script>

<style scoped>
.dbti-page {
	position: relative;
	width: 100vw;
	height: 100vh;
	box-sizing: border-box;
	overflow: hidden;
	background-color: #f5f9ff;
}

.dbti-bg {
	position: absolute;
	left: 0;
	top: 0;
	width: 100%;
	height: 100%;
	z-index: 0;
	pointer-events: none;
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
	width: 100%;
	box-sizing: border-box;
	background-color: transparent;
}

.nav-side {
	display: flex;
	align-items: center;
	min-width: 64rpx;
}

.nav-side-left {
	justify-content: flex-start;
}

.nav-side-right {
	justify-content: flex-end;
}

.nav-back {
	display: flex;
	align-items: center;
	justify-content: center;
	min-width: 64rpx;
	padding-right: 8rpx;
}

.nav-back-icon {
	font-size: 48rpx;
	line-height: 1;
	color: #000000;
	font-weight: 400;
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

.dbti-scroll {
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	z-index: 1;
	width: 100%;
	height: 100%;
}

.dbti-body {
	display: flex;
	flex-direction: column;
	align-items: flex-start;
	box-sizing: border-box;
	padding-bottom: 96rpx;
}

.dbti-logo {
	width: 400rpx;
	margin-top: 246rpx;
	margin-left: 84rpx;
	display: block;
}

.hero-title {
	margin-top: 22rpx;
	margin-left: 84rpx;
	font-size: 52rpx;
	line-height: 76rpx;
	font-weight: 500;
	color: #000000;
}

.hero-subtitle {
	margin-top: 10rpx;
	margin-left: 84rpx;
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #2c4068;
}

.feature-card {
	position: relative;
	align-self: center;
	display: flex;
	flex-direction: row;
	align-items: center;
	gap: 136rpx;
	width: 658rpx;
	height: 226rpx;
	padding: 0 82rpx;
	margin-top: 486rpx;
	border-radius: 50rpx;
	background-color: #ffffff;
	box-shadow: 0 0 10rpx 10rpx rgba(45, 123, 255, 0.35);
	box-sizing: border-box;
}

.feature-explain-btn {
	position: absolute;
	top: 24rpx;
	right: 24rpx;
	width: 26rpx;
	height: 26rpx;
	z-index: 1;
}

.feature-col {
	display: flex;
	flex-direction: column;
	align-items: center;
	flex: 0 0 74rpx;
	width: 74rpx;
	overflow: visible;
}

.feature-icon {
	display: block;
	width: 74rpx;
	height: auto;
}

.feature-title {
	align-self: center;
	width: max-content;
	max-width: 200rpx;
	margin-top: 12rpx;
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 400;
	color: #152649;
	text-align: center;
}

.feature-desc {
	align-self: center;
	width: max-content;
	max-width: 200rpx;
	margin-top: 12rpx;
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 400;
	color: #7e8dae;
	text-align: center;
}

.btn-outline {
	display: flex;
	align-items: center;
	justify-content: center;
	background-color: #ffffff;
	border-radius: 60rpx;
	box-shadow: 0 0 10rpx 10rpx rgba(45, 123, 255, 0.35);
	box-sizing: border-box;
}

.btn-wide {
	align-self: center;
	width: 658rpx;
	height: 90rpx;
	margin-top: 26rpx;
}

.btn-outline-text {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 700;
	color: #2d7bff;
}

.action-row {
	align-self: center;
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-top: 24rpx;
}

.btn-half {
	width: 310rpx;
	height: 90rpx;
}

.btn-half + .btn-half {
	margin-left: 38rpx;
}

.btn-primary {
	display: flex;
	align-items: center;
	justify-content: center;
	background-color: #2d7bff;
	border-radius: 60rpx;
	box-shadow: 0 0 10rpx 10rpx rgba(45, 123, 255, 0.35);
	box-sizing: border-box;
}

.btn-primary-text {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 700;
	color: #ffffff;
}

.footer-note {
	align-self: center;
	margin-top: 18rpx;
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 400;
	color: #7e8dae;
	text-align: center;
}

.explain-mask {
	position: fixed;
	left: 0;
	top: 0;
	right: 0;
	bottom: 0;
	z-index: 20;
	background-color: rgba(0, 0, 0, 0.45);
}

.explain-sheet {
	position: fixed;
	left: 0;
	right: 0;
	bottom: 0;
	z-index: 21;
	display: flex;
	flex-direction: column;
	align-items: stretch;
	box-sizing: border-box;
	padding: 40rpx 54rpx 60rpx;
	background-color: #ffffff;
	border-radius: 40rpx 40rpx 0 0;
}

.explain-title {
	font-size: 36rpx;
	line-height: 52rpx;
	font-weight: 500;
	color: #000000;
}

.explain-intro {
	margin-top: 12rpx;
	font-size: 26rpx;
	line-height: 38rpx;
	font-weight: 350;
	color: #454545;
}

.explain-bullet {
	margin-top: 20rpx;
	font-size: 26rpx;
	line-height: 38rpx;
	font-weight: 350;
	color: #454545;
}

.explain-bullet + .explain-bullet {
	margin-top: 12rpx;
}

.explain-disclaimer {
	margin-top: 28rpx;
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 350;
	color: #8f8e95;
}

.explain-confirm-btn {
	align-self: center;
	display: flex;
	align-items: center;
	justify-content: center;
	width: 642rpx;
	height: 90rpx;
	margin-top: 38rpx;
	border-radius: 60rpx;
	background-color: #2d7bff;
	box-shadow: 0 8rpx 0 rgba(45, 123, 255, 0.3);
}

.explain-confirm-text {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 700;
	color: #ffffff;
}
</style>
