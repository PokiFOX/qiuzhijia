<template>
	<view class="field-detail-page" v-if="field">
		<!-- Sticky Tab Header -->
		<view class="sticky-tab-bar">
			<view
				v-for="(tab, index) in tabs"
				:key="index"
				:class="['tab-item', { 'tab-item-active': activeTab === index }]"
				@tap="scrollToSection(index)"
			>
				<text :class="['tab-text', { 'tab-text-active': activeTab === index }]">
					{{ tab }}
				</text>
				<view :class="['tab-line', { 'tab-line-active': activeTab === index }]"></view>
			</view>
		</view>

		<!-- Content Sections -->
		<view class="sections-container">
			<!-- Section 0: 专业详情 -->
			<view id="section-0" class="section-card">
				<view class="field-info-card">
					<text class="field-title">{{ field.value }}</text>
					<text class="field-subtitle">学科门类: {{ field.type }}</text>
					<view class="stars-row">
						<text class="stars-label">专业热门度:</text>
						<text class="star-icon" v-for="n in field.star" :key="n">★</text>
					</view>
					<view :class="['field-desc', { 'field-desc-collapsed': !isDescExpanded }]">
						<text>{{ field.content }}</text>
					</view>
					<view class="expand-btn-row" v-if="field.content && field.content.length > 100">
						<text class="expand-btn-text" @tap="isDescExpanded = !isDescExpanded">
							{{ isDescExpanded ? "收起" : "展开" }}
						</text>
					</view>
				</view>
			</view>

			<view class="section-divider"></view>

			<!-- Section 1: 对口企业 -->
			<view id="section-1" class="section-card">
				<view class="section-header">
					<view class="title-indicator"></view>
					<text class="section-title">对口企业</text>
				</view>

				<view v-if="isLoading" class="loading-state">
					<text class="loading-text">加载中...</text>
				</view>
				<view v-else-if="enterprises.length === 0" class="empty-state">
					<text class="empty-text">暂无对口企业数据</text>
				</view>
				<view v-else class="enterprise-list">
					<view
						class="enterprise-item"
						v-for="(ent, idx) in enterprises"
						:key="idx"
						@tap="onEnterpriseTap(ent.id)"
					>
						<image
							v-if="ent.icon"
							class="enterprise-logo"
							:src="parseimage(`小图标/${ent.icon}.png`)"
							mode="aspectFit"
						/>
						<view v-else class="logo-placeholder"></view>
						<view class="enterprise-info">
							<text class="enterprise-name">{{ ent.name || "" }}</text>
							<text class="enterprise-english" v-if="ent.englishname">{{ ent.englishname }}</text>
							<view class="enterprise-tags" v-if="ent.tags && ent.tags.length > 0">
								<view class="tag-badge" v-for="(tag, tIdx) in ent.tags" :key="tIdx">
									<text class="tag-text">{{ tag }}</text>
								</view>
							</view>
							<text class="enterprise-location">
								{{ ent.zone?.value || "" }} {{ ent.city || "" }}
							</text>
						</view>
					</view>
					<view class="load-more-row" v-if="hasMoreEnterprise" @tap="loadMoreEnterprise">
						<text class="load-more-text">点击加载更多企业...</text>
					</view>
				</view>
			</view>

			<view class="section-divider"></view>

			<!-- Section 2: 成功案例 -->
			<view id="section-2" class="section-card">
				<view class="section-header">
					<view class="title-indicator"></view>
					<text class="section-title">成功案例</text>
				</view>

				<view class="cases-wrapper">
					<view :class="['cases-list', { 'blur-content': !accountinfo }]">
						<view v-if="isLoading" class="loading-state">
							<text class="loading-text">加载中...</text>
						</view>
						<view v-else-if="cases.length === 0" class="empty-state">
							<text class="empty-text">暂无成功案例数据</text>
						</view>
						<view
							v-else
							class="case-card"
							v-for="(c, idx) in cases"
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
									<view class="title-indicator-small"></view>
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
										<text class="detail-value">{{ c.field1 || "--" }}</text>
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
										<text class="detail-value">{{ c.field2 || "--" }}</text>
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
									<view class="title-indicator-small"></view>
									<text class="title-text">求职结果</text>
								</view>

								<view class="result-info">
									<text class="result-text">· 去向单位 &nbsp;&nbsp;&nbsp;&nbsp;{{ c.entname || "--" }}</text>
									<text class="result-text">· 所在部门 &nbsp;&nbsp;&nbsp;&nbsp;{{ c.dep || "--" }}</text>
									<text class="result-text">· 录取岗位 &nbsp;&nbsp;&nbsp;&nbsp;{{ c.name }}</text>
								</view>
							</view>
						</view>

						<view class="load-more-row" v-if="hasMoreCase" @tap="loadMoreCase">
							<text class="load-more-text">点击加载更多案例...</text>
						</view>
					</view>

					<!-- Login Blur Overlay -->
					<view v-if="!accountinfo" class="login-overlay">
						<button open-type="getPhoneNumber" @getphonenumber="onGetPhoneNumber" class="login-btn">
							请先登录后查看
						</button>
					</view>
				</view>
			</view>
		</view>

		<!-- Bottom Navigation Bar -->
		<view class="bottom-nav-bar">
			<view class="nav-item-home" @tap="goHome">
				<image class="nav-icon" :src="parseimage('企业详情/首页.png')" mode="aspectFit" />
				<text class="nav-text">首页</text>
			</view>

			<view class="nav-item-fav">
				<button
					v-if="!accountinfo"
					open-type="getPhoneNumber"
					@getphonenumber="onGetPhoneNumber"
					class="fav-btn-unlogged"
				>
					<image class="nav-icon" :src="parseimage('企业详情/关注.png')" mode="aspectFit" />
					<text class="nav-text">关注</text>
				</button>
				<view v-else class="fav-btn-logged" @tap="toggleFavorite">
					<image
						class="nav-icon"
						:src="parseimage(isFavorited ? '企业详情/已收藏.png' : '企业详情/关注.png')"
						mode="aspectFit"
					/>
					<text class="nav-text">{{ isFavorited ? "已收藏" : "关注" }}</text>
				</view>
			</view>

			<view class="nav-btn-consult" @tap="goConsult">
				<text class="consult-btn-text">在线咨询</text>
			</view>

			<view class="nav-btn-phone" @tap="callPhone">
				<text class="phone-btn-text">电话咨询</text>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick } from "vue";
