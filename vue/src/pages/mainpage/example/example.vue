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
				<view
					v-else
					class="case-card"
					v-for="(c, idx) in filteredCases"
					:key="idx"
				>
					<view class="case-header">
						<text class="student-name">{{ c.student || "" }}</text>
						<view class="student-target-col">
							<text class="target-entname">{{ c.entname || "" }}</text>
							<text class="target-position">{{ c.name }}</text>
						</view>
					</view>

					<view class="case-tags-row">
						<view class="case-tags-left">
							<view
								v-for="(tag, tIdx) in c.tags.filter(t => t.trim() !== '')"
								:key="tIdx"
								:class="['case-tag-badge', `tag-color-${tIdx % 3}`]"
							>
								<text class="case-tag-text">{{ tag }}</text>
							</view>
						</view>
						<text class="case-expand-toggle" @tap="toggleCaseExpand(idx)">
							{{ expandedCases[idx] ? "收起" : "展开" }}
						</text>
					</view>

					<!-- Expanded Case Details -->
					<view class="case-expanded-details" v-if="expandedCases[idx]">
						<view class="case-divider"></view>
						
						<view class="detail-section-title">
							<view class="title-indicator"></view>
							<text class="title-text">基础信息</text>
						</view>

						<view class="detail-table">
							<view class="detail-row">
								<text class="detail-label">· 学生姓名</text>
								<text class="detail-value">{{ c.student || "--" }}</text>
							</view>
							<view class="detail-row">
								<text class="detail-label">· 本科院校</text>
								<text class="detail-value">{{ c.school1 || "--" }}</text>
							</view>
							<view class="detail-row">
								<text class="detail-label">· 本科层次</text>
								<text class="detail-value">{{ stagStr(c.stag1) }}</text>
							</view>
							<view class="detail-row">
								<text class="detail-label">· 本科专业</text>
								<text
									:class="['detail-value', { 'text-blue': c.field1 }]"
									@tap="onFieldTapByName(c.field1)"
								>
									{{ c.field1 || "--" }}
								</text>
							</view>
							<view class="detail-row">
								<text class="detail-label">· 硕士院校</text>
								<text class="detail-value">{{ c.school2 || "--" }}</text>
							</view>
							<view class="detail-row">
								<text class="detail-label">· 硕士层次</text>
								<text class="detail-value">{{ stagStr(c.stag2) }}</text>
							</view>
							<view class="detail-row">
								<text class="detail-label">· 硕士专业</text>
								<text
									:class="['detail-value', { 'text-blue': c.field2 }]"
									@tap="onFieldTapByName(c.field2)"
								>
									{{ c.field2 || "--" }}
								</text>
							</view>
							<view class="detail-row">
								<text class="detail-label">· 主要实习</text>
								<view class="detail-value list-value">
									<text v-for="(s, sIdx) in (c.detail ? c.detail.split(',') : [])" :key="sIdx" class="internship-item">
										{{ s.trim() }}
									</text>
									<text v-if="!c.detail">--</text>
								</view>
							</view>
						</view>

						<view class="detail-section-title margin-top-sm">
							<view class="title-indicator"></view>
							<text class="title-text">求职结果</text>
						</view>

						<view class="result-info">
							<view class="result-row">
								<text class="result-label">· 去向单位</text>
								<text class="result-value text-blue" @tap="onEnterpriseTapByName(c.entname)">
									{{ c.entname || "--" }}
								</text>
							</view>
							<text class="result-text">· 所在部门 &nbsp;&nbsp;&nbsp;&nbsp;{{ c.dep || "--" }}</text>
							<text class="result-text">· 录取岗位 &nbsp;&nbsp;&nbsp;&nbsp;{{ c.name }}</text>
						</view>
					</view>
				</view>

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
import { caselist, accountinfo, fieldlist, enterpriselist } from "../../../tapah/data";
import { RequestCaseList, RequestWxCode, RequestEnterprise, RequestUserInfo } from "../../../tapah/request";
import { navigator, stagStr } from "../../../tapah/function";
import type { Case } from "../../../tapah/class";

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
const expandedCases = ref<Record<number, boolean>>({});

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

const toggleCaseExpand = (idx: number) => {
	expandedCases.value[idx] = !expandedCases.value[idx];
};

