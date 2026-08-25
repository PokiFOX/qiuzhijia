<template>
	<view v-if="rendered" class="sheet-mask" :class="{ 'sheet-mask-show': showPanel }">
		<view class="sheet-mask-top" @tap="onClose" @touchmove.stop.prevent />
		<view class="sheet-panel" :class="{ 'sheet-panel-show': showPanel }" @tap.stop>
			<view class="sheet-header">
				<text class="sheet-title">{{ title }}</text>
				<view class="sheet-close" @tap="onClose">
					<text class="sheet-close-icon">×</text>
				</view>
			</view>
			<view class="sheet-body">
				<slot />
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, watch, nextTick } from "vue";

const props = defineProps<{
	visible: boolean;
	title: string;
}>();

const emit = defineEmits<{
	close: [];
}>();

const rendered = ref(false);
const showPanel = ref(false);

watch(
	() => props.visible,
	(show) => {
		if (show) {
			rendered.value = true;
			nextTick(() => {
				setTimeout(() => {
					showPanel.value = true;
				}, 20);
			});
		} else {
			showPanel.value = false;
			setTimeout(() => {
				rendered.value = false;
			}, 300);
		}
	},
	{ immediate: true },
);

const onClose = () => {
	emit("close");
};
</script>

<style scoped>
.sheet-mask {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: rgba(0, 0, 0, 0);
	z-index: 1000;
	display: flex;
	flex-direction: column;
	justify-content: flex-end;
	transition: background-color 0.3s ease;
}

.sheet-mask-show {
	background-color: rgba(0, 0, 0, 0.5);
}

.sheet-mask-top {
	flex: 1;
	min-height: 25vh;
	width: 100%;
}

.sheet-panel {
	width: 100%;
	height: 75vh;
	background-color: #ffffff;
	border-radius: 24rpx 24rpx 0 0;
	display: flex;
	flex-direction: column;
	transform: translateY(100%);
	transition: transform 0.3s ease;
	box-sizing: border-box;
	overflow: hidden;
	flex-shrink: 0;
}

.sheet-panel-show {
	transform: translateY(0);
}

.sheet-header {
	position: relative;
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	height: 96rpx;
	flex-shrink: 0;
	border-bottom: 2rpx solid #f2f2f2;
	box-sizing: border-box;
}

.sheet-title {
	font-size: 32rpx;
	font-weight: 700;
	color: #000000;
}

.sheet-close {
	position: absolute;
	right: 32rpx;
	top: 50%;
	transform: translateY(-50%);
	display: flex;
	align-items: center;
	justify-content: center;
	width: 64rpx;
	height: 64rpx;
}

.sheet-close-icon {
	font-size: 44rpx;
	line-height: 1;
	color: #888888;
	font-weight: 400;
}

.sheet-body {
	flex: 1;
	min-height: 0;
	height: 0;
	display: flex;
	flex-direction: column;
	background-color: #f8f8f8;
	overflow: hidden;
}
</style>
