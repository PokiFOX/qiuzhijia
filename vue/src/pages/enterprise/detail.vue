<template>
	<view class="detail-root" v-if="initialized && enterprise">
		<scroll-view class="detail-scroll" scroll-y enhanced :show-scrollbar="false" :scroll-top="pageScrollTop" :scroll-with-animation="scrollWithAnimation" @scroll="onDetailScroll">
			<view class="detail-page">
				<view class="banner-wrap" v-if="enterprise.images && enterprise.images.length > 0">
					<swiper class="top-swiper" :style="bannerSwiperStyle" circular autoplay :interval="3000" duration="500" @change="onSwiperChange">
						<swiper-item v-for="(img, index) in enterprise.images" :key="index">
							<image class="banner-image" :src="parseEnterpriseIcon(`大图标/${img}.png`)" mode="widthFix" @load="onBannerImageLoad"/>
						</swiper-item>
					</swiper>
					<view class="swiper-indicator">
						<text class="indicator-text">{{ swiperIndex + 1 }}/{{ enterprise.images.length }}</text>
					</view>
				</view>

				<view class="tab-bar">
					<view class="tab-item" v-for="(tab, index) in entfenyes" :key="index" @tap="scrollToSection(index)">
						<text :class="['tab-text', { 'tab-text-active': fenyeindex === index }]">{{ tab }}</text>
						<view :class="['tab-line', { 'tab-line-active': fenyeindex === index }]"></view>
					</view>
				</view>

				<view class="main-panel">
					<view class="sections-inner">
				<!-- Section 0: 公司简介 -->
				<view id="section-0" class="section-card">
					<view class="name-row">
						<view class="name-marquee-col">
							<text class="enterprise-name-text">{{ enterprise.name || "" }}</text>
						</view>
						<view v-if="enterprise.icon" class="enterprise-icon-wrap">
							<image class="enterprise-icon" :src="parseEnterpriseIcon(`小图标/${enterprise.icon}.png`)" mode="aspectFit"/>
						</view>
					</view>

					<view class="location-row">
						<image class="location-icon" :src="parseimage('企业列表/定位.png')" mode="aspectFit" />
						<text class="location-text">
							{{ enterprise.zone?.value || "" }} {{ enterprise.city || "" }}
						</text>
					</view>

					<scroll-view v-if="enterprise.tags && enterprise.tags.length > 0" class="tags-scroll" scroll-x :show-scrollbar="false" enable-flex>
						<view class="tags-row">
							<view class="tag-badge" v-for="(tag, idx) in enterprise.tags" :key="idx">
								<text class="tag-text">{{ tag }}</text>
							</view>
						</view>
					</scroll-view>

					<view class="brief-box" v-if="enterprise.brief">
						<view :class="['brief-content', { 'brief-content-collapsed': !isBriefExpanded && needBriefToggle }]">
							<text class="brief-desc">
								{{ enterprise.brief }}<text v-if="needBriefToggle && isBriefExpanded" class="brief-toggle-inline" @tap.stop="toggleBrief"> 收起 ▲</text>
							</text>
							<view v-if="needBriefToggle && !isBriefExpanded" class="brief-toggle-overlay" @tap.stop="toggleBrief">
								<text class="brief-toggle-text">展开</text>
								<text class="brief-toggle-arrow">▼</text>
							</view>
						</view>
					</view>

					<view class="info-table">
						<view class="table-row">
							<text class="table-label">全　　称</text>
							<text class="table-value">{{ enterprise.name || "" }}</text>
						</view>
						<view class="table-row" v-if="enterprise.englishname">
							<text class="table-label">英　　文</text>
							<text class="table-value">{{ enterprise.englishname }}</text>
						</view>
						<view class="table-row" v-if="enterprise.shortname">
							<text class="table-label">简　　称</text>
							<text class="table-value">{{ enterprise.shortname }}</text>
						</view>
						<view class="table-row" v-if="enterprise.upper">
							<text class="table-label">上级单位</text>
							<text class="table-value">{{ enterprise.upper }}</text>
						</view>
						<view class="table-row" v-if="enterprise.sector">
							<text class="table-label">行业类别</text>
							<text class="table-value">{{ enterprise.sector.value }}</text>
						</view>
						<view class="table-row" v-if="enterprise.level">
							<text class="table-label">公司层级</text>
							<text class="table-value">{{ enterprise.level.value }}</text>
						</view>
						<view class="table-row" v-if="enterprise.website1">
							<text class="table-label">公司官网</text>
							<text class="table-value table-link" @tap="openWebsite(enterprise.website1)">
								{{ enterprise.website1 }}
							</text>
							<text class="table-copy" @tap.stop="copyWebsite(enterprise.website1)">复制链接</text>
						</view>
						<view class="table-row" v-if="enterprise.website2">
							<text class="table-label">招聘官网</text>
							<text class="table-value table-link" @tap="openWebsite(enterprise.website2)">
								{{ enterprise.website2 }}
							</text>
							<text class="table-copy" @tap.stop="copyWebsite(enterprise.website2)">复制链接</text>
						</view>
					</view>
				</view>

				<view class="section-gap"></view>

				<!-- Section 1: 招聘专业 -->
				<view id="section-1" class="section-card">
					<text class="block-title">招聘专业</text>
					<view class="fields-list" v-if="enterprise.fields && enterprise.fields.length > 0">
						<view class="field-card" v-for="(field, idx) in enterprise.fields" :key="idx" @tap="onFieldTap(field.id)">
							<text class="field-name">{{ field.value }}</text>
							<view class="field-meta-row">
								<view class="field-meta-bar">
									<text class="field-type">{{ field.type }}</text>
									<view class="field-meta-divider"></view>
									<text class="field-stars-label">专业热门度:</text>
									<text class="star-icon" v-for="n in field.star" :key="n">★</text>
								</view>
								<view class="field-detail-link" @tap.stop="onFieldTap(field.id)">
									<text class="field-detail-text">详情</text>
									<text class="field-detail-arrow">›</text>
								</view>
							</view>
						</view>
					</view>
					<view v-else class="section-empty">
						<text class="empty-text">暂无招聘专业信息</text>
					</view>
				</view>

				<view class="section-gap"></view>

				<!-- Section 2: 深度解读 -->
				<view id="section-2" class="section-card">
					<text class="block-title">深度解读</text>
					<view class="articles-list" v-if="enterprise.article1 && enterprise.article1.length > 0">
						<view class="article-card" v-for="(art, idx) in enterprise.article1" :key="idx" @tap="onArticleTap(art.article)">
							<text class="article-title">{{ art.title || "未知标题" }}</text>
							<text v-if="art.description" class="article-desc">{{ art.description }}</text>
							<view class="article-footer">
								<view v-if="art.accountName" class="article-account">
									<image v-if="art.accountIcon" class="account-icon" :src="art.accountIcon" mode="aspectFill"/>
									<text class="account-name">{{ art.accountName }}</text>
								</view>
								<text class="article-time">发布时间: {{ formatArticleDate(art) }}</text>
							</view>
						</view>
					</view>
					<view v-else class="section-empty">
						<text class="empty-text">暂无深度解读文章</text>
					</view>
				</view>

				<view class="section-gap"></view>

				<!-- Section 3: 成功案例 -->
				<view id="section-3" class="section-card">
					<text class="block-title">成功案例</text>
					<view class="cases-wrapper">
						<view :class="['cases-list', { 'blur-content': !accountinfo }]">
							<view v-if="isCasesLoading && allCases.length === 0" class="cases-loading">
								<text class="loading-text">加载中...</text>
							</view>
							<view v-else-if="allCases.length === 0" class="section-empty">
								<text class="empty-text">暂无成功案例</text>
							</view>
							<template v-else>
								<CaseCard v-for="(c, idx) in displayedCases" :key="idx" :case-item="c"/>
								<view v-if="canLoadMoreCase" class="load-more-bar" :class="{ 'load-more-bar-disabled': isLoadingMoreCases }" @tap="loadMoreCase">
									<text class="load-more-text">{{ isLoadingMoreCases ? "加载中..." : "查看更多成功案例 ›" }}</text>
								</view>
							</template>
						</view>
						<view v-if="!accountinfo" class="login-overlay">
							<button open-type="getPhoneNumber" @getphonenumber="onGetPhoneNumber" class="login-btn">
								请先登录后查看
							</button>
						</view>
					</view>
				</view>
			</view>
		</view>
			</view>
		</scroll-view>

		<DetailBottomBar :is-favorited="isFavorited" @toggle-favorite="toggleFavorite" @logged-in="onCasesLoggedIn"/>

		<!-- Copy Success Modal -->
		<view v-if="showCopyModal" class="modal-mask" @tap="showCopyModal = false">
			<view class="modal-container" @tap.stop>
				<image class="modal-check-icon" :src="parseimage('底部按钮/打钩.png')" mode="aspectFit" />
				<text class="modal-title">链接已复制</text>
				<text class="modal-desc">立即咨询顾问老师，获取岗位信息，投递建议和专属资料吧！</text>
				<view class="modal-divider" />
				<view class="modal-buttons">
					<button class="modal-btn btn-later" @tap="showCopyModal = false">稍后查看</button>
					<button class="modal-btn btn-consult" @tap="onConsultTap">立即咨询</button>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, nextTick, watch } from "vue";
