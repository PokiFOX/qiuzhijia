<template>
	<view class="field-detail-page" v-if="field">
		<view class="page-nav" :style="navBarStyle">
			<view class="nav-side nav-side-left">
				<view class="nav-back" :style="navSideStyle" @tap="onBack">
					<text class="nav-back-icon">‹</text>
				</view>
			</view>
			<text class="nav-title" :style="navTitleStyle">招聘专业</text>
			<view class="nav-side nav-side-right"></view>
		</view>

		<view class="tab-bar">
			<view v-for="(tab, index) in tabs" :key="index" class="tab-item" @tap="scrollToSection(index)">
				<text :class="['tab-text', { 'tab-text-active': activeTab === index }]">{{ tab }}</text>
				<view :class="['tab-line', { 'tab-line-active': activeTab === index }]"></view>
			</view>
		</view>

		<scroll-view class="page-scroll" scroll-y enhanced :show-scrollbar="false" :scroll-into-view="scrollTargetId" scroll-with-animation @scroll="onScroll">
			<view class="page-content">
				<view id="section-0" class="section-card section-card-field">
					<FieldCard :field="field" full-content />
				</view>

				<view id="section-1" class="section-card section-card-enterprise">
					<view class="section-header">
						<view class="title-indicator"></view>
						<text class="section-title">招聘企业</text>
					</view>

					<view v-if="isLoading" class="state-row">
						<text class="state-text">加载中...</text>
					</view>
					<view v-else-if="allEnterprises.length === 0" class="state-row">
						<text class="state-text">暂无招聘企业数据</text>
					</view>
					<view v-else class="enterprise-list">
						<EnterpriseCard v-for="(ent, idx) in displayedEnterprises" :key="idx" :enterprise="ent" compact @tap="onEnterpriseTap(ent.id)"/>
						<view v-if="canLoadMoreEnterprise" class="load-more-bar" @tap="loadMoreEnterprise">
							<text class="load-more-text">查看更多招聘企业 ›</text>
						</view>
					</view>
				</view>

				<view id="section-2" class="section-card section-card-case">
					<view class="section-header">
						<view class="title-indicator"></view>
						<text class="section-title">成功案例</text>
					</view>

					<view class="cases-wrapper">
						<view :class="['cases-list', { 'blur-content': !accountinfo }]">
							<view v-if="isLoading" class="state-row">
								<text class="state-text">加载中...</text>
							</view>
							<view v-else-if="allCases.length === 0" class="state-row">
								<text class="state-text">暂无成功案例数据</text>
							</view>
							<template v-else>
								<CaseCard v-for="(c, idx) in displayedCases" :key="idx" :case-item="c"/>
								<view v-if="canLoadMoreCase" class="load-more-bar" @tap="loadMoreCase">
									<text class="load-more-text">查看更多成功案例 ›</text>
								</view>
							</template>
						</view>

						<view v-if="!accountinfo" class="login-overlay">
							<button open-type="getPhoneNumber" @getphonenumber="onCaseLogin" class="login-btn">
								请先登录后查看
							</button>
						</view>
					</view>
				</view>
			</view>
		</scroll-view>

		<DetailBottomBar :is-favorited="isFavorited" favorite-label="关注" favorited-label="已关注" @toggle-favorite="toggleFavorite" @logged-in="loadData"/>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, nextTick } from "vue";
import { onLoad } from "@dcloudio/uni-app";

import { fieldlist, accountinfo } from "../../../tapah/data";
import { RequestEnterprise, RequestCase, RequestUserInfo, RequestWxCode } from "../../../tapah/request";
import { navigator, getWechatNavMetrics } from "../../../tapah/function";
import type { Field, Enterprise, Case } from "../../../tapah/class";
import FieldCard from "../../../components/FieldCard.vue";
import EnterpriseCard from "../../../components/EnterpriseCard.vue";
import DetailBottomBar from "../../../components/DetailBottomBar.vue";
import CaseCard from "../../../components/CaseCard.vue";

const PAGE_SIZE = 4;

const tabs = ["专业详情", "招聘企业", "成功案例"];
const activeTab = ref(0);
const scrollTargetId = ref("");
const field = ref<Field | null>(null);
const allEnterprises = ref<Enterprise[]>([]);
const allCases = ref<Case[]>([]);
const displayEnterpriseCount = ref(PAGE_SIZE);
const displayCaseCount = ref(PAGE_SIZE);
const enterprisePage = ref(1);
const casePage = ref(1);
const hasMoreEnterprisePages = ref(true);
const hasMoreCasePages = ref(true);
const isLoading = ref(true);

