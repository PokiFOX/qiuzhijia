<template>
	<view class="field-stars">
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
</template>

<script setup lang="ts">
import { computed } from "vue";
import { parseimage, fieldStarParts } from "../tapah/function";

const props = defineProps<{
	star: number;
}>();

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
</style>
