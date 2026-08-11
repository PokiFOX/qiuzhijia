<template>
	<view class="enterprise-container">
		<!-- Top Gradient Category Buttons -->
		<view class="top-row">
			<view class="cat-btn red-gradient" @tap="onCategoryTap(1, 0)">
				<text class="cat-btn-text">国有企业</text>
			</view>
			<view class="cat-btn orange-gradient" @tap="onCategoryTap(2, 0)">
				<text class="cat-btn-text">中央企业</text>
			</view>
			<view class="cat-btn green-gradient" @tap="onCategoryTap(0, 1)">
				<text class="cat-btn-text">金融机构</text>
			</view>
		</view>

		<view class="divider-space-small"></view>

		<!-- Filter and Search Row -->
		<view class="filter-row">
			<view class="dropdown-col">
				<picker
					mode="selector"
					:range="zoneRange"
					range-key="value"
					:value="zoneIndex"
					@change="onZoneChange"
				>
					<view class="picker-view">
						<text class="picker-text">{{ zoneRange[zoneIndex]?.value || "地区" }}</text>
						<text class="arrow-down">▼</text>
					</view>
				</picker>
			</view>

			<view class="dropdown-col">
				<picker
					mode="selector"
					:range="levelRange"
					range-key="value"
					:value="levelIndex"
					@change="onLevelChange"
				>
					<view class="picker-view">
						<text class="picker-text">{{ levelRange[levelIndex]?.value || "档次" }}</text>
						<text class="arrow-down">▼</text>
					</view>
				</picker>
			</view>

			<view class="dropdown-col">
				<picker
					mode="selector"
					:range="sectorRange"
					range-key="value"
					:value="sectorIndex"
					@change="onSectorChange"
				>
					<view class="picker-view">
						<text class="picker-text">{{ sectorRange[sectorIndex]?.value || "行业" }}</text>
						<text class="arrow-down">▼</text>
					</view>
				</picker>
			</view>

			<view class="search-col">
				<input
					class="search-input"
					type="text"
					v-model="search"
					placeholder="搜索企业"
					confirm-type="search"
					@confirm="onSearchSubmit"
				/>
				<view class="search-icon-btn" @tap="onSearchSubmit">
					<icon type="search" size="16" color="#2D7BFF" />
				</view>
			</view>
		</view>

		<view class="divider-space-small"></view>

		<!-- Enterprise List -->
		<scroll-view
			class="list-scroll-view"
			scroll-y
			:scroll-top="scrollTop"
			@scroll="onScroll"
		>
			<view class="list-container">
				<view
					class="enterprise-card"
					v-for="(enterprise, idx) in enterpriselist"
					:key="idx"
					@tap="onEnterpriseTap(enterprise.id)"
				>
					<view class="logo-col">
						<image
							v-if="enterprise.icon"
							class="enterprise-logo"
							:src="parseimage(`小图标/${enterprise.icon}.png`)"
							mode="aspectFit"
						/>
						<view v-else class="logo-placeholder"></view>
					</view>

					<view class="info-col">
						<text class="enterprise-name">{{ enterprise.name || "" }}</text>
						<text v-if="enterprise.englishname" class="enterprise-english-name">
							{{ enterprise.englishname }}
						</text>
						<view v-if="enterprise.tags && enterprise.tags.length > 0" class="tags-row">
							<view
								class="tag-badge"
								v-for="(tag, tIdx) in enterprise.tags"
								:key="tIdx"
							>
								<text class="tag-text">{{ tag }}</text>
							</view>
						</view>
						<text class="location-text">
							{{ enterprise.zone?.value || "" }} {{ enterprise.city || "" }}
						</text>
					</view>
				</view>

				<!-- Loading and Empty States -->
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
import { ref, computed, onMounted, onUnmounted } from "vue";
import { zonelist, sectorlist, levellist, enterpriselist } from "../../../tapah/data";
import { RequestEnterpriseList } from "../../../tapah/request";
import { parseimage, navigator } from "../../../tapah/function";