import { onLoad } from "@dcloudio/uni-app";

import { enterpriselist, accountinfo } from "../../tapah/data";
import { entfenyes } from "../../tapah/option";
import { RequestEnterpriseDetail, RequestCase, RequestWxCode, RequestUserInfo } from "../../tapah/request";
import { parseimage, parseEnterpriseIcon, navigator, openOfficialAccountArticle, openExternalUrl, } from "../../tapah/function";
import type { Enterprise, Case, Article } from "../../tapah/class";
import DetailBottomBar from "../../components/DetailBottomBar.vue";
import CaseCard from "../../components/CaseCard.vue";

const SECTION_COUNT = 4;
const TAB_BAR_HEIGHT_RPX = 88;
const PAGE_SIZE = 4;

const initialized = ref(false);
const enterprise = ref<Enterprise | null>(null);
const swiperIndex = ref(0);
const fenyeindex = ref(0);
const isBriefExpanded = ref(false);

const allCases = ref<Case[]>([]);
const displayCaseCount = ref(PAGE_SIZE);
const casePage = ref(1);
const hasMoreCasePages = ref(true);
const isCasesLoading = ref(true);
const isLoadingMoreCases = ref(false);

const displayedCases = computed(() => allCases.value.slice(0, displayCaseCount.value));
const canLoadMoreCase = computed(
	() => displayCaseCount.value < allCases.value.length || hasMoreCasePages.value,
);

