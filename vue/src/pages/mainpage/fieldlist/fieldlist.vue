<template>
	<view class="filter-page">
		<view class="page-nav" :style="navBarStyle">
			<view class="nav-side nav-side-left">
				<view class="nav-back" :style="navSideStyle" @tap="onBack">
					<text class="nav-back-icon">‹</text>
				</view>
			</view>
			<text class="nav-title" :style="navTitleStyle">招聘专业</text>
			<view class="nav-side nav-side-right"></view>
		</view>

		<view class="page-body">
			<view class="filter-row">
				<view class="filter-item">
					<text class="filter-label filter-label-active">专业列表</text>
					<image
						class="filter-arrow filter-arrow-up"
						:src="parseimage('企业列表/下箭头.png')"
						mode="aspectFit"
					/>
				</view>
				<view class="search-box">
					<input
						class="search-input"
						type="text"
						v-model="search"
						placeholder="搜索你的专业"
						placeholder-class="search-placeholder"
						confirm-type="search"
					/>
					<image class="search-icon" :src="parseimage('企业列表/搜索.png')" mode="aspectFit" />
				</view>
			</view>

			<view class="filter-divider"></view>

			<scroll-view class="option-scroll" scroll-y enhanced :show-scrollbar="false">
				<view class="option-list">
					<view
						v-for="item in displayedOptions"
						:key="item.id"
						class="option-row"
						@tap="onOptionTap(item.id)"
					>
						<text :class="['option-text', { 'option-text-selected': isOptionSelected(item.id) }]">
							{{ item.value }}
						</text>
						<view :class="['option-radio', { 'option-radio-selected': isOptionSelected(item.id) }]"></view>
					</view>
				</view>
			</scroll-view>

			<view class="bottom-divider"></view>
			<view class="bottom-actions">
				<button class="action-btn btn-reset" @tap="onReset">重置</button>
				<button
					class="action-btn btn-confirm"
					:class="{ 'btn-confirm-disabled': !canConfirm }"
					:disabled="!canConfirm"
					@tap="onConfirm"
				>
					确定
				</button>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { onLoad } from "@dcloudio/uni-app";

import { fieldlist } from "../../../tapah/data";
import { parseimage, getWechatNavMetrics } from "../../../tapah/function";

interface FilterOption {
	id: number;
	value: string;
	type?: string;
}

const search = ref("");
const fieldIds = ref<number[]>([]);
const fieldUnlimited = ref(true);

const metrics = computed(() => getWechatNavMetrics());

const navBarStyle = computed(() => ({
	height: `${metrics.value.navBarHeight}px`,
	paddingTop: `${metrics.value.statusBarHeight}px`,
	paddingLeft: `${metrics.value.paddingHorizontal}px`,
	paddingRight: `${metrics.value.paddingHorizontal}px`,
	boxSizing: "border-box" as const,
}));

const navSideStyle = computed(() => {
	const capsuleTopOffset = metrics.value.capsuleTop - metrics.value.statusBarHeight;
	return {
		height: `${metrics.value.capsuleHeight}px`,
		marginTop: `${capsuleTopOffset}px`,
	};
});

const navTitleStyle = computed(() => {
	const capsuleTopOffset = metrics.value.capsuleTop - metrics.value.statusBarHeight;
	return {
		height: `${metrics.value.capsuleHeight}px`,
		lineHeight: `${metrics.value.capsuleHeight}px`,
		marginTop: `${capsuleTopOffset}px`,
	};
});

const baseOptions = computed<FilterOption[]>(() => {
	const fields = fieldlist.value
		.filter((f) => f.id !== 1)
		.map((f) => ({ id: f.id, value: f.value, type: f.type }));
	return [{ id: 0, value: "不限" }, ...fields];
});

const displayedOptions = computed(() => {
	const query = search.value.trim().toLowerCase();
	if (!query) return baseOptions.value;
	return baseOptions.value.filter(
		(item) =>
			item.id === 0 ||
			item.value.toLowerCase().includes(query) ||
			(item.type && item.type.toLowerCase().includes(query)),
	);
});

const canConfirm = computed(() => fieldUnlimited.value || fieldIds.value.length > 0);

const isOptionSelected = (id: number) => {
	if (id === 0) return fieldUnlimited.value;
	return !fieldUnlimited.value && fieldIds.value.includes(id);
};

const onOptionTap = (id: number) => {
	if (id === 0) {
		fieldUnlimited.value = true;
		fieldIds.value = [];
		return;
	}

	fieldUnlimited.value = false;
	const next = [...fieldIds.value];
	const idx = next.indexOf(id);
	if (idx >= 0) {
		next.splice(idx, 1);
	} else {
		next.push(id);
	}
	fieldIds.value = next;
};

const parseIds = (raw?: string) => {
	if (!raw) return [];
	return raw
		.split(",")
		.map((s) => parseInt(s.trim(), 10))
		.filter((n) => !isNaN(n) && n > 0);
};