// Cache variables outside component instance to persist across tab switches
let cachedZone = 0;
let cachedSector = 0;
let cachedLevel = 0;
let cachedPage = 1;
let cachedSearch = "";
let cachedScrollTop = 0;
let cachedIsFinish = false;
let hasCache = false;

const zone = ref(0);
const sector = ref(0);
const level = ref(0);
const page = ref(1);
const search = ref("");
const scrollTop = ref(0);
const currentScrollTop = ref(0);
const isLoading = ref(false);
const isFinish = ref(false);

// Dropdown ranges
const zoneRange = computed(() => [{ id: 0, value: "地区" }, ...zonelist.value]);
const levelRange = computed(() => [{ id: 0, value: "档次" }, ...levellist.value]);
const sectorRange = computed(() => [{ id: 0, value: "行业" }, ...sectorlist.value]);

const zoneIndex = computed(() => {
	const idx = zoneRange.value.findIndex((item) => item.id === zone.value);
	return idx >= 0 ? idx : 0;
});

const levelIndex = computed(() => {
	const idx = levelRange.value.findIndex((item) => item.id === level.value);
	return idx >= 0 ? idx : 0;
});

const sectorIndex = computed(() => {
	const idx = sectorRange.value.findIndex((item) => item.id === sector.value);
	return idx >= 0 ? idx : 0;
});

const onZoneChange = (e: any) => {
	const idx = parseInt(e.detail.value, 10);
	zone.value = zoneRange.value[idx]?.id || 0;
	getEnterpriseList();
};

const onLevelChange = (e: any) => {
	const idx = parseInt(e.detail.value, 10);
	level.value = levelRange.value[idx]?.id || 0;
	getEnterpriseList();
};

const onSectorChange = (e: any) => {
	const idx = parseInt(e.detail.value, 10);
	sector.value = sectorRange.value[idx]?.id || 0;
	getEnterpriseList();
};

const onSearchSubmit = () => {
	getEnterpriseList();
};

const onCategoryTap = (enttype: number, financial: number) => {
	navigator("/mainpage/filter", { enttype, financial });
};

const onEnterpriseTap = (id: number) => {
	cacheCurrentState();
	navigator("/enterprise/detail", { enterprise: id });
};

const onScroll = (e: any) => {
	currentScrollTop.value = e.detail.scrollTop;
};

const cacheCurrentState = () => {
	cachedZone = zone.value;
	cachedSector = sector.value;
	cachedLevel = level.value;
	cachedPage = page.value;
	cachedSearch = search.value;
	cachedScrollTop = currentScrollTop.value;
	cachedIsFinish = isFinish.value;
	hasCache = true;
};

const restoreState = () => {
	if (hasCache) {
		zone.value = cachedZone;
		sector.value = cachedSector;
		level.value = cachedLevel;
		page.value = cachedPage;
		search.value = cachedSearch;
		isFinish.value = cachedIsFinish;
		// Use nextTick to ensure list scroll-view has rendered
		setTimeout(() => {
			scrollTop.value = cachedScrollTop;
		}, 100);
	}
};