const sectionTops = ref<number[]>([]);
const isScrollingToSection = ref(false);
const showCopyModal = ref(false);
const pageScrollTop = ref(0);
const scrollWithAnimation = ref(false);
const bannerHeightPx = ref(0);
let scrollTopCache = 0;

const tabBarHeightPx = computed(() => {
	try {
		return uni.upx2px(TAB_BAR_HEIGHT_RPX);
	} catch {
		return 44;
	}
});

const tabScrollOffset = computed(() => tabBarHeightPx.value + 8);

const isFavorited = computed(() => {
	if (!accountinfo.value || !enterprise.value) return false;
	return accountinfo.value.enterprise.has(enterprise.value.id);
});

const needBriefToggle = computed(() => (enterprise.value?.brief?.length || 0) > 40);

watch(
	() => enterprise.value?.images,
	() => {
		bannerHeightPx.value = 0;
	},
);

watch(bannerHeightPx, () => {
	nextTick(() => setTimeout(calculateSectionTops, 100));
});

const bannerSwiperStyle = computed(() => ({
	height: bannerHeightPx.value > 0 ? `${bannerHeightPx.value}px` : "1px",
}));

const onBannerImageLoad = (e: any) => {
	const { width, height } = e.detail || {};
	if (!width || !height) return;
	try {
		const sys = uni.getSystemInfoSync();
		const h = (sys.windowWidth * height) / width;
		if (h > bannerHeightPx.value) bannerHeightPx.value = h;
	} catch {
		const h = (750 * height) / width;
		if (h > bannerHeightPx.value) bannerHeightPx.value = h;
	}
};

const onSwiperChange = (e: any) => {
	swiperIndex.value = e.detail.current;
};

const toggleBrief = () => {
	isBriefExpanded.value = !isBriefExpanded.value;
	nextTick(() => setTimeout(calculateSectionTops, 100));
};

const onFieldTap = (id: number) => {
	navigator("/mainpage/fielddetail", { field: id });
};

const onArticleTap = (url: string) => {
	openOfficialAccountArticle(url);
};

const openWebsite = (url?: string) => {
	if (!url) return;
	openExternalUrl(url);
};

