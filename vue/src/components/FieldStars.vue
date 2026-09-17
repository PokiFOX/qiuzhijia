<template>
	<view class="field-hot-score">
		<text class="field-hot-score-text">{{ scoreText }}</text>
	</view>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { fieldHotScoreText } from "../tapah/function";

const props = defineProps<{
	star: number;
}>();

const scoreText = computed(() => fieldHotScoreText(props.star));
</script>

<style scoped>
.field-hot-score {
	display: flex;
	align-items: center;
	justify-content: center;
	width: 76rpx;
	height: 34rpx;
	background-color: #fef5e6;
	border-radius: 8rpx;
	flex-shrink: 0;
	box-sizing: border-box;
}

.field-hot-score-text {
	font-size: 26rpx;
	line-height: 38rpx;
	font-weight: 500;
	color: #80500a;
}
</style>
