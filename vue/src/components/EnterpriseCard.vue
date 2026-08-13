<template>
	<view :class="['enterprise-card', { 'enterprise-card-compact': compact }]" @tap="emit('tap')">
		<view class="logo-col">
			<image
				v-if="enterprise.icon"
				class="enterprise-logo"
				:src="parseEnterpriseIcon(`小图标/${enterprise.icon}.png`)"
				mode="aspectFit"
			/>
			<view v-else class="logo-placeholder"></view>
		</view>
		<view class="info-col">
			<text class="enterprise-name">{{ enterprise.name || "" }}</text>
			<text v-if="enterprise.englishname" class="enterprise-english-name">{{ enterprise.englishname }}</text>
			<view v-if="enterprise.tags && enterprise.tags.length > 0" class="tags-row">
				<view class="tag-badge" v-for="(tag, tIdx) in enterprise.tags" :key="tIdx">
					<text class="tag-text">{{ tag }}</text>
				</view>
			</view>
			<view class="location-row">
				<image class="location-icon" :src="parseimage('企业列表/定位.png')" mode="aspectFit" />
				<text class="location-text">{{ enterprise.zone?.value || "" }} {{ enterprise.city || "" }}</text>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { parseimage, parseEnterpriseIcon } from "../tapah/function";
import type { Enterprise } from "../tapah/class";

defineProps<{
	enterprise: Enterprise;
	compact?: boolean;
}>();

const emit = defineEmits<{
	tap: [];
}>();
</script>

<style scoped>
.enterprise-card {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	background-color: #ffffff;
	border-radius: 20rpx;
	min-height: 196rpx;
	padding: 20rpx;
	margin-bottom: 24rpx;
	box-shadow: 0 6rpx 12rpx -8rpx rgba(0, 0, 0, 0.12);
	box-sizing: border-box;
}

.enterprise-card-compact {
	margin-bottom: 16rpx;
}

.enterprise-card:last-child {
	margin-bottom: 0;
}

.logo-col {
	display: flex;
	align-items: center;
	justify-content: center;
	width: 150rpx;
	height: 150rpx;
	flex-shrink: 0;
	align-self: center;
}

.enterprise-logo {
	width: 150rpx;
	height: 150rpx;
}

.logo-placeholder {
	width: 150rpx;
	height: 150rpx;
	background-color: #e0e0e0;
	border-radius: 8rpx;
}

.info-col {
	flex: 1;
	min-width: 0;
	display: flex;
	flex-direction: column;
	margin-left: 20rpx;
	overflow: hidden;
}

.enterprise-name {
	font-size: 32rpx;
	font-weight: 700;
	color: #262626;
	line-height: 46rpx;
	word-break: break-word;
}

.enterprise-english-name {
	font-size: 20rpx;
	font-weight: 400;
	color: #3d3d3d;
	line-height: 28rpx;
	margin-top: 4rpx;
	word-break: break-word;
}

.tags-row {
	display: flex;
	flex-direction: row;
	flex-wrap: wrap;
	align-items: center;
	gap: 3rpx;
	width: 100%;
	margin-top: 10rpx;
}

.tag-badge {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	padding: 1rpx 3rpx;
	background-color: #fef5e6;
	border-radius: 6rpx;
	box-sizing: border-box;
}

.tag-text {
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 400;
	color: #80500a;
}

.location-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-top: 10rpx;
}

.location-icon {
	width: 24rpx;
	height: 24rpx;
	flex-shrink: 0;
	margin-right: 6rpx;
}

.location-text {
	font-size: 20rpx;
	color: #666666;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}
</style>
