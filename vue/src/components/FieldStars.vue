<template>
	<view v-if="mode === 'stars'" class="field-stars">
		<image
			v-for="n in parts.full"
			:key="'full-' + n"
			class="star-icon"
			:src="parseimage('底部按钮/全星.png')"
			mode="aspectFit"
		/>
		<image
			v-if="parts.half"
			class="star-icon"
			:src="parseimage('底部按钮/半星.png')"
			mode="aspectFit"
		/>
		<image
			v-for="n in parts.empty"
			:key="'empty-' + n"
			class="star-icon"
			:src="parseimage('底部按钮/空星.png')"
			mode="aspectFit"
		/>
	</view>
	<view v-else class="field-hot-score">
		<text class="field-hot-score-text">{{ scoreText }}</text>
	</view>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { parseimage, fieldHotScoreText, fieldStarParts } from "../tapah/function";

const props = withDefaults(
	defineProps<{
		star: number;
		mode?: "score" | "stars";
	}>(),
	{
		mode: "score",
	},
);

const scoreText = computed(() => fieldHotScoreText(props.star));
const parts = computed(() => fieldStarParts(props.star));
</script>

<style scoped>
.field-stars {
	display: flex;
	flex-direction: row;
	align-items: center;
	flex-shrink: 0;
}

.star-icon {
	width: 24rpx;
	height: 24rpx;
	flex-shrink: 0;
}

.star-icon + .star-icon {
	margin-left: 4rpx;
}

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
