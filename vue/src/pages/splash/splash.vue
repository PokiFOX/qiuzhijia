<template>
	<view class="splash-container">
		<image class="logo" src="/static/logo.png" mode="aspectFit" />
		<text class="slogan">求职家 | 专注应届生求职实习</text>
		<view class="dots">
			<view class="dot" />
			<view class="dot" />
			<view class="dot" />
		</view>
	</view>
</template>

<script setup lang="ts">
import { onMounted } from "vue";
import { RequestZoneList,RequestSectorList, RequestLevelList, RequestFieldList } from "../../tapah/request";

onMounted(async () => {
	const startTime = Date.now();

	try {
		await Promise.all([
			RequestZoneList(),
			RequestSectorList(),
			RequestLevelList(),
			RequestFieldList(),
		]);
	} catch (err) {
		console.error("Failed to load initial configurations:", err);
	}

	const elapsedTime = Date.now() - startTime;
	const remainingTime = Math.max(0, 1000 - elapsedTime);

	setTimeout(() => {
		uni.reLaunch({
			url: "/pages/mainpage/mainpage",
		});
	}, remainingTime);
});
</script>

<style scoped>
.splash-container {
	display: flex;
	flex-direction: column;
	align-items: center;
	width: 100vw;
	height: 100vh;
	background-color: #ffffff;
}

.logo {
	width: 191rpx;
	height: 349rpx;
	margin-top: 180rpx;
}

.slogan {
	margin-top: 15rpx;
	color: #000000;
	font-family: "PingFang SC", sans-serif;
	font-size: 20rpx;
	font-weight: 500;
	line-height: 29rpx;
	text-align: center;
}

.dots {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-top: 20rpx;
}

.dot {
	width: 6rpx;
	height: 6rpx;
	margin: 0 4rpx;
	border-radius: 50%;
	background-color: #cccccc;
	opacity: 0.3;
	animation: splash-dot-pulse 1.2s ease-in-out infinite;
}

.dot:nth-child(2) {
	animation-delay: 0.2s;
}

.dot:nth-child(3) {
	animation-delay: 0.4s;
}

@keyframes splash-dot-pulse {
	0%,
	80%,
	100% {
		opacity: 0.3;
	}
	40% {
		opacity: 1;
	}
}
</style>