const copyWebsite = (url?: string) => {
	if (!url) return;
	uni.setClipboardData({
		data: url,
		success: () => {
			showCopyModal.value = true;
		},
	});
};

const onConsultTap = () => {
	showCopyModal.value = false;
	navigator("/kefu");
};

const formatArticleDate = (art: Article) => {
	const ts = art.publishTime || art.update;
	if (!ts) return "--";
	const d = new Date(ts * 1000);
	const y = d.getFullYear();
	const m = String(d.getMonth() + 1).padStart(2, "0");
	const day = String(d.getDate()).padStart(2, "0");
	return `${y}-${m}-${day}`;
};

const toggleFavorite = async () => {
	if (!accountinfo.value || !enterprise.value) return;
	if (accountinfo.value.enterprise.has(enterprise.value.id)) {
		accountinfo.value.enterprise.delete(enterprise.value.id);
	} else {
		accountinfo.value.enterprise.add(enterprise.value.id);
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
			if (enterprise.value) loadCases({ silent: true });
		} catch (err) {
			console.error("Failed to login with WeChat code:", err);
			uni.showToast({ title: "登录失败", icon: "none" });
		}
	} else {
		uni.showToast({ title: "获取手机号失败", icon: "none" });
	}
};

const onCasesLoggedIn = () => {
	loadCases({ silent: true });
};

const loadCases = async (options?: { silent?: boolean }) => {
	if (!enterprise.value) return;
	const silent = options?.silent ?? false;
	if (!silent) {
		isCasesLoading.value = true;
	}
	casePage.value = 1;
	displayCaseCount.value = PAGE_SIZE;
	try {
		const list = await RequestCase(enterprise.value.id, 0, 0, 0, 0, 0, 0, 1);
		allCases.value = list;
		hasMoreCasePages.value = list.length >= 20;
	} catch (err) {
		console.error("Failed to load cases:", err);
		if (!silent) {
			allCases.value = [];
		}
	} finally {
		isCasesLoading.value = false;
		nextTick(() => setTimeout(calculateSectionTops, 300));
	}
};

const loadMoreCase = async () => {
	if (isLoadingMoreCases.value) return;
	if (displayCaseCount.value < allCases.value.length) {
		displayCaseCount.value = Math.min(allCases.value.length, displayCaseCount.value + PAGE_SIZE);
		nextTick(() => setTimeout(calculateSectionTops, 100));
		return;
	}
	if (!enterprise.value || !hasMoreCasePages.value) return;
	isLoadingMoreCases.value = true;
	const nextPage = casePage.value + 1;
	try {
		const more = await RequestCase(enterprise.value.id, 0, 0, 0, 0, 0, 0, nextPage);
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
	} finally {
		isLoadingMoreCases.value = false;
		nextTick(() => setTimeout(calculateSectionTops, 100));
	}
};

const calculateSectionTops = () => {
	const query = uni.createSelectorQuery();
	query.select(".detail-scroll").boundingClientRect();
	for (let i = 0; i < SECTION_COUNT; i++) {
		query.select(`#section-${i}`).boundingClientRect();
	}
	query.exec((res) => {
		if (!res || res.length < SECTION_COUNT + 1) return;
		const scrollViewRect = res[0];
		if (!scrollViewRect) return;
		const tops: number[] = [];
		for (let i = 0; i < SECTION_COUNT; i++) {
			const rect = res[i + 1];
			tops.push(rect ? scrollTopCache + rect.top - scrollViewRect.top : 0);
		}
		sectionTops.value = tops;
	});
};

const scrollToSection = (index: number) => {
	isScrollingToSection.value = true;
	fenyeindex.value = index;
	const query = uni.createSelectorQuery();
	query.select(`#section-${index}`).boundingClientRect();
	query.select(".detail-scroll").boundingClientRect();
	query.exec((res) => {
		if (res && res[0] && res[1]) {
			const targetScrollTop = scrollTopCache + res[0].top - res[1].top - tabScrollOffset.value;
			scrollWithAnimation.value = true;
			pageScrollTop.value = scrollTopCache;
			nextTick(() => {
				pageScrollTop.value = Math.max(0, targetScrollTop);
				setTimeout(() => {
					isScrollingToSection.value = false;
					scrollWithAnimation.value = false;
				}, 350);
			});
		} else {
			isScrollingToSection.value = false;
		}
	});
};