const onReset = () => {
	fieldIds.value = [];
	fieldUnlimited.value = true;
	search.value = "";
};

const onConfirm = () => {
	if (!canConfirm.value) return;
	const selectedFields = fieldUnlimited.value
		? []
		: fieldlist.value.filter((f) => fieldIds.value.includes(f.id));
	uni.$emit("fieldListSelected", selectedFields);
	uni.navigateBack();
};

const onBack = () => {
	uni.navigateBack();
};

onLoad((options) => {
	fieldIds.value = parseIds(options?.fields);
	fieldUnlimited.value = fieldIds.value.length === 0;
});
</script>

<style scoped>
.filter-page {
	display: flex;
	flex-direction: column;
	width: 100vw;
	height: 100vh;
	background-color: #ffffff;
	box-sizing: border-box;
}

.page-nav {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	justify-content: space-between;
	background-color: #ffffff;
	width: 100%;
	flex-shrink: 0;
	box-sizing: border-box;
}

.nav-side {
	display: flex;
	align-items: center;
	min-width: 64rpx;
}

.nav-side-left {
	justify-content: flex-start;
}

.nav-side-right {
	justify-content: flex-end;
}

.nav-back {
	display: flex;
	align-items: center;
	justify-content: center;
	min-width: 64rpx;
	padding-right: 8rpx;
}

.nav-back-icon {
	font-size: 48rpx;
	line-height: 1;
	color: #000000;
	font-weight: 400;
}

.nav-title {
	flex: 1;
	text-align: center;
	font-size: 32rpx;
	font-weight: 700;
	color: #000000;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.page-body {
	flex: 1;
	display: flex;
	flex-direction: column;
	min-height: 0;
	padding: 0 32rpx;
	box-sizing: border-box;
}

.filter-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	background-color: #ffffff;
	border-radius: 20rpx;
	height: 86rpx;
	margin-top: 20rpx;
	padding: 0 26rpx;
	box-sizing: border-box;
	flex-shrink: 0;
}

.filter-item {
	display: flex;
	flex-direction: row;
	align-items: center;
	flex-shrink: 0;
	margin-right: 26rpx;
}

.filter-label {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 350;
	color: #000000;
	max-width: 128rpx;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.filter-label-active {
	color: #1269ff;
}

.filter-arrow {
	width: 20rpx;
	height: 20rpx;
	margin-left: 4rpx;
	flex-shrink: 0;
	transition: transform 0.2s ease;
}

.filter-arrow-up {
	transform: rotate(180deg);
}

.search-box {
	flex: 1;
	min-width: 0;
	display: flex;
	flex-direction: row;
	align-items: center;
	height: 60rpx;
	background-color: #f5f5f5;
	border-radius: 12rpx;
	padding: 0 20rpx;
	box-sizing: border-box;
}

.search-input {
	flex: 1;
	min-width: 0;
	height: 60rpx;
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 350;
	color: #000000;
}

.search-placeholder {
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 350;
	color: #a4a4a4;
}

.search-icon {
	width: 32rpx;
	height: 32rpx;
	flex-shrink: 0;
	margin-left: 8rpx;
}

.filter-divider {
	margin-top: 22rpx;
	border-top: 2rpx solid #f2f2f2;
	flex-shrink: 0;
}

.option-scroll {
	flex: 1;
	min-height: 0;
	width: 100%;
}

.option-list {
	display: flex;
	flex-direction: column;
	padding: 0 26rpx;
	box-sizing: border-box;
}

.option-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: space-between;
	padding: 10rpx 0;
	box-sizing: border-box;
}

.option-text {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 350;
	color: #3d3d3d;
}

.option-text-selected {
	color: #1269ff;
}

.option-radio {
	width: 30rpx;
	height: 30rpx;
	border-radius: 50%;
	background-color: #ffffff;
	border: 2rpx solid #b3b3b3;
	box-sizing: border-box;
	flex-shrink: 0;
}

.option-radio-selected {
	background-color: #1269ff;
	border-color: #1269ff;
}

.bottom-divider {
	border-top: 2rpx solid #f2f2f2;
	flex-shrink: 0;
}

.bottom-actions {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	gap: 20rpx;
	padding: 20rpx 0 40rpx;
	flex-shrink: 0;
}

.action-btn {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 0;
	margin: 0;
	box-sizing: border-box;
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 400;
	border-radius: 6rpx;
}

.action-btn::after {
	border: none;
}

.btn-reset {
	width: 200rpx;
	height: 70rpx;
	background-color: #f8f8f8;
	color: #000000;
	border: 2rpx solid #b3b3b3;
}

.btn-confirm {
	width: 428rpx;
	height: 70rpx;
	background-color: #1269ff;
	color: #ffffff;
	border: none;
	font-weight: 500;
}

.btn-confirm-disabled {
	background-color: #a4c8ff;
	color: rgba(255, 255, 255, 0.8);
}
</style>