const onFieldTapByName = (name?: string) => {
	if (!name) return;
	const field = fieldlist.value.find((f) => f.value === name);
	if (field) {
		navigator("/mainpage/fielddetail", { field: field.id });
	}
};

const onEnterpriseTapByName = async (name?: string) => {
	if (!name) return;
	const found = enterpriselist.value.find((e) => e.name === name);
	if (found) {
		navigator("/pages/enterprise/detail", { enterprise: found.id });
	} else {
		try {
			const list = await RequestEnterprise(0, 0, 0, 0, 0, null, name, 1);
			if (list.length > 0) {
				navigator("/pages/enterprise/detail", { enterprise: list[0].id });
			}
		} catch (err) {
			console.error("Failed to find enterprise by name:", err);
		}
	}
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
	padding: 0 40rpx 40rpx 40rpx;
	box-sizing: border-box;
}

.blur-content {
	filter: blur(12px);
	pointer-events: none;
}

.case-card {
	background-color: #ffffff;
	border-radius: 16rpx;
	padding: 20rpx;
	margin-bottom: 20rpx;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
	box-sizing: border-box;
}

.case-header {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	margin-bottom: 10rpx;
}

.student-name {
	font-size: 30rpx;
	font-weight: bold;
	color: #2d7bff;
	width: 140rpx;
	flex-shrink: 0;
}

.student-target-col {
	flex: 1;
	display: flex;
	flex-direction: column;
}

.target-entname {
	font-size: 30rpx;
	font-weight: bold;
	color: #333333;
	line-height: 1.2;
}

.target-position {
	font-size: 20rpx;
	font-weight: bold;
	color: #333333;
	margin-top: 4rpx;
}

.case-tags-row {
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	align-items: center;
}

.case-tags-left {
	display: flex;
	flex-direction: row;
	flex-wrap: wrap;
	flex: 1;
}

.case-tag-badge {
	border-radius: 8rpx;
	padding: 4rpx 12rpx;
	margin-right: 10rpx;
	margin-bottom: 6rpx;
}

.tag-color-0 {
	background-color: #e8f0fe;
}
.tag-color-0 .case-tag-text {
	color: #2d7bff;
}

.tag-color-1 {
	background-color: #feeddf;
}
.tag-color-1 .case-tag-text {
	color: #692e1f;
}

.tag-color-2 {
	background-color: #f3eeff;
}
.tag-color-2 .case-tag-text {
	color: #6b21a8;
}

.case-tag-text {
	font-size: 22rpx;
}

.case-expand-toggle {
	font-size: 24rpx;
	color: #2d7bff;
	margin-left: 20rpx;
	flex-shrink: 0;
}

/* Expanded Case Details */
.case-expanded-details {
	display: flex;
	flex-direction: column;
}

.case-divider {
	height: 1rpx;
	background-color: #eeeeee;
	margin: 16rpx 0;
}

.detail-section-title {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-bottom: 12rpx;
}

.title-indicator {
	width: 6rpx;
	height: 24rpx;
	background-color: #2d7bff;
	margin-right: 16rpx;
}

.title-text {
	font-size: 26rpx;
	font-weight: bold;
	color: #333333;
}

.detail-table {
	display: flex;
	flex-direction: column;
	margin-bottom: 20rpx;
}

.detail-row {
	display: flex;
	flex-direction: row;
	padding: 6rpx 0;
	font-size: 24rpx;
}

.detail-label {
	width: 160rpx;
	color: #555555;
}

.detail-value {
	flex: 1;
	color: #555555;
}

.list-value {
	display: flex;
	flex-direction: column;
}

.internship-item {
	margin-bottom: 4rpx;
}

.margin-top-sm {
	margin-top: 10rpx;
}

.result-info {
	display: flex;
	flex-direction: column;
}

.result-row {
	display: flex;
	flex-direction: row;
	padding: 4rpx 0;
	font-size: 24rpx;
}

.result-label {
	width: 160rpx;
	color: #555555;
}

.result-value {
	flex: 1;
	color: #555555;
}

.result-text {
	font-size: 24rpx;
	color: #555555;
	padding: 4rpx 0;
}

.text-blue {
	color: #2d7bff !important;
	font-weight: bold;
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
