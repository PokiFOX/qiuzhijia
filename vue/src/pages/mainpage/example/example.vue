<template>
	<view class="example-page">
		<!-- Search and Filter Row -->
		<view class="search-filter-row">
			<view class="search-col">
				<icon type="search" size="16" color="#888888" class="search-icon" />
				<input
					class="search-input"
					type="text"
					v-model="searchQuery"
					placeholder="搜索企业/岗位/专业"
					confirm-type="search"
					@input="onSearchInput"
				/>
			</view>

			<view class="filter-col" @tap="goCaseFilter">
				<text class="filter-text">筛选</text>
				<text class="arrow-down">▼</text>
			</view>
		</view>

		<view class="divider-space"></view>

		<!-- Case List Wrapper with Login Blur Option -->
		<view class="cases-wrapper">
			<view :class="['cases-list', { 'blur-content': !accountinfo }]">
				<view v-if="isInitialLoading" class="loading-state">
					<text class="loading-text">加载中...</text>
				</view>
				<view v-else-if="filteredCases.length === 0" class="empty-state">
					<text class="empty-text">暂无成功案例</text>
				</view>
				<template v-else>
					<CaseCard
						v-for="(c, idx) in filteredCases"
						:key="idx"
						:case-item="c"
					/>
				</template>

				<!-- Load More State -->
				<view v-if="isLoading" class="loading-state">
					<text class="loading-text">加载中...</text>
				</view>
				<view v-if="isFinish && filteredCases.length > 0" class="no-more-state">
					<text class="no-more-text">没有更多了</text>
				</view>
			</view>

			<!-- Login Blur Overlay -->
			<view v-if="!accountinfo" class="login-overlay">
				<button open-type="getPhoneNumber" @getphonenumber="onGetPhoneNumber" class="login-btn">
					请先登录再查看
				</button>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from "vue";
import { onLoad, onReachBottom } from "@dcloudio/uni-app";
import { caselist, accountinfo } from "../../../tapah/data";
import { RequestCaseList, RequestWxCode, RequestUserInfo } from "../../../tapah/request";
import { navigator } from "../../../tapah/function";
import CaseCard from "../../../components/CaseCard.vue";

const searchQuery = ref("");
const level = ref(0);
const sector = ref(0);
const stag1 = ref(0);
const stag2 = ref(0);
const year = ref(0);
const page = ref(1);

const isInitialLoading = ref(true);
const isLoading = ref(false);
const isFinish = ref(false);

const filteredCases = computed(() => {
	return caselist.value.filter((c) => {
		if (searchQuery.value.trim().length === 0) return true;
		const query = searchQuery.value.trim().toLowerCase();
		return (
			(c.student || "").toLowerCase().includes(query) ||
			(c.entname || "").toLowerCase().includes(query) ||
			(c.name || "").toLowerCase().includes(query) ||
			(c.field1 || "").toLowerCase().includes(query) ||
			(c.field2 || "").toLowerCase().includes(query) ||
			(c.school1 || "").toLowerCase().includes(query) ||
			(c.school2 || "").toLowerCase().includes(query)
		);
	});
});

const onSearchInput = () => {
	// Handled reactively by computed property
};

const goCaseFilter = () => {
	navigator("/mainpage/casefilter", {
		stag1: stag1.value,
		stag2: stag2.value,
		year: year.value,
		level: level.value,
		sector: sector.value,
	});
};

const onGetPhoneNumber = async (e: any) => {
	const code = e.detail.code;
	if (code) {
		try {
			await RequestWxCode(code);
			loadCases();
		} catch (err) {
			console.error("Failed to login:", err);
			uni.showToast({ title: "登录失败", icon: "none" });
		}
	} else {
		uni.showToast({ title: "获取手机号失败", icon: "none" });
	}
};

