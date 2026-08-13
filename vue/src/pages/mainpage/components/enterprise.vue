<template>
	<view class="enterprise-container">
		<view class="enterprise-header">
			<!-- Top category images -->
			<view class="top-row">
				<image class="cat-img" :src="parseimage('企业列表/央企国企.png')" mode="widthFix" @load="updateListHeight" @tap="onCategoryTap(1, 0)"/>
				<image class="cat-img" :src="parseimage('企业列表/金融机构.png')" mode="widthFix" @load="updateListHeight" @tap="onCategoryTap(0, 1)"/>
				<image class="cat-img" :src="parseimage('企业列表/成长企业.png')" mode="widthFix" @load="updateListHeight" @tap="onCategoryTap(2, 0)"/>
			</view>

			<!-- Filter and Search Row -->
			<view class="filter-row">
				<view class="filter-item" @tap="openEnterpriseFilter('zone')">
					<text :class="['filter-label', { 'filter-label-active': zoneIds.length > 0 }]">{{ zoneLabel }}</text>
					<image class="filter-arrow" :src="parseimage('企业列表/下箭头.png')" mode="aspectFit"/>
				</view>
				<view class="filter-item" @tap="openEnterpriseFilter('level')">
					<text :class="['filter-label', { 'filter-label-active': levelIds.length > 0 }]">{{ levelLabel }}</text>
					<image class="filter-arrow" :src="parseimage('企业列表/下箭头.png')" mode="aspectFit"/>
				</view>
				<view class="filter-item" @tap="openEnterpriseFilter('sector')">
					<text :class="['filter-label', { 'filter-label-active': sectorIds.length > 0 }]">{{ sectorLabel }}</text>
					<image class="filter-arrow" :src="parseimage('企业列表/下箭头.png')" mode="aspectFit"/>
				</view>
			<view class="search-box">
				<input class="search-input" type="text" v-model="search" placeholder="搜索企业" placeholder-class="search-placeholder" confirm-type="search" @confirm="onSearchSubmit"/>
				<image class="search-icon" :src="parseimage('企业列表/搜索.png')" mode="aspectFit" @tap="onSearchSubmit"/>
			</view>
			</view>
		</view>

		<!-- Enterprise List -->
		<scroll-view class="list-scroll-view" scroll-y enhanced :show-scrollbar="false" :style="listScrollStyle" :scroll-top="scrollTop" :lower-threshold="80" @scroll="onScroll" @scrolltolower="loadMore">
			<view class="list-container">
				<EnterpriseCard v-for="(enterprise, idx) in enterpriselist" :key="idx" :enterprise="enterprise" @tap="onEnterpriseTap(enterprise.id)"/>
				<view v-if="enterpriselist.length === 0 && !isLoading" class="empty-state">
					<text class="empty-text">暂无企业数据</text>
				</view>
				<view v-if="isLoading" class="loading-state">
					<text class="loading-text">加载中...</text>
				</view>
				<view v-if="isFinish && enterpriselist.length > 0" class="no-more-state">
					<text class="no-more-text">没有更多了</text>
				</view>
			</view>
		</scroll-view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, getCurrentInstance, nextTick, type CSSProperties } from "vue";

import { zonelist, sectorlist, levellist, enterpriselist, syncEnterpriseFilterState, enterpriseFilterState } from "../../../tapah/data";
import { parseimage, navigator } from "../../../tapah/function";
import { RequestEnterpriseList, serializeFilterParam } from "../../../tapah/request";
import EnterpriseCard from "../../../components/EnterpriseCard.vue";

type DimensionKey = "zone" | "level" | "sector";

let cachedZoneIds: number[] = [];
let cachedLevelIds: number[] = [];
let cachedSectorIds: number[] = [];
let cachedPage = 1;
let cachedSearch = "";
let cachedScrollTop = 0;
let cachedIsFinish = false;
let hasCache = false;

const zoneIds = ref<number[]>([]);
const levelIds = ref<number[]>([]);
const sectorIds = ref<number[]>([]);
const page = ref(1);
const search = ref("");
const scrollTop = ref(0);
const currentScrollTop = ref(0);
const isLoading = ref(false);
const isFinish = ref(false);
const listHeightPx = ref(0);

const instance = getCurrentInstance();

const listScrollStyle = computed((): CSSProperties => {
	if (listHeightPx.value <= 0) return {};
	return { height: `${listHeightPx.value}px` };
});

const updateListHeight = () => {
	nextTick(() => {
		if (!instance) return;
		uni.createSelectorQuery()
			.in(instance)
			.select(".enterprise-header")
			.boundingClientRect()
			.select(".enterprise-container")
			.boundingClientRect()
			.exec((res) => {
				const header = res[0] as UniApp.NodeInfo | null;
				const container = res[1] as UniApp.NodeInfo | null;
				if (header?.height != null && container?.height != null) {
					const gap = uni.upx2px(30);
					listHeightPx.value = Math.max(0, container.height - header.height - gap);
				}
			});
	});
};