const onDetailScroll = (e: { detail: { scrollTop: number } }) => {
	scrollTopCache = e.detail.scrollTop;
	if (isScrollingToSection.value || sectionTops.value.length === 0) return;
	const scrollTop = e.detail.scrollTop;
	let activeIndex = 0;
	for (let i = 0; i < sectionTops.value.length; i++) {
		if (scrollTop >= sectionTops.value[i] - tabScrollOffset.value) {
			activeIndex = i;
		}
	}
	if (activeIndex !== fenyeindex.value) {
		fenyeindex.value = activeIndex;
	}
};

watch(
	() => enterprise.value?.id,
	() => {
		nextTick(() => setTimeout(calculateSectionTops, 300));
	}
);

onLoad(async (options) => {
	let enterpriseId = 0;
	if (options && options.enterprise) {
		enterpriseId = parseInt(options.enterprise, 10) || 0;
	}

	if (enterpriseId > 0) {
		const found = enterpriselist.value.find((e) => e.id === enterpriseId);
		if (found) {
			enterprise.value = found;
			initialized.value = true;
			loadCases();
		} else {
			try {
				enterprise.value = await RequestEnterpriseDetail(enterpriseId);
				initialized.value = true;
				loadCases();
			} catch (err) {
				console.error("Failed to load enterprise detail:", err);
				uni.showToast({ title: "加载失败", icon: "none" });
			}
		}
	}

	if (enterprise.value?.name) {
		uni.setNavigationBarTitle({ title: enterprise.value.name });
	}

	nextTick(() => setTimeout(calculateSectionTops, 400));
});
</script>

<style scoped>
.detail-root {
	display: flex;
	flex-direction: column;
	width: 100%;
	height: 100vh;
	overflow: hidden;
	background-color: #f8f8f8;
	box-sizing: border-box;
}

.detail-scroll {
	flex: 1;
	min-height: 0;
	width: 100%;
}

.detail-page {
	display: flex;
	flex-direction: column;
	width: 100%;
	background-color: #f8f8f8;
	padding-bottom: 132rpx;
	box-sizing: border-box;
}

.banner-wrap {
	position: relative;
	width: 100%;
}

.top-swiper {
	width: 100%;
}

.top-swiper swiper-item {
	height: 100%;
}

.banner-image {
	display: block;
	width: 100%;
}

.swiper-indicator {
	position: absolute;
	right: 64rpx;
	bottom: 20rpx;
	background-color: rgba(0, 0, 0, 0.5);
	padding: 8rpx 32rpx;
	border-radius: 40rpx;
}

.indicator-text {
	color: #ffffff;
	font-size: 40rpx;
}

.main-panel {
	margin-top: 0;
	background-color: #ffffff;
	border-radius: 20rpx 20rpx 0 0;
	position: relative;
	z-index: 1;
}

.tab-bar {
	position: sticky;
	top: 0;
	z-index: 100;
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: space-between;
	height: 88rpx;
	padding: 0 48rpx;
	background-color: #ffffff;
	box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.05);
	box-sizing: border-box;
}

.tab-item {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	height: 100%;
	flex: 1;
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
	background-color: transparent;
	border-radius: 2rpx;
}

.tab-line-active {
	background-color: #1269ff;
}

.sections-inner {
	background-color: #f8f8f8;
	padding-bottom: 40rpx;
}

.section-card {
	background-color: #ffffff;
	border-radius: 20rpx;
	padding-bottom: 40rpx;
	box-sizing: border-box;
}

.section-gap {
	height: 30rpx;
	background-color: #f8f8f8;
}

.name-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	height: 128rpx;
	padding: 0 64rpx;
	box-sizing: border-box;
}

.name-marquee-col {
	flex: 1;
	min-width: 0;
	margin-right: 20rpx;
}

.enterprise-name-text {
	font-size: 44rpx;
	font-weight: 500;
	color: #000000;
	line-height: 64rpx;
	display: -webkit-box;
	-webkit-box-orient: vertical;
	-webkit-line-clamp: 2;
	overflow: hidden;
	word-break: break-all;
}

.enterprise-icon-wrap {
	width: 128rpx;
	height: 128rpx;
	flex-shrink: 0;
	background-color: #ffffff;
	border-radius: 10rpx;
	box-shadow:
		0 -2rpx 6rpx 0 rgba(0, 0, 0, 0.05),
		0 8rpx 8rpx 0 rgba(0, 0, 0, 0.1);
	overflow: hidden;
	display: flex;
	align-items: center;
	justify-content: center;
}