import { onLoad, onPageScroll } from "@dcloudio/uni-app";
import { fieldlist, accountinfo } from "../../../tapah/data";
import { RequestEnterprise, RequestCase, RequestWxCode, RequestUserInfo } from "../../../tapah/request";
import { parseimage, navigator, stagStr } from "../../../tapah/function";
import type { Field, Enterprise, Case } from "../../../tapah/class";

const tabs = ["专业详情", "对口企业", "成功案例"];
const activeTab = ref(0);
const field = ref<Field | null>(null);
const enterprises = ref<Enterprise[]>([]);
const cases = ref<Case[]>([]);
const isLoading = ref(true);
const isDescExpanded = ref(false);
const expandedCases = ref<Record<number, boolean>>({});

// Pagination
const enterprisePage = ref(1);
const casePage = ref(1);
const hasMoreEnterprise = ref(true);
const hasMoreCase = ref(true);

// Scroll Spy
const sectionTops = ref<number[]>([]);
const isScrollingToSection = ref(false);

const isFavorited = computed(() => {
	if (!accountinfo.value || !field.value) return false;
	return accountinfo.value.field.has(field.value.id);
});

const toggleCaseExpand = (idx: number) => {
	expandedCases.value[idx] = !expandedCases.value[idx];
};

const onEnterpriseTap = (id: number) => {
	navigator("/pages/enterprise/detail", { enterprise: id });
};

const goHome = () => {
	navigator("/mainpage");
};