const getEnterpriseList = async () => {
	if (isLoading.value) return;
	isLoading.value = true;
	page.value = 1;
	enterpriselist.value = [];
	try {
		const [count, pagesize] = await RequestEnterpriseList(
			zone.value,
			sector.value,
			level.value,
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
	}
};

const loadMore = async () => {
	if (isFinish.value || isLoading.value) return;
	isLoading.value = true;
	page.value++;
	try {
		const [count, pagesize] = await RequestEnterpriseList(
			zone.value,
			sector.value,
			level.value,
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

// Expose loadMore for parent onReachBottom
defineExpose({
	loadMore,
});

onMounted(() => {
	if (hasCache) {
		restoreState();
	} else {
		getEnterpriseList();
	}
});

onUnmounted(() => {
	cacheCurrentState();
});
</script>

<style scoped>
.enterprise-container {
	display: flex;
	flex-direction: column;
	width: 100vw;
	height: 100%;
	background-color: #e2edff;
	box-sizing: border-box;
}

/* Top Gradient Buttons */
.top-row {
	display: flex;
	flex-direction: row;
	justify-content: space-around;
	width: 100%;
	padding: 20rpx 20rpx 0 20rpx;
	box-sizing: border-box;
}

.cat-btn {
	display: flex;
	align-items: center;
	justify-content: center;
	width: 220rpx;
	height: 112rpx;
	border-radius: 12rpx;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.05);
}

.red-gradient {
	background: linear-gradient(to left, #da2f35, #ffc1c3);
}

.orange-gradient {
	background: linear-gradient(to left, #ffa600, #feefd1);
}

.green-gradient {
	background: linear-gradient(to left, #4ec67b, #b9ffd3);
}

.cat-btn-text {
	font-size: 32rpx;
	font-weight: bold;
	color: #ffffff;
}

.divider-space-small {
	height: 20rpx;
}

/* Filter and Search Row */
.filter-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	background-color: #ffffff;
	border-radius: 20rpx;
	height: 100rpx;
	margin: 0 20rpx;
	padding: 0 10rpx;
	box-sizing: border-box;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
}

.dropdown-col {
	width: 130rpx;
	height: 40rpx;
	border-right: 1rpx solid #eeeeee;
	display: flex;
	align-items: center;
	justify-content: center;
}

.picker-view {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	width: 100%;
}

.picker-text {
	font-size: 26rpx;
	color: #333333;
	margin-right: 4rpx;
	max-width: 90rpx;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.arrow-down {
	font-size: 16rpx;
	color: #888888;
}

.search-col {
	flex: 1;
	display: flex;
	flex-direction: row;
	align-items: center;
	padding-left: 16rpx;
}

.search-input {
	flex: 1;
	font-size: 26rpx;
	color: #333333;
	height: 60rpx;
}

.search-icon-btn {
	display: flex;
	align-items: center;
	justify-content: center;
	width: 60rpx;
	height: 60rpx;
}

/* List Scroll View */
.list-scroll-view {
	flex: 1;
	width: 100%;
	overflow: hidden;
}

.list-container {
	display: flex;
	flex-direction: column;
	padding: 0 20rpx 20rpx 20rpx;
	box-sizing: border-box;
}

/* Enterprise Card */
.enterprise-card {
	display: flex;
	flex-direction: row;
	background-color: #ffffff;
	border-radius: 16rpx;
	padding: 20rpx;
	margin-bottom: 20rpx;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
	box-sizing: border-box;
}

.logo-col {
	display: flex;
	align-items: center;
	justify-content: center;
	width: 90rpx;
	height: 90rpx;
	margin-right: 20rpx;
	flex-shrink: 0;
}

.enterprise-logo {
	width: 90rpx;
	height: 90rpx;
}

.logo-placeholder {
	width: 90rpx;
	height: 90rpx;
	background-color: #e0e0e0;
	border-radius: 8rpx;
}

.info-col {
	flex: 1;
	display: flex;
	flex-direction: column;
	overflow: hidden;
}

.enterprise-name {
	font-size: 36rpx;
	font-weight: bold;
	color: #333333;
	line-height: 1.2;
	margin-bottom: 6rpx;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.enterprise-english-name {
	font-size: 22rpx;
	color: #888888;
	line-height: 1.3;
	margin-bottom: 8rpx;
	overflow: hidden;
	text-overflow: ellipsis;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
}

.tags-row {
	display: flex;
	flex-direction: row;
	flex-wrap: wrap;
	margin-bottom: 12rpx;
}

.tag-badge {
	background-color: #feeddf;
	border-radius: 8rpx;
	padding: 4rpx 16rpx;
	margin-right: 12rpx;
	margin-bottom: 8rpx;
}

.tag-text {
	font-size: 20rpx;
	color: #692e1f;
}

.location-text {
	font-size: 20rpx;
	color: #666666;
	margin-top: auto;
}

/* States */
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
