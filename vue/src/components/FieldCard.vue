<template>
	<view :class="['field-card', { 'field-card-full': fullContent }]" @tap="emit('tap')">
		<view class="card-row-top">
			<view class="title-bar"></view>
			<view class="title-group">
				<text class="field-title">{{ field.value }}</text>
				<view class="type-badge">
					<text class="type-badge-text">{{ field.type }}</text>
				</view>
			</view>
			<view class="hot-group">
				<image class="hot-icon" :src="parseimage('底部按钮/专业热门度.png')" mode="aspectFit" />
				<FieldStars class="hot-stars" :star="field.star" />
			</view>
		</view>
		<view class="desc-block">
			<view :class="['desc-content', { 'desc-content-full': fullContent }]">
				<text class="field-desc">{{ field.content }}</text>
				<view v-if="!fullContent && needDetailLink(field.content)" class="detail-overlay">
					<text class="detail-suffix">... 详情 ›</text>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { parseimage } from "../tapah/function";
import type { Field } from "../tapah/class";
import FieldStars from "./FieldStars.vue";

defineProps<{
	field: Field;
	fullContent?: boolean;
}>();

const emit = defineEmits<{
	tap: [];
}>();

const needDetailLink = (content?: string) => (content?.length || 0) > 48;
</script>

<style scoped>
.field-card {
	display: flex;
	flex-direction: column;
	height: 246rpx;
	background-color: #ffffff;
	border-radius: 16rpx;
	padding: 30rpx;
	box-sizing: border-box;
	overflow: hidden;
}

.field-card-full {
	height: auto;
	min-height: 0;
	overflow: visible;
	background-color: transparent;
	border-radius: 0;
	padding: 0;
}

.card-row-top {
	display: flex;
	flex-direction: row;
	align-items: center;
	height: 50rpx;
	flex-shrink: 0;
}

.title-bar {
	width: 6rpx;
	height: 50rpx;
	background-color: #4476ff;
	border-radius: 3rpx;
	flex-shrink: 0;
}

.title-group {
	flex: 1;
	min-width: 0;
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-left: 12rpx;
	overflow: hidden;
}

.field-title {
	flex-shrink: 1;
	min-width: 0;
	font-size: 34rpx;
	line-height: 50rpx;
	font-weight: 400;
	color: #000000;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.type-badge {
	display: flex;
	align-items: center;
	justify-content: center;
	height: 26rpx;
	padding: 0 8rpx;
	margin-left: 12rpx;
	background-color: #deecff;
	border-radius: 8rpx;
	flex-shrink: 0;
	box-sizing: border-box;
}

.type-badge-text {
	font-size: 20rpx;
	line-height: 32rpx;
	font-weight: 400;
	color: #2c3d73;
}

.hot-group {
	display: flex;
	flex-direction: row;
	align-items: center;
	flex-shrink: 0;
	margin-left: 12rpx;
}

.hot-icon {
	width: 132rpx;
	height: 34rpx;
	flex-shrink: 0;
}

.hot-stars {
	margin-left: 4rpx;
}

.desc-block {
	flex-shrink: 0;
	margin-top: 16rpx;
}

.desc-content {
	position: relative;
	height: 120rpx;
	overflow: hidden;
}

.desc-content-full {
	height: auto;
	overflow: visible;
}

.field-desc {
	font-size: 26rpx;
	line-height: 40rpx;
	font-weight: 300;
	color: #000000;
	word-break: break-word;
}

.detail-overlay {
	position: absolute;
	right: 0;
	bottom: 0;
	height: 30rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: flex-end;
	padding-left: 28rpx;
	box-sizing: border-box;
	background: linear-gradient(90deg, rgba(255, 255, 255, 0) 0%, #ffffff 55%);
}

.detail-suffix {
	font-size: 26rpx;
	line-height: 40rpx;
	font-weight: 350;
	color: #5e80f7;
	white-space: nowrap;
}
</style>
