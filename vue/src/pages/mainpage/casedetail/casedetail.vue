<template>
	<view class="case-detail-page" v-if="caseItem">
		<view class="page-nav" :style="navBarStyle">
			<view class="nav-side nav-side-left">
				<view class="nav-back" :style="navSideStyle" @tap="onBack">
					<text class="nav-back-icon">‹</text>
				</view>
			</view>
			<text class="nav-title" :style="navTitleStyle">成功案例</text>
			<view class="nav-side nav-side-right"></view>
		</view>

		<scroll-view class="page-scroll" scroll-y enhanced :show-scrollbar="false">
			<view class="page-content">
				<text class="job-title">{{ pageTitle }}</text>

				<view class="section-card">
					<view class="section-header">
						<view class="title-indicator"></view>
						<text class="section-title">基础信息</text>
					</view>

					<view class="info-table">
						<view class="table-row">
							<text class="table-label">毕业院校</text>
							<view class="table-value-col">
								<view class="table-value-wrap">
									<text class="table-value">{{ caseItem.student || "--" }}</text>
									<view v-for="(badge, idx) in studentBadges" :key="'s-' + idx" class="peach-tag">
										<text class="peach-tag-text">{{ badge }}</text>
									</view>
								</view>
							</view>
							<view class="table-link-col"></view>
						</view>
						<view class="table-row">
							<text class="table-label">去向单位</text>
							<view class="table-value-col">
								<text class="table-value">{{ caseItem.entname || "--" }}</text>
							</view>
							<view v-if="caseItem.entid" class="table-link-col" @tap.stop="onEnterpriseTap">
								<text class="link-text">企业详情 ›</text>
							</view>
							<view v-else class="table-link-col"></view>
						</view>
						<view class="table-row">
							<text class="table-label">所在部门</text>
							<view class="table-value-col">
								<text class="table-value">{{ caseItem.dep || "--" }}</text>
							</view>
							<view class="table-link-col"></view>
						</view>
						<view class="table-row">
							<text class="table-label">录取岗位</text>
							<view class="table-value-col">
								<text class="table-value">{{ caseItem.name || "--" }}</text>
							</view>
							<view class="table-link-col"></view>
						</view>
						<view class="table-row">
							<text class="table-label">毕业学校</text>
							<view class="table-value-col">
								<view class="table-value-wrap">
									<text class="table-value">{{ caseItem.school1 || "--" }}</text>
									<view v-if="school1Tag" class="peach-tag">
										<text class="peach-tag-text">{{ school1Tag }}</text>
									</view>
								</view>
							</view>
							<view class="table-link-col"></view>
						</view>
						<view class="table-row">
							<text class="table-label">本科专业</text>
							<view class="table-value-col">
								<text class="table-value">{{ caseItem.field1 || "--" }}</text>
							</view>
							<view v-if="caseItem.field?.id" class="table-link-col" @tap.stop="onFieldTap">
								<text class="link-text">专业详情 ›</text>
							</view>
							<view v-else class="table-link-col"></view>
						</view>
						<view class="table-row">
							<text class="table-label">硕士学校</text>
							<view class="table-value-col">
								<view class="table-value-wrap">
									<text class="table-value">{{ caseItem.school2 || "--" }}</text>
									<view v-if="school2Tag" class="peach-tag">
										<text class="peach-tag-text">{{ school2Tag }}</text>
									</view>
								</view>
							</view>
							<view class="table-link-col"></view>
						</view>
						<view class="table-row">
							<text class="table-label">硕士专业</text>
							<view class="table-value-col">
								<text class="table-value">{{ caseItem.field2 || "--" }}</text>
							</view>
							<view v-if="caseItem.field?.id" class="table-link-col" @tap.stop="onFieldTap">
								<text class="link-text">专业详情 ›</text>
							</view>
							<view v-else class="table-link-col"></view>
						</view>
					</view>
				</view>

				<view class="section-card section-card-gap">
					<view class="section-header section-header-between">
						<view class="section-header-left">
							<view class="title-indicator"></view>
							<text class="section-title">主要经历</text>
						</view>
						<text class="section-link-text" @tap="onBackgroundImproveTap">如何做好背景提升 ›</text>
					</view>

					<view v-if="experiences.length === 0" class="empty-exp">
						<text class="empty-exp-text">--</text>
					</view>
					<view v-else class="experience-list">
						<view v-for="(exp, idx) in experiences" :key="idx" class="experience-item">
							<view class="exp-top-row">
								<view class="exp-dot"></view>
								<text
									class="exp-company"
									@tap.stop="exp.enterpriseId ? onExperienceEnterpriseTap(exp.enterpriseId) : undefined"
								>{{ exp.enterpriseName || exp.company || "--" }}</text>
							</view>
							<view class="exp-detail-row">
								<image class="exp-icon" :src="parseimage('底部按钮/实习企业.png')" mode="aspectFit" />
								<text class="exp-dept-role">{{ exp.deptRole || "--" }}</text>
							</view>
						</view>
					</view>
				</view>

				<SimilarCaseSection :cases="similarCases" />
			</view>
		</scroll-view>

		<DetailBottomBar />
	</view>

	<view v-else-if="isLoading" class="loading-page">
		<text class="loading-text">加载中...</text>
	</view>
