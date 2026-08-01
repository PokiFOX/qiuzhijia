<template>
	<view class="splash-container">
		<image class="logo" src="/static/logo.png" mode="aspectFit" />
	</view>
</template>

<script setup lang="ts">
import { onMounted } from "vue";
import {
	RequestZoneList,
	RequestSectorList,
	RequestLevelList,
	RequestFieldList,
} from "../../tapah/request";

onMounted(async () => {
	const startTime = Date.now();

	try {
		// Load all initial configurations in parallel
		await Promise.all([
			RequestZoneList(),
			RequestSectorList(),
			RequestLevelList(),
			RequestFieldList(),
		]);
	} catch (err) {
		console.error("Failed to load initial configurations:", err);
	}

	// Ensure splash screen is displayed for at least 1000ms
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
	width: 100vw;
	height: 100vh;
	align-items: center;
	justify-content: center;
	background-color: #ffffff;
}

.logo {
	width: 240rpx;
	height: 240rpx;
}
</style>