const loadCases = async () => {
	page.value = 1;
	isFinish.value = false;
	caselist.value = [];
	isInitialLoading.value = true;
	try {
		const [count, pagesize] = await RequestCaseList(
			0,
			level.value,
			sector.value,
			0,
			stag1.value,
			stag2.value,
			year.value,
			page.value
		);
		isFinish.value = count < pagesize;
	} catch (err) {
		console.error("Failed to load cases:", err);
	} finally {
		isInitialLoading.value = false;
	}
};

const loadMore = async () => {
	if (isFinish.value || isLoading.value) return;
	isLoading.value = true;
	const nextPage = page.value + 1;
	try {
		const [count, pagesize] = await RequestCaseList(
			0,
			level.value,
			sector.value,
			0,
			stag1.value,
			stag2.value,
			year.value,
			nextPage
		);
		isFinish.value = count < pagesize;
		page.value = nextPage;
	} catch (err) {
		console.error("Failed to load more cases:", err);
	} finally {
		isLoading.value = false;
	}
};

// Handle return value from CaseFilter page
const onCaseFilterSelected = (selections: number[]) => {
	stag1.value = selections[0] || 0;
	stag2.value = selections[1] || 0;
	year.value = selections[2] || 0;
	level.value = selections[3] || 0;
	sector.value = selections[4] || 0;
	loadCases();
};

onMounted(() => {
	uni.$on("caseFilterSelected", onCaseFilterSelected);
	uni.setNavigationBarTitle({
		title: "过往案例",
	});
	if (accountinfo.value) {
		loadCases();
	} else {
		isInitialLoading.value = false;
	}
});

onUnmounted(() => {
	uni.$off("caseFilterSelected", onCaseFilterSelected);
});

onReachBottom(() => {
	loadMore();
});
</script>

<style scoped>
.example-page {
	display: flex;
	flex-direction: column;
	width: 100vw;
	min-height: 100vh;
	background-color: #f8f8f8;
	box-sizing: border-box;
}

/* Search and Filter Row */
.search-filter-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	padding: 20rpx;
	box-sizing: border-box;
}

.search-col {
	flex: 1;
	display: flex;
	flex-direction: row;
	align-items: center;
	background-color: #ffffff;
	border-radius: 20rpx;
	padding: 0 24rpx;
	height: 100rpx;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
	box-sizing: border-box;
}

.search-icon {
	margin-right: 12rpx;
}

.search-input {
	flex: 1;
	font-size: 28rpx;
	color: #333333;
	height: 100%;
}

.filter-col {
	width: 200rpx;
	height: 100rpx;
	background-color: #ffffff;
	border-radius: 20rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	margin-left: 20rpx;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
}

.filter-text {
	font-size: 28rpx;
	color: #666666;
	margin-right: 8rpx;
}

.arrow-down {
	font-size: 16rpx;
	color: #888888;
}

.divider-space {
	height: 10rpx;
}

/* Case List Wrapper */
.cases-wrapper {
	position: relative;
	flex: 1;
	width: 100%;
	min-height: 400rpx;
}

.cases-list {
	display: flex;
	flex-direction: column;
	gap: 20rpx;
	padding: 0 40rpx 40rpx 40rpx;
	box-sizing: border-box;
}

.blur-content {
	filter: blur(12px);
	pointer-events: none;
}

/* Login Overlay */
.login-overlay {
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	display: flex;
	align-items: center;
	justify-content: center;
	background-color: rgba(0, 0, 0, 0.05);
	z-index: 10;
}

.login-btn {
	background-color: rgba(0, 0, 0, 0.65);
	color: #ffffff;
	font-size: 32rpx;
	font-weight: 600;
	border-radius: 16rpx;
	padding: 24rpx 48rpx;
	line-height: 1;
	border: none;
}

/* States */
.loading-state,
.empty-state,
.no-more-state {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 40rpx 0;
}

.loading-text,
.empty-text,
.no-more-text {
	font-size: 28rpx;
	color: #888888;
}
</style>