</template>

<script setup lang="ts">
import { ref, computed } from "vue";
import { onLoad } from "@dcloudio/uni-app";

import type { Case } from "../../../tapah/class";
import { RequestCaseDetail } from "../../../tapah/request";
import { parseInternshipExperiences } from "../../../tapah/caseExperience";
import { parseimage, navigator, getWechatNavMetrics, stagStr } from "../../../tapah/function";
import DetailBottomBar from "../../../components/DetailBottomBar.vue";
import SimilarCaseSection from "../../../components/SimilarCaseSection.vue";

const caseItem = ref<Case | null>(null);
const similarCases = ref<Case[]>([]);
const isLoading = ref(true);

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

const pageTitle = computed(() => {
	if (!caseItem.value) return "--";
	const ent = caseItem.value.entname || "";
	const name = caseItem.value.name || "";
	return `${ent}${name}offer`;
});

const yearBadge = computed(() => {
	if (!caseItem.value) return "";
	if (caseItem.value.year || caseItem.value.tags?.some((t) => t.includes("届"))) {
		return "应届生";
	}
	return "";
});

const studentBadges = computed(() => {
	if (!caseItem.value) return [];
	const badges: string[] = [];
	const tagList = caseItem.value.tags ?? [];
	for (const tag of tagList) {
		if (tag.includes("届")) continue;
		if (tag.trim()) badges.push(tag);
	}
	if (yearBadge.value) badges.unshift(yearBadge.value);
	return badges;
});

const school1Tag = computed(() => {
	const stag = caseItem.value?.stag1;
	if (stag == null || stag <= 0) return "";
	const label = stagStr(stag);
	return label && label !== "未知" ? label : "";
});

const school2Tag = computed(() => {
	const stag = caseItem.value?.stag2;
	if (stag == null || stag <= 0) return "";
	const label = stagStr(stag);
	return label && label !== "未知" ? label : "";
});

const experiences = computed(() =>
	parseInternshipExperiences(caseItem.value?.detail, caseItem.value?.experiences),
);

const onExperienceEnterpriseTap = (enterpriseId: number) => {
	navigator("/pages/enterprise/detail", { enterprise: enterpriseId });
};

const onBack = () => {
	uni.navigateBack();
};

const onEnterpriseTap = () => {
	if (!caseItem.value?.entid) return;
	navigator("/pages/enterprise/detail", { enterprise: caseItem.value.entid });
};

const onFieldTap = () => {
	if (!caseItem.value?.field?.id) return;
	navigator("/mainpage/fielddetail", { field: caseItem.value.field.id });
};

const onBackgroundImproveTap = () => {
	navigator("/lanmu/shixineitui");
};

const loadCaseDetail = async (id: number) => {
	isLoading.value = true;
	try {
		const result = await RequestCaseDetail(id);
		caseItem.value = result.caseItem;
		similarCases.value = result.similar;
	} catch (err) {
		console.error("Failed to load case detail:", err);
		caseItem.value = null;
		uni.showToast({ title: "加载失败", icon: "none" });
	} finally {
		isLoading.value = false;
	}
};

