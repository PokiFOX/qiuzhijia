<template>
	<image
		class="nav-arrow"
		:class="direction === 'down' ? 'nav-arrow-down' : 'nav-arrow-right'"
		:src="arrowSrc"
		mode="aspectFit"
	/>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { parseimage } from "../tapah/function";

const props = withDefaults(
	defineProps<{
		direction?: "right" | "down";
	}>(),
	{
		direction: "right",
	},
);

const arrowSrc = computed(() =>
	parseimage(props.direction === "down" ? "底部按钮/下箭头.png" : "底部按钮/详情箭头.png"),
);
</script>

<style scoped>
.nav-arrow {
	flex-shrink: 0;
	margin-left: 4rpx;
}

.nav-arrow-right {
	width: 16rpx;
	height: 16rpx;
}

.nav-arrow-down {
	width: 14rpx;
	height: 14rpx;
}
</style>