const sectionTops = ref<number[]>([]);
const isScrollingToSection = ref(false);

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

const displayedEnterprises = computed(() => allEnterprises.value.slice(0, displayEnterpriseCount.value));
const displayedCases = computed(() => allCases.value.slice(0, displayCaseCount.value));

const canLoadMoreEnterprise = computed(
	() => displayEnterpriseCount.value < allEnterprises.value.length || hasMoreEnterprisePages.value,
);
const canLoadMoreCase = computed(
	() => displayCaseCount.value < allCases.value.length || hasMoreCasePages.value,
);

const isFavorited = computed(() => {
	if (!accountinfo.value || !field.value) return false;
	return accountinfo.value.field.has(field.value.id);
});

const onBack = () => {
	uni.navigateBack();
};

const onEnterpriseTap = (id: number) => {
	navigator("/pages/enterprise/detail", { enterprise: id });
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

const onCaseLogin = async (e: any) => {
	const code = e.detail.code;
	if (!code) {
		uni.showToast({ title: "获取手机号失败", icon: "none" });
		return;
	}
	try {
		await RequestWxCode(code);
		loadData();
	} catch (err) {
		console.error("Failed to login:", err);
		uni.showToast({ title: "登录失败", icon: "none" });
	}
};

const loadData = async () => {
	if (!field.value) return;
	isLoading.value = true;
	enterprisePage.value = 1;
	casePage.value = 1;
	displayEnterpriseCount.value = PAGE_SIZE;
	displayCaseCount.value = PAGE_SIZE;
	try {
		const [entList, caseList] = await Promise.all([
			RequestEnterprise(0, 0, 0, 0, field.value.id, null, null, "", 1),
			RequestCase(0, 0, 0, field.value.id, 0, 0, 0, 1),
		]);
		allEnterprises.value = entList;
		allCases.value = caseList;
		hasMoreEnterprisePages.value = entList.length >= 20;
		hasMoreCasePages.value = caseList.length >= 20;
	} catch (err) {
		console.error("Failed to load field detail data:", err);
	} finally {
		isLoading.value = false;
		nextTick(() => {
			setTimeout(calculateSectionTops, 300);
		});
	}
};

const loadMoreEnterprise = async () => {
	if (displayEnterpriseCount.value < allEnterprises.value.length) {
		displayEnterpriseCount.value = Math.min(allEnterprises.value.length, displayEnterpriseCount.value + PAGE_SIZE);
		return;
	}
	if (!field.value || !hasMoreEnterprisePages.value) return;
	const nextPage = enterprisePage.value + 1;
	try {
		const more = await RequestEnterprise(0, 0, 0, 0, field.value.id, null, null, "", nextPage);
		if (more.length > 0) {
			allEnterprises.value.push(...more);
			enterprisePage.value = nextPage;
			displayEnterpriseCount.value = Math.min(allEnterprises.value.length, displayEnterpriseCount.value + PAGE_SIZE);
			hasMoreEnterprisePages.value = more.length >= 20;
		} else {
			hasMoreEnterprisePages.value = false;
		}
	} catch (err) {
		console.error("Failed to load more enterprises:", err);
	}
};

const loadMoreCase = async () => {
	if (displayCaseCount.value < allCases.value.length) {
		displayCaseCount.value = Math.min(allCases.value.length, displayCaseCount.value + PAGE_SIZE);
		return;
	}
	if (!field.value || !hasMoreCasePages.value) return;
	const nextPage = casePage.value + 1;
	try {
		const more = await RequestCase(0, 0, 0, field.value.id, 0, 0, 0, nextPage);
		if (more.length > 0) {
			allCases.value.push(...more);
			casePage.value = nextPage;
			displayCaseCount.value = Math.min(allCases.value.length, displayCaseCount.value + PAGE_SIZE);
			hasMoreCasePages.value = more.length >= 20;
		} else {
			hasMoreCasePages.value = false;
		}
	} catch (err) {
		console.error("Failed to load more cases:", err);
	}
};

const calculateSectionTops = () => {
	const query = uni.createSelectorQuery();
	for (let i = 0; i < tabs.length; i++) {
		query.select(`#section-${i}`).boundingClientRect();
	}
	query.select(".page-scroll").boundingClientRect();
	query.exec((res) => {
		if (!res || res.length < tabs.length + 1) return;
		const scrollRect = res[res.length - 1];
		if (!scrollRect) return;
		const tops: number[] = [];
		for (let i = 0; i < tabs.length; i++) {
			const rect = res[i];
			tops.push(rect ? rect.top - scrollRect.top : 0);
		}
		sectionTops.value = tops;
	});
};

const scrollToSection = (index: number) => {
	isScrollingToSection.value = true;
	activeTab.value = index;
	scrollTargetId.value = `section-${index}`;
	setTimeout(() => {
		scrollTargetId.value = "";
		isScrollingToSection.value = false;
	}, 350);
};

const onScroll = (e: { detail: { scrollTop: number } }) => {
	if (isScrollingToSection.value || sectionTops.value.length === 0) return;
	const scrollTop = e.detail.scrollTop;
	let activeIndex = 0;
	for (let i = 0; i < sectionTops.value.length; i++) {
		if (scrollTop >= sectionTops.value[i] - 20) {
			activeIndex = i;
		}
	}
	activeTab.value = activeIndex;
};

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
});
</script>