const goConsult = () => {
	navigator("/kefu");
};

const callPhone = () => {
	uni.makePhoneCall({
		phoneNumber: "051281660895",
	});
};

const toggleFavorite = async () => {
	if (!accountinfo.value || !field.value) return;
	if (accountinfo.value.field.has(field.value.id)) {
		accountinfo.value.field.delete(field.value.id);
	} else {
		accountinfo.value.field.add(field.value.id);
	}
	try {
		await RequestUserInfo();
	} catch (err) {
		console.error("Failed to update favorite status:", err);
		uni.showToast({ title: "操作失败", icon: "none" });
	}
};

const onGetPhoneNumber = async (e: any) => {
	const code = e.detail.code;
	if (code) {
		try {
			await RequestWxCode(code);
			if (field.value) {
				loadData();
			}
		} catch (err) {
			console.error("Failed to login:", err);
			uni.showToast({ title: "登录失败", icon: "none" });
		}
	} else {
		uni.showToast({ title: "获取手机号失败", icon: "none" });
	}
};

const loadData = async () => {
	if (!field.value) return;
	isLoading.value = true;
	enterprisePage.value = 1;
	casePage.value = 1;
	try {
		const [entList, caseList] = await Promise.all([
			RequestEnterprise(0, 0, 0, 0, field.value.id, null, "", 1),
			RequestCase(0, 0, 0, field.value.id, 0, 0, 0, 1),
		]);
		enterprises.value = entList;
		cases.value = caseList;
		hasMoreEnterprise.value = entList.length >= 10; // Assuming page size is 10
		hasMoreCase.value = caseList.length >= 10;
	} catch (err) {
		console.error("Failed to load field detail data:", err);
	} finally {
		isLoading.value = false;
		nextTick(() => {
			setTimeout(calculateSectionTops, 500);
		});
	}
};

const loadMoreEnterprise = async () => {
	if (!field.value || !hasMoreEnterprise.value) return;
	const nextPage = enterprisePage.value + 1;
	try {
		const more = await RequestEnterprise(0, 0, 0, 0, field.value.id, null, "", nextPage);
		if (more.length > 0) {
			enterprises.value.push(...more);
			enterprisePage.value = nextPage;
			hasMoreEnterprise.value = more.length >= 10;
		} else {
			hasMoreEnterprise.value = false;
		}
	} catch (err) {
		console.error("Failed to load more enterprises:", err);
	}
};

const loadMoreCase = async () => {
	if (!field.value || !hasMoreCase.value) return;
	const nextPage = casePage.value + 1;
	try {
		const more = await RequestCase(0, 0, 0, field.value.id, 0, 0, 0, nextPage);
		if (more.length > 0) {
			cases.value.push(...more);
			casePage.value = nextPage;
			hasMoreCase.value = more.length >= 10;
		} else {
			hasMoreCase.value = false;
		}
	} catch (err) {
		console.error("Failed to load more cases:", err);
	}
};

const calculateSectionTops = () => {
	const query = uni.createSelectorQuery();
	for (let i = 0; i < 3; i++) {
		query.select(`#section-${i}`).boundingClientRect();
	}
	query.selectViewport().scrollOffset(() => {});
	query.exec((res) => {
		if (!res || res.length < 4) return;
		const viewport = res[3];
		if (!viewport) return;
		const scrollTop = viewport.scrollTop;
		const tops: number[] = [];
		for (let i = 0; i < 3; i++) {
			const rect = res[i];
			if (rect) {
				tops.push(scrollTop + rect.top);
			} else {
				tops.push(0);
			}
		}
		sectionTops.value = tops;
	});
};

const scrollToSection = (index: number) => {
	isScrollingToSection.value = true;
	activeTab.value = index;
	const query = uni.createSelectorQuery();
	query.select(`#section-${index}`).boundingClientRect();
	query.selectViewport().scrollOffset(() => {});
	query.exec((res) => {
		if (res && res[0] && res[1]) {
			const sectionTop = res[0].top;
			const scrollTop = res[1].scrollTop;
			const targetScrollTop = scrollTop + sectionTop - 40;
			uni.pageScrollTo({
				scrollTop: targetScrollTop,
				duration: 300,
				complete: () => {
					setTimeout(() => {
						isScrollingToSection.value = false;
					}, 100);
				},
			});
		} else {
			isScrollingToSection.value = false;
		}
	});
};

