<template>
	<view v-if="cases.length > 0" class="similar-section">
		<view class="section-title-row">
			<view class="title-line title-line-left"></view>
			<text class="section-title">相似案例</text>
			<view class="title-line title-line-right"></view>
		</view>
		<view class="similar-list">
			<SimilarCaseCard v-for="c in cases" :key="c.id" :case-item="c" />
		</view>
	</view>
</template>

<script setup lang="ts">
import type { Case } from "../tapah/class";
import SimilarCaseCard from "./SimilarCaseCard.vue";

defineProps<{
	cases: Case[];
}>();
</script>

<style scoped>
.similar-section {
	width: 100%;
	margin-top: 24rpx;
	box-sizing: border-box;
}

.section-title-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	width: 100%;
}

.title-line {
	width: 188rpx;
	height: 2rpx;
	flex-shrink: 0;
}

.title-line-left {
	margin-right: 50rpx;
	background: linear-gradient(90deg, rgba(216, 216, 216, 0) 0%, #c4c4c4 100%);
}

.title-line-right {
	margin-left: 50rpx;
	background: linear-gradient(90deg, #c4c4c4 0%, rgba(216, 216, 216, 0) 100%);
}

.section-title {
	font-size: 34rpx;
	line-height: 50rpx;
	font-weight: 350;
	color: #000000;
	flex-shrink: 0;
}

.similar-list {
	display: flex;
	flex-direction: column;
	gap: 20rpx;
	margin-top: 16rpx;
	width: 100%;
}
</style>
