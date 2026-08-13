<template>
	<view class="case-card">
		<view class="case-top-row">
			<view class="ent-logo-col">
				<image v-if="caseItem.enticon" class="ent-logo" :src="parseEnterpriseIcon(`小图标/${caseItem.enticon}.png`)" mode="aspectFit"/>
				<view v-else class="ent-logo-placeholder"></view>
			</view>

			<view class="case-info-col">
				<text class="case-title">{{ titleText }}</text>
				<view v-if="metaBadges.length > 0" class="meta-tags-row">
					<view v-for="(badge, idx) in metaBadges" :key="idx" class="meta-tag">
						<text class="meta-tag-text">{{ badge }}</text>
					</view>
				</view>
			</view>

			<image class="arrow-icon" :src="parseimage('底部按钮/右圆圈.png')" mode="aspectFit" />
		</view>

		<view class="case-detail-box">
			<view class="student-row">
				<text class="student-name">{{ caseItem.student || "--" }}</text>
				<view v-if="yearTag" class="year-peach-tag">
					<text class="year-peach-text">{{ yearTag }}</text>
				</view>
			</view>

			<view class="dash-line"></view>

			<view class="info-rows">
				<view class="info-row">
					<text class="info-label">毕业院校</text>
					<text class="info-value">{{ caseItem.school1 || "--" }}</text>
				</view>
				<view class="info-row">
					<text class="info-label">本科专业</text>
					<text class="info-value">{{ caseItem.field1 || "--" }}</text>
				</view>
				<view class="info-row">
					<text class="info-label">硕士院校</text>
					<text class="info-value">{{ caseItem.school2 || "--" }}</text>
				</view>
				<view class="info-row">
					<text class="info-label">硕士专业</text>
					<text class="info-value">{{ caseItem.field2 || "--" }}</text>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { computed } from "vue";

import type { Case } from "../tapah/class";
import { parseimage, parseEnterpriseIcon, stagStr } from "../tapah/function";

const props = defineProps<{
	caseItem: Case;
}>();

const titleText = computed(() => {
	const ent = props.caseItem.entname || "";
	const name = props.caseItem.name || "";
	return [ent, name].filter(Boolean).join(" ");
});

const yearTag = computed(() => {
	if (props.caseItem.year) {
		return `${props.caseItem.year}届`;
	}
	const fromTags = props.caseItem.tags?.find((t) => t.includes("届"));
	return fromTags || "";
});

const bestStag = computed(() => {
	const s1 = props.caseItem.stag1;
	const s2 = props.caseItem.stag2;
	const valid = [s1, s2].filter((s): s is number => s != null && s > 0);
	if (valid.length === 0) return null;
	return Math.min(...valid);
});

const metaBadges = computed(() => {
	const badges: string[] = [];
	if (yearTag.value) badges.push(yearTag.value);
	const stag = bestStag.value;
	if (stag != null) {
		const label = stagStr(stag);
		if (label && label !== "未知") badges.push(label);
	}
	return badges;
});
</script>

<style scoped>
.case-card {
	display: flex;
	flex-direction: column;
	height: 532rpx;
	padding: 20rpx;
	background-color: #e8f0ff;
	border-radius: 10rpx;
	box-sizing: border-box;
}

.case-top-row {
	display: flex;
	flex-direction: row;
	align-items: flex-end;
	flex-shrink: 0;
}

.ent-logo-col {
	flex-shrink: 0;
}

.ent-logo {
	width: 152rpx;
	height: 152rpx;
	display: block;
}

.ent-logo-placeholder {
	width: 152rpx;
	height: 152rpx;
	background-color: #d0dff5;
	border-radius: 8rpx;
}

.case-info-col {
	flex: 1;
	min-width: 0;
	display: flex;
	flex-direction: column;
	margin-left: 20rpx;
	margin-right: 12rpx;
}

.case-title {
	font-size: 36rpx;
	line-height: 52rpx;
	font-weight: 500;
	color: #000000;
	display: -webkit-box;
	-webkit-box-orient: vertical;
	-webkit-line-clamp: 2;
	overflow: hidden;
	word-break: break-word;
}

.meta-tags-row {
	display: flex;
	flex-direction: row;
	flex-wrap: wrap;
	align-items: center;
	gap: 20rpx;
	margin-top: 20rpx;
}

.meta-tag {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	height: 34rpx;
	padding: 0 12rpx;
	background-color: #deecff;
	border-radius: 8rpx;
	box-sizing: border-box;
}

.meta-tag-text {
	font-size: 22rpx;
	line-height: 32rpx;
	font-weight: 400;
	color: #2c3d73;
}

.arrow-icon {
	width: 48rpx;
	height: 48rpx;
	flex-shrink: 0;
	align-self: center;
}

.case-detail-box {
	display: flex;
	flex-direction: column;
	height: 300rpx;
	margin-top: 20rpx;
	padding: 20rpx 24rpx;
	background-color: #ffffff;
	border-radius: 10rpx;
	box-sizing: border-box;
	flex-shrink: 0;
}

.student-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	flex-shrink: 0;
}

.student-name {
	font-size: 40rpx;
	line-height: 58rpx;
	font-weight: 500;
	color: #000000;
}

.year-peach-tag {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	height: 32rpx;
	margin-left: 30rpx;
	padding: 0 12rpx;
	background-color: #fbebe5;
	border-radius: 8rpx;
	box-sizing: border-box;
}

.year-peach-text {
	font-size: 22rpx;
	line-height: 32rpx;
	font-weight: 400;
	color: #80500a;
}

.dash-line {
	height: 0;
	margin: 16rpx 0;
	border-bottom: 1rpx dashed #e0e0e0;
	flex-shrink: 0;
}

.info-rows {
	display: flex;
	flex-direction: column;
	flex: 1;
	justify-content: space-between;
	min-height: 0;
}

.info-row {
	display: flex;
	flex-direction: row;
	align-items: center;
}

.info-label {
	flex-shrink: 0;
	width: 112rpx;
	font-size: 28rpx;
	line-height: 48rpx;
	font-weight: 350;
	color: #6a727d;
}

.info-value {
	flex: 1;
	min-width: 0;
	margin-left: 60rpx;
	font-size: 28rpx;
	line-height: 48rpx;
	font-weight: 350;
	color: #000000;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}
</style>