onPageScroll((e) => {
	if (isScrollingToSection.value || sectionTops.value.length === 0) return;
	const scrollTop = e.scrollTop;
	let activeIndex = 0;
	for (let i = 0; i < sectionTops.value.length; i++) {
		if (scrollTop >= sectionTops.value[i] - 50) {
			activeIndex = i;
		}
	}
	activeTab.value = activeIndex;
});

onLoad((options) => {
	let fieldId = 0;
	if (options && options.field) {
		fieldId = parseInt(options.field, 10) || 0;
	}

	if (fieldId > 0) {
		const found = fieldlist.value.find((f) => f.id === fieldId);
		if (found) {
			field.value = found;
			loadData();
		}
	}

	if (field.value && field.value.value) {
		uni.setNavigationBarTitle({
			title: field.value.value,
		});
	}
});
</script>

<style scoped>
.field-detail-page {
	display: flex;
	flex-direction: column;
	width: 100vw;
	min-height: 100vh;
	background-color: #f1f2f4;
	padding-bottom: 120rpx; /* Space for bottom nav bar */
	box-sizing: border-box;
}

/* Sticky Tab Bar */
.sticky-tab-bar {
	position: sticky;
	top: 0;
	z-index: 100;
	background-color: #f1f2f4;
	border-bottom: 1rpx solid #e2e2e2;
	height: 108rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	padding: 0 12rpx;
	box-sizing: border-box;
}

.tab-item {
	flex: 1;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	height: 100%;
}

.tab-text {
	font-size: 32rpx;
	font-weight: bold;
	color: #444444;
	line-height: 1;
}

.tab-text-active {
	color: #2d7bff;
}

.tab-line {
	height: 4rpx;
	width: 60rpx;
	background-color: transparent;
	margin-top: 12rpx;
	border-radius: 2rpx;
}

.tab-line-active {
	background-color: #2d7bff;
}

/* Sections Container */
.sections-container {
	display: flex;
	flex-direction: column;
	padding: 20rpx 24rpx;
	box-sizing: border-box;
}

.section-card {
	background-color: #ffffff;
	border-radius: 20rpx;
	padding: 24rpx;
	box-sizing: border-box;
}

.section-divider {
	height: 24rpx;
}

/* Section 0: 专业详情 */
.field-info-card {
	display: flex;
	flex-direction: column;
}

.field-title {
	font-size: 36rpx;
	font-weight: bold;
	color: #2d7bff;
	margin-bottom: 12rpx;
}

.field-subtitle {
	font-size: 26rpx;
	color: #333333;
	margin-bottom: 12rpx;
}

.stars-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-bottom: 16rpx;
}

.stars-label {
	font-size: 26rpx;
	color: #333333;
	margin-right: 10rpx;
}

.star-icon {
	color: #f6c44d;
	font-size: 34rpx;
	margin-right: 4rpx;
}

.field-desc {
	font-size: 26rpx;
	color: #555555;
	line-height: 1.5;
}

.field-desc-collapsed {
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
	overflow: hidden;
}

.expand-btn-row {
	display: flex;
	justify-content: flex-end;
	margin-top: 10rpx;
}

.expand-btn-text {
	color: #2d7bff;
	font-size: 26rpx;
}

/* Section Header */
.section-header {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-bottom: 24rpx;
}

.title-indicator {
	width: 8rpx;
	height: 40rpx;
	background-color: #2d7bff;
	border-radius: 4rpx;
	margin-right: 16rpx;
}

.section-title {
	font-size: 34rpx;
	font-weight: bold;
	color: #333333;
}

/* Enterprise List */
.enterprise-list {
	display: flex;
	flex-direction: column;
}