.enterprise-icon {
	width: 128rpx;
	height: 128rpx;
	flex-shrink: 0;
}

.location-row {
	display: inline-flex;
	flex-direction: row;
	align-items: center;
	margin-top: 10rpx;
	margin-left: 64rpx;
	padding: 6rpx 10rpx 6rpx 6rpx;
	background-color: #edf2f8;
	box-sizing: border-box;
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
}

.tags-scroll {
	width: 100%;
	margin-top: 10rpx;
	padding: 0 64rpx;
	box-sizing: border-box;
}

.tags-row {
	display: inline-flex;
	flex-direction: row;
	flex-wrap: nowrap;
	align-items: center;
	gap: 3rpx;
}

.tag-badge {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	padding: 1rpx 3rpx;
	background-color: #fef5e6;
	border-radius: 6rpx;
	flex-shrink: 0;
}

.tag-text {
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 400;
	color: #80500a;
	white-space: nowrap;
}

.brief-box {
	margin-top: 20rpx;
	padding: 0 64rpx;
}

.brief-content {
	position: relative;
}

.brief-desc {
	font-size: 28rpx;
	line-height: 48rpx;
	font-weight: 350;
	color: #000000;
	letter-spacing: 0.05em;
	word-break: break-word;
}

.brief-content-collapsed {
	max-height: 192rpx;
	overflow: hidden;
}

.brief-toggle-inline,
.brief-toggle-text {
	font-size: 28rpx;
	line-height: 48rpx;
	color: #5e80f7;
	font-weight: 350;
}

.brief-toggle-overlay {
	position: absolute;
	right: 0;
	bottom: 0;
	height: 48rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	padding-left: 72rpx;
	background: linear-gradient(90deg, rgba(255, 255, 255, 0) 0%, #ffffff 40%);
}

.brief-toggle-arrow {
	font-size: 28rpx;
	line-height: 48rpx;
	color: #5e80f7;
	margin-left: 4rpx;
}

.info-table {
	display: flex;
	flex-direction: column;
	margin-top: 20rpx;
	padding: 0 64rpx;
}

.table-row {
	display: flex;
	flex-direction: row;
	padding: 12rpx 0;
	align-items: flex-start;
}

.table-label {
	width: 140rpx;
	flex-shrink: 0;
	font-size: 30rpx;
	line-height: 44rpx;
	font-weight: 350;
	color: #6a727d;
}

.table-value {
	flex: 1;
	min-width: 0;
	font-size: 30rpx;
	line-height: 44rpx;
	font-weight: 350;
	color: #000000;
	word-break: break-all;
}

.table-link {
	color: #5e80f7;
	text-decoration: underline;
}

.table-copy {
	flex-shrink: 0;
	margin-left: 16rpx;
	font-size: 30rpx;
	line-height: 44rpx;
	font-weight: 350;
	color: #5e80f7;
}

.block-title {
	display: block;
	font-size: 40rpx;
	line-height: 58rpx;
	font-weight: 700;
	color: #000000;
	padding: 40rpx 64rpx 16rpx 64rpx;
}

.fields-list {
	display: flex;
	flex-direction: column;
	padding: 0 64rpx;
	gap: 4rpx;
}

.field-card {
	min-height: 134rpx;
	border: 1rpx solid #e7e7e7;
	border-radius: 10rpx;
	padding: 16rpx 0;
	box-sizing: border-box;
	display: flex;
	flex-direction: column;
	justify-content: center;
}

.field-name {
	font-size: 34rpx;
	line-height: 50rpx;
	font-weight: 350;
	color: #000000;
	padding-left: 30rpx;
}

.field-meta-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-top: 10rpx;
	margin-left: 30rpx;
	margin-right: 30rpx;
}

.field-meta-bar {
	display: inline-flex;
	flex-direction: row;
	align-items: center;
	padding: 4rpx 20rpx;
	background-color: #f6f6fa;
	border-radius: 8rpx;
	box-sizing: border-box;
	flex-shrink: 0;
}

.field-type {
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 400;
	color: #394156;
	flex-shrink: 0;
}

