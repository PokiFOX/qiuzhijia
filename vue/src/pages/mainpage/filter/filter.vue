<template>
	<view class="filter-page">
		<!-- Filter and Search Row -->
		<view class="filter-row">
			<view class="search-col">
				<icon type="search" size="16" color="#888888" class="search-icon" />
				<input
					class="search-input"
					type="text"
					v-model="search"
					placeholder="请输入企业名称"
					confirm-type="search"
					@confirm="onSearchSubmit"
				/>
			</view>

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
		</view>

		<view class="divider-space-small"></view>

		<!-- Enterprise List -->
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
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { onLoad, onReachBottom } from "@dcloudio/uni-app";
import { zonelist, enterpriselist } from "../../../tapah/data";
import { RequestEnterpriseList } from "../../../tapah/request";
import { parseimage, navigator } from "../../../tapah/function";

const zone = ref(0);
const page = ref(1);
const search = ref("");
const enttype = ref(0);
const financial = ref(false);
const isLoading = ref(false);
const isFinish = ref(false);

const zoneRange = computed(() => [{ id: 0, value: "地区" }, ...zonelist.value]);

const zoneIndex = computed(() => {
	const idx = zoneRange.value.findIndex((item) => item.id === zone.value);
	return idx >= 0 ? idx : 0;
});

const onZoneChange = (e: any) => {
	const idx = parseInt(e.detail.value, 10);
	zone.value = zoneRange.value[idx]?.id || 0;
	getEnterpriseList();
};

const onSearchSubmit = () => {
	getEnterpriseList();
};

const onEnterpriseTap = (id: number) => {
	navigator("/enterprise/detail", { enterprise: id });
};

const getEnterpriseList = async () => {
	if (isLoading.value) return;
	isLoading.value = true;
	page.value = 1;
	enterpriselist.value = [];
	try {
		const [count, pagesize] = await RequestEnterpriseList(
			zone.value,
			0,
			0,
			enttype.value,
			0,
			financial.value,
			search.value,
			page.value
		);
		isFinish.value = count < pagesize;
	} catch (err) {
		console.error("Failed to load enterprises:", err);
	} finally {
		isLoading.value = false;
	}
};

const loadMore = async () => {
	if (isFinish.value || isLoading.value) return;
	isLoading.value = true;
	page.value++;
	try {
		const [count, pagesize] = await RequestEnterpriseList(
			zone.value,
			0,
			0,
			enttype.value,
			0,
			financial.value,
			search.value,
			page.value
		);
		isFinish.value = count < pagesize;
	} catch (err) {
		console.error("Failed to load more enterprises:", err);
	} finally {
		isLoading.value = false;
	}
};

onLoad((options) => {
	if (options) {
		if (options.enttype) {
			enttype.value = parseInt(options.enttype, 10) || 0;
		}
		if (options.financial) {
			financial.value = options.financial === "1" || options.financial === "true";
		}
	}

	// Set dynamic navigation bar title
	let rowname = "企业列表";
	if (enttype.value === 1) rowname = "国有企业";
	if (enttype.value === 2) rowname = "中央企业";
	if (enttype.value === 0 && financial.value) rowname = "金融企业";

	uni.setNavigationBarTitle({
		title: rowname,
	});

	getEnterpriseList();
});

onReachBottom(() => {
	loadMore();
});
</script>

<style scoped>
.filter-page {
	display: flex;
	flex-direction: column;
	width: 100vw;
	min-height: 100vh;
	background-color: #f8f8f8;
	box-sizing: border-box;
}

/* Filter and Search Row */
.filter-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	background-color: #ffffff;
	border-radius: 20rpx;
	height: 100rpx;
	margin: 20rpx;
	padding: 0 10rpx;
	box-sizing: border-box;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
}

.search-col {
	flex: 1;
	display: flex;
	flex-direction: row;
	align-items: center;
	padding-left: 16rpx;
}

.search-icon {
	margin-right: 12rpx;
}

.search-input {
	flex: 1;
	font-size: 26rpx;
	color: #333333;
	height: 60rpx;
}

.dropdown-col {
	width: 150rpx;
	height: 40rpx;
	border-left: 1rpx solid #eeeeee;
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
	max-width: 100rpx;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.arrow-down {
	font-size: 16rpx;
	color: #888888;
}

.divider-space-small {
	height: 10rpx;
}

/* List Container */
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