.enterprise-item {
	display: flex;
	flex-direction: row;
	background-color: #ffffff;
	border-radius: 16rpx;
	padding: 20rpx 0;
	border-bottom: 1rpx solid #eeeeee;
	box-sizing: border-box;
}

.enterprise-item:last-child {
	border-bottom: none;
}

.enterprise-logo {
	width: 90rpx;
	height: 90rpx;
	margin-right: 20rpx;
	flex-shrink: 0;
}

.logo-placeholder {
	width: 90rpx;
	height: 90rpx;
	background-color: #e0e0e0;
	border-radius: 8rpx;
	margin-right: 20rpx;
	flex-shrink: 0;
}

.enterprise-info {
	flex: 1;
	display: flex;
	flex-direction: column;
	overflow: hidden;
}

.enterprise-name {
	font-size: 32rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 6rpx;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.enterprise-english {
	font-size: 22rpx;
	color: #888888;
	margin-bottom: 8rpx;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.enterprise-tags {
	display: flex;
	flex-direction: row;
	flex-wrap: wrap;
	margin-bottom: 12rpx;
}

.tag-badge {
	background-color: #feeddf;
	border-radius: 8rpx;
	padding: 2rpx 12rpx;
	margin-right: 10rpx;
	margin-bottom: 6rpx;
}

.tag-text {
	font-size: 20rpx;
	color: #692e1f;
}

.enterprise-location {
	font-size: 20rpx;
	color: #666666;
}

.load-more-row {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 20rpx 0;
}

.load-more-text {
	font-size: 24rpx;
	color: #2d7bff;
}

/* Success Cases */
.cases-wrapper {
	position: relative;
	width: 100%;
}

.cases-list {
	display: flex;
	flex-direction: column;
}

.blur-content {
	filter: blur(12px);
	pointer-events: none;
}

.case-card {
	background-color: #ffffff;
	border-radius: 16rpx;
	padding: 20rpx 0;
	border-bottom: 1rpx solid #eeeeee;
	box-sizing: border-box;
}

.case-card:last-child {
	border-bottom: none;
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

.title-indicator-small {
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

.result-text {
	font-size: 24rpx;
	color: #555555;
	padding: 4rpx 0;
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
.empty-state {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 40rpx 0;
}

.loading-text,
.empty-text {
	font-size: 28rpx;
	color: #888888;
}

/* Bottom Navigation Bar */
.bottom-nav-bar {
	position: fixed;
	bottom: 0;
	left: 0;
	right: 0;
	height: 120rpx;
	background-color: #ffffff;
	border-top: 1rpx solid #eeeeee;
	display: flex;
	flex-direction: row;
	align-items: center;
	padding: 0 20rpx;
	box-sizing: border-box;
	z-index: 200;
}

.nav-item-home,
.nav-item-fav {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	width: 100rpx;
	height: 100%;
}

.nav-item-home {
	margin-right: 10rpx;
}

.nav-icon {
	width: 56rpx;
	height: 56rpx;
	margin-bottom: 4rpx;
}

.nav-text {
	font-size: 20rpx;
	color: #333333;
	line-height: 1;
}

.fav-btn-unlogged {
	background: none;
	border: none;
	padding: 0;
	margin: 0;
	line-height: 1.2;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	width: 100%;
	height: 100%;
}

.fav-btn-unlogged::after {
	border: none;
}

.fav-btn-logged {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	width: 100%;
	height: 100%;
}

.nav-btn-consult,
.nav-btn-phone {
	flex: 1;
	height: 70rpx;
	border-radius: 35rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	margin: 0 10rpx;
}

.nav-btn-consult {
	background-color: #82b2f5;
}

.consult-btn-text {
	color: #ffffff;
	font-size: 28rpx;
	font-weight: bold;
}

.nav-btn-phone {
	background-color: #ffc300;
}

.phone-btn-text {
	color: #ffffff;
	font-size: 28rpx;
	font-weight: bold;
}
</style>
