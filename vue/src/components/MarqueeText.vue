<template>
	<view class="marquee-wrap" :style="{ height }">
		<view v-if="!shouldScroll" class="marquee-static">
			<text class="marquee-text" :style="textStyle">{{ text }}</text>
		</view>
		<view v-else class="marquee-viewport">
			<view class="marquee-track" :style="{ animationDuration: `${duration}s` }">
				<text class="marquee-text" :style="textStyle">{{ text }}</text>
				<text class="marquee-text marquee-copy" :style="textStyle">{{ text }}</text>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { computed, type CSSProperties } from "vue";

const props = withDefaults(
	defineProps<{
		text: string;
		height?: string;
		textStyle?: CSSProperties;
		scrollThreshold?: number;
		duration?: number;
	}>(),
	{
		height: "64rpx",
		scrollThreshold: 14,
		duration: 10,
	}
);

const shouldScroll = computed(() => (props.text || "").length > props.scrollThreshold);
</script>

<style scoped>
.marquee-wrap {
	width: 100%;
	overflow: hidden;
}

.marquee-static {
	display: flex;
	align-items: center;
	height: 100%;
	overflow: hidden;
}

.marquee-viewport {
	width: 100%;
	height: 100%;
	overflow: hidden;
	display: flex;
	align-items: center;
}

.marquee-track {
	display: inline-flex;
	flex-direction: row;
	align-items: center;
	white-space: nowrap;
	animation-name: marquee-scroll;
	animation-timing-function: linear;
	animation-iteration-count: infinite;
}

.marquee-copy {
	margin-left: 60rpx;
}

.marquee-text {
	white-space: nowrap;
}

@keyframes marquee-scroll {
	from {
		transform: translateX(0);
	}
	to {
		transform: translateX(calc(-50% - 30rpx));
	}
}
</style>