const getFilterLabel = (placeholder: string, ids: number[], list: { id: number; value: string }[]) => {
	if (ids.length === 0) return placeholder;
	if (ids.length === 1) {
		const item = list.find((e) => e.id === ids[0]);
		return item?.value || placeholder;
	}
	return `已选${ids.length}项`;
};

const zoneLabel = computed(() => getFilterLabel("地区", zoneIds.value, zonelist.value));
const levelLabel = computed(() => getFilterLabel("档次", levelIds.value, levellist.value));
const sectorLabel = computed(() => getFilterLabel("行业", sectorIds.value, sectorlist.value));

const openEnterpriseFilter = (tab: DimensionKey) => {
	syncEnterpriseFilterState(zoneIds.value, levelIds.value, sectorIds.value, search.value);
	navigator("/mainpage/enterprisefilter", { tab });
};

const onEnterpriseFilterConfirmed = () => {
	const state = enterpriseFilterState.value;
	zoneIds.value = [...state.zones];
	levelIds.value = [...state.levels];
	sectorIds.value = [...state.sectors];
	search.value = state.search;
	getEnterpriseList();
};

const onSearchSubmit = () => {
	getEnterpriseList();
};

const onCategoryTap = (enttype: number, financial: number) => {
	navigator("/pages/mainpage/components/filter", { enttype, financial });
};

const onEnterpriseTap = (id: number) => {
	cacheCurrentState();
	navigator("/pages/enterprise/detail", { enterprise: id });
};

const onScroll = (e: any) => {
	currentScrollTop.value = e.detail.scrollTop;
};

const cacheCurrentState = () => {
	cachedZoneIds = [...zoneIds.value];
	cachedLevelIds = [...levelIds.value];
	cachedSectorIds = [...sectorIds.value];
	cachedPage = page.value;
	cachedSearch = search.value;
	cachedScrollTop = currentScrollTop.value;
	cachedIsFinish = isFinish.value;
	hasCache = true;
};

const restoreState = () => {
	if (hasCache) {
		zoneIds.value = [...cachedZoneIds];
		levelIds.value = [...cachedLevelIds];
		sectorIds.value = [...cachedSectorIds];
		page.value = cachedPage;
		search.value = cachedSearch;
		isFinish.value = cachedIsFinish;
		setTimeout(() => {
			scrollTop.value = cachedScrollTop;
		}, 100);
	}
};

const getEnterpriseList = async () => {
	if (isLoading.value) return;
	isLoading.value = true;
	page.value = 1;
	isFinish.value = false;
	enterpriselist.value = [];
	try {
		const [count, pagesize] = await RequestEnterpriseList(
			serializeFilterParam(zoneIds.value),
			serializeFilterParam(sectorIds.value),
			serializeFilterParam(levelIds.value),
			0,
			0,
			null,
			search.value,
			page.value
		);
		isFinish.value = count < pagesize;
	} catch (err) {
		console.error("Failed to load enterprises:", err);
	} finally {
		isLoading.value = false;
		cacheCurrentState();
		updateListHeight();
	}
};

const loadMore = async () => {
	if (isFinish.value || isLoading.value) return;
	isLoading.value = true;
	page.value++;
	try {
		const [count, pagesize] = await RequestEnterpriseList(
			serializeFilterParam(zoneIds.value),
			serializeFilterParam(sectorIds.value),
			serializeFilterParam(levelIds.value),
			0,
			0,
			null,
			search.value,
			page.value
		);
		isFinish.value = count < pagesize;
	} catch (err) {
		console.error("Failed to load more enterprises:", err);
	} finally {
		isLoading.value = false;
		cacheCurrentState();
	}
};

defineExpose({
	loadMore,
});

onMounted(() => {
	setTimeout(updateListHeight, 50);
	uni.$on("enterpriseFilterConfirmed", onEnterpriseFilterConfirmed);
	if (hasCache) {
		restoreState();
	} else {
		getEnterpriseList();
	}
});

onUnmounted(() => {
	uni.$off("enterpriseFilterConfirmed", onEnterpriseFilterConfirmed);
	cacheCurrentState();
});
</script>

<style scoped>
.enterprise-container {
	display: flex;
	flex-direction: column;
	width: 100%;
	height: 100%;
	min-height: 0;
	padding: 0 32rpx;
	background-color: #f8f8f8;
	box-sizing: border-box;
	overflow: hidden;
}

.enterprise-header {
	flex-shrink: 0;
}

.top-row {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	width: 100%;
	padding-top: 32rpx;
	box-sizing: border-box;
	gap: 16rpx;
}

.cat-img {
	flex: 1;
	width: 0;
	height: auto;
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

.list-scroll-view {
	flex-shrink: 0;
	width: 100%;
	margin-top: 30rpx;
}

.list-container {
	display: flex;
	flex-direction: column;
	padding-bottom: 20rpx;
	box-sizing: border-box;
}

.empty-state,
.loading-state,
.no-more-state {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 40rpx 0;
	width: 100%;
}

.empty-text,
.loading-text,
.no-more-text {
	font-size: 24rpx;
	color: #888888;
}
</style>