.field-meta-divider {
	width: 1rpx;
	height: 24rpx;
	background-color: #d9d9d9;
	margin: 0 20rpx;
	flex-shrink: 0;
}

.field-stars-label {
	font-size: 24rpx;
	line-height: 28rpx;
	font-weight: 400;
	color: #000000;
	flex-shrink: 0;
}

.star-icon {
	color: #ff9800;
	font-size: 24rpx;
	line-height: 28rpx;
	margin-right: 4rpx;
}

.field-detail-link {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-left: auto;
	flex-shrink: 0;
}

.field-detail-text {
	font-size: 26rpx;
	line-height: 38rpx;
	font-weight: 350;
	color: #5e80f7;
}

.field-detail-arrow {
	font-size: 26rpx;
	line-height: 38rpx;
	color: #5e80f7;
	margin-left: 4rpx;
}

.articles-list {
	display: flex;
	flex-direction: column;
	padding: 0 64rpx;
	gap: 24rpx;
}

.article-card {
	background-color: #ffffff;
	border-radius: 20rpx;
	padding: 32rpx;
	border: 1rpx solid #eeeeee;
	box-sizing: border-box;
}

.article-title {
	font-size: 28rpx;
	font-weight: 700;
	color: #333333;
	line-height: 1.4;
	margin-bottom: 8rpx;
	display: -webkit-box;
	-webkit-box-orient: vertical;
	-webkit-line-clamp: 2;
	overflow: hidden;
}

.article-desc {
	font-size: 24rpx;
	color: #666666;
	line-height: 1.4;
	display: -webkit-box;
	-webkit-box-orient: vertical;
	-webkit-line-clamp: 2;
	overflow: hidden;
}

.article-footer {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: space-between;
	margin-top: 24rpx;
}

.article-account {
	display: flex;
	flex-direction: row;
	align-items: center;
	flex: 1;
	min-width: 0;
}

.account-icon {
	width: 40rpx;
	height: 40rpx;
	border-radius: 50%;
	flex-shrink: 0;
	margin-right: 12rpx;
}

.account-name {
	font-size: 20rpx;
	line-height: 30rpx;
	font-weight: 400;
	color: #000000;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.article-time {
	font-size: 20rpx;
	line-height: 30rpx;
	font-weight: 350;
	color: #818181;
	flex-shrink: 0;
	margin-left: auto;
}

.cases-wrapper {
	position: relative;
	width: 100%;
	padding: 0 64rpx;
	box-sizing: border-box;
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

.cases-loading {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 40rpx 0;
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

.load-more-bar-disabled {
	opacity: 0.6;
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

.section-empty {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 40rpx 0;
}

.empty-text,
.loading-text {
	font-size: 28rpx;
	color: #888888;
}

.modal-mask {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: rgba(0, 0, 0, 0.5);
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 1000;
}

.modal-container {
	width: 560rpx;
	height: 770rpx;
	background-color: #ffffff;
	border-radius: 20rpx;
	box-shadow:
		0 4rpx 8rpx 0 rgba(0, 0, 0, 0.02),
		0 2rpx 4rpx 0 rgba(0, 0, 0, 0.03);
	display: flex;
	flex-direction: column;
	align-items: center;
	box-sizing: border-box;
}

.modal-check-icon {
	width: 156rpx;
	height: 156rpx;
	margin-top: 98rpx;
	flex-shrink: 0;
}

.modal-title {
	margin-top: 56rpx;
	font-size: 44rpx;
	line-height: 64rpx;
	font-weight: 700;
	color: #000000;
}

.modal-desc {
	margin-top: 40rpx;
	width: 438rpx;
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 300;
	color: #3d3d3d;
	text-align: center;
}

.modal-divider {
	margin-top: 54rpx;
	width: 486rpx;
	height: 2rpx;
	background-color: #e6e6e6;
	flex-shrink: 0;
}

.modal-buttons {
	margin-top: 60rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	gap: 50rpx;
}

.modal-btn {
	width: 220rpx;
	height: 80rpx;
	border-radius: 10rpx;
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 500;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 0;
	margin: 0;
	box-sizing: border-box;
}

.modal-btn::after {
	border: none;
}

.btn-later {
	background-color: #ffffff;
	color: #333333;
	border: 2rpx solid #b2b5bc;
}

.btn-consult {
	background-color: #2d7bff;
	color: #ffffff;
	border: none;
}
</style>
