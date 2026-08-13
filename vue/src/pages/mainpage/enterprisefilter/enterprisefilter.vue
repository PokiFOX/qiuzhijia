<template>
	<view class="filter-page">
		<view class="page-nav" :style="navBarStyle">
			<view class="nav-side nav-side-left">
				<view class="nav-back" :style="navSideStyle" @tap="onBack">
					<text class="nav-back-icon">‹</text>
				</view>
			</view>
			<text class="nav-title" :style="navTitleStyle">招聘企业</text>
			<view class="nav-side nav-side-right"></view>
		</view>

		<view class="page-body">
			<view class="filter-row">
				<view
					v-for="dim in dimensions"
					:key="dim.key"
					class="filter-item"
					@tap="activeDimension = dim.key"
				>
					<text :class="['filter-label', { 'filter-label-active': activeDimension === dim.key }]">
						{{ dim.label }}
					</text>
					<image
						class="filter-arrow"
						:class="{ 'filter-arrow-up': activeDimension === dim.key }"
						:src="parseimage('企业列表/下箭头.png')"
						mode="aspectFit"
					/>
				</view>
				<view class="search-box">
					<input
						class="search-input"
						type="text"
						v-model="search"
						placeholder="搜索企业"
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
						v-for="item in currentOptions"
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
				<button class="action-btn btn-confirm" :class="{ 'btn-confirm-disabled': !canConfirm }" :disabled="!canConfirm" @tap="onConfirm">确定</button>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { onLoad } from "@dcloudio/uni-app";

import { zonelist, sectorlist, levellist } from "../../../tapah/data";
import { parseimage, getWechatNavMetrics } from "../../../tapah/function";

type DimensionKey = "zone" | "level" | "sector";

const dimensions: { key: DimensionKey; label: string }[] = [
	{ key: "zone", label: "地区" },
	{ key: "level", label: "档次" },
	{ key: "sector", label: "行业" },
];

const activeDimension = ref<DimensionKey>("zone");
const search = ref("");
const zoneIds = ref<number[]>([]);
const levelIds = ref<number[]>([]);
const sectorIds = ref<number[]>([]);
const zoneUnlimited = ref(true);
const levelUnlimited = ref(true);
const sectorUnlimited = ref(true);

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

const currentOptions = computed(() => {
	if (activeDimension.value === "zone") return zonelist.value;
	if (activeDimension.value === "level") return levellist.value;
	return sectorlist.value;
});

const currentSelection = computed(() => {
	if (activeDimension.value === "zone") return zoneIds.value;
	if (activeDimension.value === "level") return levelIds.value;
	return sectorIds.value;
});

const currentUnlimited = computed(() => {
	if (activeDimension.value === "zone") return zoneUnlimited.value;
	if (activeDimension.value === "level") return levelUnlimited.value;
	return sectorUnlimited.value;
});

const isDimensionValid = (unlimited: boolean, ids: number[]) => unlimited || ids.length > 0;

const canConfirm = computed(
	() =>
		isDimensionValid(zoneUnlimited.value, zoneIds.value) &&
		isDimensionValid(levelUnlimited.value, levelIds.value) &&
		isDimensionValid(sectorUnlimited.value, sectorIds.value),
);

const isOptionSelected = (id: number) => {
	if (id === 0) return currentUnlimited.value;
	return !currentUnlimited.value && currentSelection.value.includes(id);
};

const getSelectionRef = (dim: DimensionKey) => {
	if (dim === "zone") return zoneIds;
	if (dim === "level") return levelIds;
	return sectorIds;
};

const getUnlimitedRef = (dim: DimensionKey) => {
	if (dim === "zone") return zoneUnlimited;
	if (dim === "level") return levelUnlimited;
	return sectorUnlimited;
};

const onOptionTap = (id: number) => {
	const selection = getSelectionRef(activeDimension.value);
	const unlimited = getUnlimitedRef(activeDimension.value);

	if (id === 0) {
		unlimited.value = true;
		selection.value = [];
		return;
	}

	unlimited.value = false;
	const next = [...selection.value];
	const idx = next.indexOf(id);
	if (idx >= 0) {
		next.splice(idx, 1);
	} else {
		next.push(id);
	}
	selection.value = next;
};

const parseIds = (raw?: string) => {
	if (!raw) return [];
	return raw
		.split(",")
		.map((s) => parseInt(s.trim(), 10))
		.filter((n) => !isNaN(n) && n > 0);
};

const onReset = () => {
	zoneIds.value = [];
	levelIds.value = [];
	sectorIds.value = [];
	zoneUnlimited.value = true;
	levelUnlimited.value = true;
	sectorUnlimited.value = true;
	search.value = "";
};

const onConfirm = () => {
	if (!canConfirm.value) return;
	uni.$emit("enterpriseFilterConfirmed", {
		zones: [...zoneIds.value],
		levels: [...levelIds.value],
		sectors: [...sectorIds.value],
		search: search.value,
	});
	uni.navigateBack();
};

const onBack = () => {
	uni.navigateBack();
};

onLoad((options) => {
	if (options?.tab === "level" || options?.tab === "sector" || options?.tab === "zone") {
		activeDimension.value = options.tab;
	}
	zoneIds.value = parseIds(options?.zones);
	levelIds.value = parseIds(options?.levels);
	sectorIds.value = parseIds(options?.sectors);
	zoneUnlimited.value = zoneIds.value.length === 0;
	levelUnlimited.value = levelIds.value.length === 0;
	sectorUnlimited.value = sectorIds.value.length === 0;
	if (options?.search) {
		search.value = decodeURIComponent(options.search);
	}
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
	max-width: 88rpx;
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
