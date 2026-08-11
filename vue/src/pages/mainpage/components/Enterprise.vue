<template>
	<view class="enterprise-container">
		<!-- Top category images -->
		<view class="top-row">
			<image
				class="cat-img"
				:src="parseimage('企业列表/央企国企.png')"
				mode="widthFix"
				@tap="onCategoryTap(1, 0)"
			/>
			<image
				class="cat-img"
				:src="parseimage('企业列表/金融机构.png')"
				mode="widthFix"
				@tap="onCategoryTap(0, 1)"
			/>
			<image
				class="cat-img"
				:src="parseimage('企业列表/成长企业.png')"
				mode="widthFix"
				@tap="onCategoryTap(2, 0)"
			/>
		</view>

		<!-- Filter and Search Row -->
		<view class="filter-row">
			<picker
				mode="selector"
				:range="zoneRange"
				range-key="value"
				:value="zoneIndex"
				@change="onZoneChange"
			>
				<view class="filter-item">
					<text class="filter-label">{{ zoneLabel }}</text>
					<image class="filter-arrow" :src="parseimage('企业列表/下箭头.png')" mode="aspectFit" />
				</view>
			</picker>

			<picker
				mode="selector"
				:range="levelRange"
				range-key="value"
				:value="levelIndex"
				@change="onLevelChange"
			>
				<view class="filter-item">
					<text class="filter-label">{{ levelLabel }}</text>
					<image class="filter-arrow" :src="parseimage('企业列表/下箭头.png')" mode="aspectFit" />
				</view>
			</picker>

			<picker
				mode="selector"
				:range="sectorRange"
				range-key="value"
				:value="sectorIndex"
				@change="onSectorChange"
			>
				<view class="filter-item">
					<text class="filter-label">{{ sectorLabel }}</text>
					<image class="filter-arrow" :src="parseimage('企业列表/下箭头.png')" mode="aspectFit" />
				</view>
			</picker>

			<view class="search-box">
				<input
					class="search-input"
					type="text"
					v-model="search"
					placeholder="搜索企业"
					placeholder-class="search-placeholder"
					confirm-type="search"
					@confirm="onSearchSubmit"
				/>
				<image
					class="search-icon"
					:src="parseimage('企业列表/搜索.png')"
					mode="aspectFit"
					@tap="onSearchSubmit"
				/>
			</view>
		</view>

		<!-- Enterprise List -->
		<scroll-view
			class="list-scroll-view"
			scroll-y
			:show-scrollbar="false"
			:scroll-top="scrollTop"
			:lower-threshold="80"
			@scroll="onScroll"
			@scrolltolower="loadMore"
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
							:src="parseEnterpriseIcon(`小图标/${enterprise.icon}.png`)"
							mode="aspectFit"
						/>
						<view v-else class="logo-placeholder"></view>
					</view>

					<view class="info-col">
						<text class="enterprise-name">{{ enterprise.name || "" }}</text>
						<text v-if="enterprise.englishname" class="enterprise-english-name">
							{{ enterprise.englishname }}
						</text>
						<scroll-view
							v-if="enterprise.tags && enterprise.tags.length > 0"
							class="tags-scroll"
							scroll-x
							:show-scrollbar="false"
							enable-flex
						>
							<view class="tags-row">
								<view
									class="tag-badge"
									v-for="(tag, tIdx) in enterprise.tags"
									:key="tIdx"
								>
									<text class="tag-text">{{ tag }}</text>
								</view>
							</view>
						</scroll-view>
						<view class="location-row">
							<image
								class="location-icon"
								:src="parseimage('企业列表/定位.png')"
								mode="aspectFit"
							/>
							<text class="location-text">
								{{ enterprise.zone?.value || "" }} {{ enterprise.city || "" }}
							</text>
						</view>
					</view>
				</view>

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
import { parseimage, parseEnterpriseIcon, navigator } from "../../../tapah/function";

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

const zoneLabel = computed(() => {
	if (zone.value === 0) return "地区";
	const item = zoneRange.value[zoneIndex.value];
	return item?.value || "地区";
});

const levelLabel = computed(() => {
	if (level.value === 0) return "档次";
	const item = levelRange.value[levelIndex.value];
	return item?.value || "档次";
});

const sectorLabel = computed(() => {
	if (sector.value === 0) return "行业";
	const item = sectorRange.value[sectorIndex.value];
	return item?.value || "行业";
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
	background-color: #f8f8f8;
	box-sizing: border-box;
}

.top-row {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	width: 100%;
	padding: 32rpx 40rpx 0 40rpx;
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
	margin: 20rpx 40rpx 0 40rpx;
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
	flex: 1;
	width: 100%;
	overflow: hidden;
	margin-top: 30rpx;
}

.list-container {
	display: flex;
	flex-direction: column;
	padding: 0 40rpx 20rpx 40rpx;
	box-sizing: border-box;
}

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
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.enterprise-english-name {
	font-size: 20rpx;
	font-weight: 400;
	color: #3d3d3d;
	line-height: 28rpx;
	margin-top: 4rpx;
	word-break: break-word;
	display: -webkit-box;
	-webkit-box-orient: vertical;
	-webkit-line-clamp: 2;
	overflow: hidden;
}

.tags-scroll {
	width: 100%;
	margin-top: 10rpx;
	overflow: hidden;
}

.tags-row {
	display: flex;
	flex-direction: row;
	flex-wrap: nowrap;
	align-items: center;
	gap: 3rpx;
}

.tag-badge {
	display: flex;
	align-items: center;
	justify-content: center;
	height: 32rpx;
	padding: 0 6rpx;
	background-color: #fef5e6;
	border-radius: 6rpx;
	flex-shrink: 0;
	box-sizing: border-box;
}

.tag-text {
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 400;
	color: #80500a;
	white-space: nowrap;
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