<style scoped>
.field-detail-page {
	display: flex;
	flex-direction: column;
	width: 100vw;
	height: 100vh;
	background-color: #f8f8f8;
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

.tab-bar {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: space-between;
	height: 88rpx;
	padding: 0 48rpx;
	background-color: #ffffff;
	box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.05);
	flex-shrink: 0;
	box-sizing: border-box;
}

.tab-item {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	height: 100%;
}

.tab-text {
	font-size: 30rpx;
	line-height: 44rpx;
	font-weight: 400;
	color: #000000;
}

.tab-text-active {
	color: #1269ff;
	font-weight: 500;
}

.tab-line {
	width: 48rpx;
	height: 4rpx;
	margin-top: 4rpx;
	border-radius: 2rpx;
	background-color: transparent;
}

.tab-line-active {
	background-color: #1269ff;
}

.page-scroll {
	flex: 1;
	min-height: 0;
	width: 100%;
}

.page-content {
	display: flex;
	flex-direction: column;
	padding: 24rpx 48rpx 180rpx;
	box-sizing: border-box;
}

.section-card {
	background-color: #ffffff;
	border-radius: 20rpx;
	padding: 24rpx;
	box-sizing: border-box;
}

.section-card-field {
	box-shadow: 0 2rpx 4rpx rgba(0, 0, 0, 0.03);
}

.section-card-enterprise {
	margin-top: 24rpx;
	box-shadow:
		0 4rpx 8rpx rgba(0, 0, 0, 0.02),
		0 2rpx 12rpx rgba(0, 0, 0, 0.02),
		0 2rpx 4rpx rgba(0, 0, 0, 0.03);
}

.section-card-case {
	margin-top: 24rpx;
	box-shadow:
		0 4rpx 8rpx rgba(0, 0, 0, 0.02),
		0 2rpx 12rpx rgba(0, 0, 0, 0.02),
		0 2rpx 4rpx rgba(0, 0, 0, 0.03);
}

.section-header {
	display: flex;
	flex-direction: row;
	align-items: center;
}

.title-indicator {
	width: 6rpx;
	height: 32rpx;
	background-color: #1269ff;
	border-radius: 3rpx;
	margin-right: 12rpx;
	flex-shrink: 0;
}

.section-title {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 500;
	color: #000000;
}

.enterprise-list {
	margin-top: 32rpx;
}

.state-row {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 40rpx 0;
}

.state-text {
	font-size: 28rpx;
	color: #888888;
}

.load-more-bar {
	display: flex;
	align-items: center;
	justify-content: center;
	height: 82rpx;
	background-color: #f6f7f9;
	border-radius: 14rpx;
}

.load-more-text {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 350;
	color: #000000;
}

.cases-wrapper {
	position: relative;
	width: 100%;
	margin-top: 32rpx;
}

.cases-list {
	display: flex;
	flex-direction: column;
	gap: 20rpx;
}

.blur-content {
	filter: blur(12px);
	pointer-events: none;
}

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

.login-btn::after {
	border: none;
}
</style>