onLoad((options) => {
	const id = parseInt(String(options?.id ?? options?.case ?? "0"), 10);
	if (!id) {
		isLoading.value = false;
		uni.showToast({ title: "案例不存在", icon: "none" });
		return;
	}
	loadCaseDetail(id);
});
</script>

<style scoped>
.case-detail-page {
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

.job-title {
	font-size: 48rpx;
	line-height: 70rpx;
	font-weight: 400;
	color: #000000;
	word-break: break-word;
}

.section-card {
	margin-top: 24rpx;
	background-color: #ffffff;
	border-radius: 20rpx;
	padding: 24rpx;
	box-sizing: border-box;
	box-shadow:
		0 4rpx 8rpx rgba(0, 0, 0, 0.02),
		0 2rpx 12rpx rgba(0, 0, 0, 0.02),
		0 2rpx 4rpx rgba(0, 0, 0, 0.03);
}

.section-card-gap {
	margin-top: 24rpx;
}

.section-header {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-bottom: 16rpx;
}

.section-header-between {
	justify-content: space-between;
}

.section-header-left {
	display: flex;
	flex-direction: row;
	align-items: center;
	min-width: 0;
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

.section-link-text {
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 350;
	color: #5e80f7;
	flex-shrink: 0;
}

.info-table {
	display: flex;
	flex-direction: column;
	gap: 8rpx;
}

.table-row {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	min-height: 48rpx;
}

.table-label {
	flex-shrink: 0;
	width: 140rpx;
	font-size: 28rpx;
	line-height: 48rpx;
	font-weight: 350;
	color: #898989;
}

.table-value-col {
	flex: 1;
	min-width: 0;
	padding-right: 8rpx;
	box-sizing: border-box;
}

.table-link-col {
	flex-shrink: 0;
	width: 128rpx;
	display: flex;
	justify-content: flex-end;
	align-items: flex-start;
	min-height: 48rpx;
	padding-top: 7rpx;
	box-sizing: border-box;
}

.table-value-wrap {
	display: flex;
	flex-direction: row;
	flex-wrap: wrap;
	align-items: center;
	gap: 8rpx;
}

.table-value {
	font-size: 28rpx;
	line-height: 48rpx;
	font-weight: 350;
	color: #000000;
	word-break: break-word;
}

.peach-tag {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	height: 30rpx;
	padding: 0 10rpx;
	background-color: #fbebe5;
	border-radius: 8rpx;
	box-sizing: border-box;
	flex-shrink: 0;
}

.peach-tag-text {
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 400;
	color: #ee692d;
}

.link-text {
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 350;
	color: #5e80f7;
	white-space: nowrap;
}

.experience-list {
	display: flex;
	flex-direction: column;
	gap: 20rpx;
}

.experience-item {
	display: flex;
	flex-direction: column;
}

.exp-top-row {
	display: flex;
	flex-direction: row;
	align-items: center;
}

.exp-dot {
	width: 12rpx;
	height: 12rpx;
	border-radius: 50%;
	background-color: #4476ff;
	flex-shrink: 0;
}

.exp-company {
	margin-left: 30rpx;
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 500;
	color: #000000;
	word-break: break-word;
}

.exp-detail-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-top: 8rpx;
	margin-left: 42rpx;
}

.exp-icon {
	width: 64rpx;
	height: 28rpx;
	flex-shrink: 0;
}

.exp-dept-role {
	margin-left: 12rpx;
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 350;
	color: #000000;
	word-break: break-word;
}

.empty-exp {
	padding: 8rpx 0;
}

.empty-exp-text {
	font-size: 28rpx;
	line-height: 48rpx;
	color: #000000;
}

.loading-page {
	display: flex;
	align-items: center;
	justify-content: center;
	width: 100vw;
	height: 100vh;
	background-color: #f8f8f8;
}

.loading-text {
	font-size: 28rpx;
	color: #888888;
}
</style>
