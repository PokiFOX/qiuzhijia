<template>
	<view class="similar-case-card" @tap="onDetailTap">
		<view class="card-top-row">
			<image
				v-if="caseItem.enticon"
				class="ent-logo"
				:src="parseEnterpriseIcon(`小图标/${caseItem.enticon}.png`)"
				mode="aspectFit"
			/>
			<view v-else class="ent-logo-placeholder"></view>

			<view class="card-info-col">
				<text class="card-title">{{ titleText }}</text>
				<view v-if="metaBadges.length > 0" class="meta-tags-row">
					<view v-for="(badge, idx) in metaBadges" :key="idx" class="meta-tag">
						<text class="meta-tag-text">{{ badge }}</text>
					</view>
				</view>
			</view>
		</view>

		<view class="info-grid">
			<view class="info-row">
				<view class="grid-cell">
					<image class="cell-icon" :src="parseimage('底部按钮/本科.png')" mode="aspectFit" />
					<text class="cell-text">{{ caseItem.school1 || "--" }}</text>
				</view>
				<view class="grid-cell">
					<image class="cell-icon" :src="parseimage('底部按钮/专业.png')" mode="aspectFit" />
					<text class="cell-text">{{ caseItem.field1 || "--" }}</text>
				</view>
			</view>
			<view class="info-row">
				<view class="grid-cell">
					<image class="cell-icon" :src="parseimage('底部按钮/硕士.png')" mode="aspectFit" />
					<text class="cell-text">{{ caseItem.school2 || "--" }}</text>
				</view>
				<view class="grid-cell">
					<image class="cell-icon" :src="parseimage('底部按钮/专业.png')" mode="aspectFit" />
					<text class="cell-text">{{ caseItem.field2 || "--" }}</text>
				</view>
			</view>
			<view class="info-row">
				<view class="grid-cell">
					<image class="cell-icon" :src="parseimage('底部按钮/实习.png')" mode="aspectFit" />
					<text class="cell-text">{{ internshipText }}</text>
				</view>
				<view class="grid-cell detail-cell" @tap.stop="onDetailTap">
					<text class="detail-text">详情 ›</text>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { computed } from "vue";

import type { Case } from "../tapah/class";
import { formatInternship } from "../tapah/caseDisplay";
import { parseimage, parseEnterpriseIcon, stagStr, navigatorToCase } from "../tapah/function";

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

const internshipText = computed(() =>
	formatInternship(props.caseItem.detail, props.caseItem.experiences),
);

const onDetailTap = () => {
	navigatorToCase(props.caseItem.id);
};
</script>

<style scoped>
.similar-case-card {
	display: flex;
	flex-direction: column;
	height: 300rpx;
	padding: 20rpx;
	background-color: #ffffff;
	border-radius: 10rpx;
	box-sizing: border-box;
	box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.1);
}

.card-top-row {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	flex-shrink: 0;
}

.ent-logo {
	width: 64rpx;
	height: 64rpx;
	flex-shrink: 0;
	display: block;
}

.ent-logo-placeholder {
	width: 64rpx;
	height: 64rpx;
	flex-shrink: 0;
	background-color: #e8e8e8;
	border-radius: 8rpx;
}

.card-info-col {
	flex: 1;
	min-width: 0;
	margin-left: 16rpx;
}

.card-title {
	font-size: 28rpx;
	line-height: 40rpx;
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
	gap: 12rpx;
	margin-top: 8rpx;
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

.info-grid {
	display: flex;
	flex-direction: column;
	flex-shrink: 0;
	margin-top: auto;
	padding-top: 12rpx;
	gap: 10rpx;
}

.info-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	width: 100%;
	min-height: 28rpx;
}

.grid-cell {
	display: flex;
	flex-direction: row;
	align-items: center;
	width: 50%;
	box-sizing: border-box;
	padding-right: 8rpx;
	min-width: 0;
}

.detail-cell {
	justify-content: flex-end;
	padding-right: 0;
}

.cell-icon {
	width: 24rpx;
	height: 24rpx;
	flex-shrink: 0;
	display: block;
}

.cell-text {
	margin-left: 12rpx;
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 350;
	color: #000000;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
	flex: 1;
	min-width: 0;
}

.detail-text {
	font-size: 26rpx;
	line-height: 38rpx;
	font-weight: 350;
	color: #5e80f7;
}
</style>
