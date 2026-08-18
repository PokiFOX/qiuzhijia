<template>
	<view class="home-container">
		<view class="home-top-panel">
			<!-- Swiper Banner -->
			<view class="banner-wrap">
				<swiper class="swiper-banner" circular autoplay :interval="3000" indicator-dots indicator-active-color="#1269FF" indicator-color="rgba(0,0,0,.3)">
					<swiper-item v-for="(img, idx) in imageurls" :key="idx">
						<image class="swiper-image" :src="parseimage(img)" mode="aspectFill" />
					</swiper-item>
				</swiper>
			</view>

			<!-- LanMu Grid Card -->
			<view class="grid-card">
				<swiper class="lanmu-swiper" :current="lanmuPage" @change="onLanmuPageChange">
					<swiper-item v-for="(pageItems, pageIdx) in lanmuPages" :key="pageIdx">
						<view
							class="lanmu-page"
							:class="{
								'lanmu-page-has-prev': pageIdx > 0,
								'lanmu-page-has-next': pageIdx < lanmuPages.length - 1,
							}"
						>
							<view class="lanmu-row" v-for="(row, rowIdx) in pageRows(pageItems)" :key="rowIdx">
								<view class="grid-item" v-for="(item, colIdx) in row" :key="colIdx" @tap="onLanMuTap(pageIdx * 10 + rowIdx * 5 + colIdx)">
									<template v-if="item">
										<image class="grid-icon" :src="parseimage(item.image)" mode="aspectFit" />
										<text class="grid-text">{{ item.title }}</text>
									</template>
									<template v-else>
										<view class="grid-icon-placeholder" />
										<text class="grid-text"> </text>
									</template>
								</view>
							</view>
						</view>
					</swiper-item>
				</swiper>
				<view class="lanmu-dots">
					<view v-for="(_, idx) in lanmuPages" :key="idx" class="lanmu-dot" :class="{ active: lanmuPage === idx }"/>
				</view>
			</view>

			<!-- Promo three images -->
			<view class="promo-row">
				<image class="promo-left" :style="promoLeftStyle" :src="parseimage('实习推荐.png')" mode="aspectFill" @tap="onPromoTap('shixineitui')"/>
				<view class="promo-right" :style="promoRightStyle">
					<image class="promo-right-item" :style="promoRightItemStyle" :src="parseimage('求职全套.png')" mode="aspectFill" @tap="onPromoTap('qiuzhifuwu')"/>
					<image class="promo-right-item" :style="promoRightItemStyle" :src="parseimage('教授科研.png')" mode="aspectFill" @tap="onPromoTap('kefu')"/>
				</view>
			</view>
		</view>

		<!-- FenYe Header -->
		<view class="section-header">
			<view v-for="(tab, index) in fenyes" :key="index" class="fenye-tab" @tap="onFenyeTap(index)">
				<text class="fenye-tab-text" :class="{ active: fenyeIndex === index }">{{ tab.title }}</text>
				<view class="fenye-tab-line" :class="{ active: fenyeIndex === index }" />
			</view>
		</view>

		<!-- Article List -->
		<view class="article-list">
			<view class="article-item" v-for="(article, idx) in displayedArticles" :key="idx" @tap="openOfficialAccountArticle(article.article)">
				<view class="article-content">
					<text class="article-title">{{ article.title || "未知标题" }}</text>
					<text class="article-desc">{{ article.description }}</text>
				</view>
			</view>

			<view v-if="displayedArticles.length === 0" class="empty-text">
				<text>暂无文章</text>
			</view>
			<view v-else-if="hasMore" class="loading-text">
				<text>加载中...</text>
			</view>
			<view v-else class="no-more-text">
				<text>没有更多了</text>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, type CSSProperties } from "vue";

import { article1, article2 } from "../../../tapah/data";
import { parseimage, openOfficialAccountArticle, navigator, activateMainPageTab, KeFu, } from "../../../tapah/function";
import { lanmus, imageurls, LanMuInfo, fenyes } from "../../../tapah/option";
import { RequestArticle1, RequestArticle2 } from "../../../tapah/request";

const PAGE_MARGIN_RPX = 32;
const PROMO_COL_GAP_RPX = 10;
const PROMO_ROW_GAP_RPX = 14;

const getWindowWidth = () => {
	try {
		return uni.getSystemInfoSync().windowWidth;
	} catch {
		return 375;
	}
};

const windowWidthPx = ref(getWindowWidth());

const rpxToPx = (rpx: number) => (rpx / 750) * windowWidthPx.value;

const contentWidthPx = computed(() => windowWidthPx.value - rpxToPx(PAGE_MARGIN_RPX * 2));

const promoLeftStyle = computed((): CSSProperties => {
	const total = contentWidthPx.value;
	if (total <= 0) return {};
	const gap = rpxToPx(PROMO_COL_GAP_RPX);
	const width = (total - gap) * (178 / 354);
	const height = width * (157 / 178);
	return {
		width: `${width}px`,
		height: `${height}px`,
		marginRight: `${gap}px`,
	};
});

const promoRightStyle = computed((): CSSProperties => {
	const total = contentWidthPx.value;
	if (total <= 0) return {};
	const gap = rpxToPx(PROMO_COL_GAP_RPX);
	const width = (total - gap) * (176 / 354);
	return { width: `${width}px` };
});

const promoRightItemStyle = computed((): CSSProperties => {
	const total = contentWidthPx.value;
	if (total <= 0) return {};
	const gap = rpxToPx(PROMO_COL_GAP_RPX);
	const width = (total - gap) * (176 / 354);
	const height = width * (75 / 176);
	return {
		width: `${width}px`,
		height: `${height}px`,
	};
});

const refreshLayout = () => {
	windowWidthPx.value = getWindowWidth();
};

const lanmuPage = ref(0);
const fenyeIndex = ref(0);
const PAGE_SIZE = 10;

const lanmuPages = computed(() => {
	const pages: (LanMuInfo | null)[][] = [];
	for (let i = 0; i < lanmus.length; i += PAGE_SIZE) {
		const chunk: (LanMuInfo | null)[] = lanmus.slice(i, i + PAGE_SIZE);
		while (chunk.length < PAGE_SIZE) chunk.push(null);
		pages.push(chunk);
	}
	return pages.length ? pages : [Array(PAGE_SIZE).fill(null)];
});

const pageRows = (pageItems: (LanMuInfo | null)[]) => {
	return [pageItems.slice(0, 5), pageItems.slice(5, 10)];
};

const onLanmuPageChange = (e: { detail: { current: number } }) => {
	lanmuPage.value = e.detail.current;
};

const displayCount = ref(5);

const currentArticleList = computed(() => {
	if (fenyeIndex.value === 0) return article1.value;
	if (fenyeIndex.value === 1) return article2.value;
	return [];
});

const displayedArticles = computed(() => {
	return currentArticleList.value.slice(0, displayCount.value);
});

const hasMore = computed(() => {
	return displayCount.value < currentArticleList.value.length;
});

const onFenyeTap = (index: number) => {
	if (fenyeIndex.value === index) return;
	fenyeIndex.value = index;
	displayCount.value = 5;
};

const loadMore = () => {
	if (!hasMore.value) return;
	displayCount.value = Math.min(currentArticleList.value.length, displayCount.value + 5);
};

defineExpose({
	loadMore,
});

const openAiInterviewMiniProgram = () => {
	// @ts-ignore
	if (typeof wx !== "undefined" && wx.navigateToMiniProgram) {
		// @ts-ignore
		wx.navigateToMiniProgram({
			appId: "wx320a7a97e2f254e2",
			path: "/pages/entry/share?o=store&type=39&id=2",
		});
	} else {
		uni.showToast({ title: "请在微信小程序中打开", icon: "none" });
	}
};

const onLanMuTap = (index: number) => {
	if (index < 0 || index >= lanmus.length) return;
	const title = lanmus[index].title;

	switch (title) {
		case "招聘企业":
			activateMainPageTab(1);
			break;
		case "招聘专业":
			navigator("/mainpage/field");
			break;
		case "AI面试":
			openAiInterviewMiniProgram();
			break;
		case "AI助手":
			navigator("/lanmu/aizhushou");
			break;
		case "智能选岗":
			break;
		case "求职资料":
			navigator("/lanmu/qiuzhiziliao");
			break;
		case "岗位内推":
			navigator("/lanmu/gangweineitui");
			break;
		case "咨询顾问":
			navigator("/lanmu/zixunguwen");
			break;
		case "笔试题库":
			navigator("/lanmu/bishitiku");
			break;
		case "面试经验":
			navigator("/lanmu/mianshijingyan");
			break;
		case "实习内推":
			navigator("/lanmu/shixineitui");
			break;
		case "求职服务":
			navigator("/lanmu/qiuzhifuwu");
			break;
		case "教授科研":
			break;
		case "过往案例":
			navigator("/mainpage/example");
			break;
		case "DBTI":
			break;
	}
};

const onPromoTap = (kind: string) => {
	if (kind === "shixineitui") {
		navigator("/lanmu/shixineitui");
	} else if (kind === "qiuzhifuwu") {
		navigator("/lanmu/qiuzhifuwu");
	} else {
		KeFu();
	}
};

onMounted(async () => {
	refreshLayout();
	try {
		await Promise.all([RequestArticle1(), RequestArticle2()]);
	} catch (err) {
		console.error("Failed to load articles:", err);
	}
});
</script>

<style scoped>
.home-container {
	display: flex;
	flex-direction: column;
	width: 100%;
	padding: 0 32rpx;
	box-sizing: border-box;
	background-color: #f8f8f8;
	min-height: 100%;
}

.home-top-panel {
	display: flex;
	flex-direction: column;
	width: 100%;
	background-color: #ffffff;
	border-radius: 0 0 32rpx 32rpx;
	padding-bottom: 24rpx;
	box-sizing: border-box;
}

.banner-wrap {
	width: 100%;
	position: relative;
	height: 0;
	padding-bottom: 52.49%;
	margin-top: 16rpx;
	border-radius: 16rpx;
	overflow: hidden;
}

.swiper-banner {
	position: absolute;
	top: 0;
	left: 0;
	width: 100%;
	height: 100%;
}

.swiper-banner swiper-item {
	height: 100%;
}

.swiper-image {
	width: 100%;
	height: 100%;
	display: block;
}

.grid-card {
	width: 100%;
	height: 408rpx;
	margin-top: 24rpx;
	background-color: #ffffff;
	border-radius: 20rpx;
	box-shadow:
		0 18rpx 56rpx 16rpx rgba(0, 0, 0, 0.05),
		0 6rpx 12rpx -8rpx rgba(0, 0, 0, 0.12);
	box-sizing: border-box;
	padding: 32rpx 32rpx 0 32rpx;
	display: flex;
	flex-direction: column;
	align-items: center;
}

.lanmu-swiper {
	width: 100%;
	height: 320rpx;
	overflow: hidden;
}

.lanmu-page {
	display: flex;
	flex-direction: column;
	width: 100%;
	box-sizing: border-box;
}

/* 翻页时在相邻两页之间留出间距（仅 seam 侧内边距，不改页内 space-between 布局） */
.lanmu-page-has-prev {
	padding-left: 24rpx;
}

.lanmu-page-has-next {
	padding-right: 24rpx;
}

.lanmu-row {
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	width: 100%;
}

.lanmu-row + .lanmu-row {
	margin-top: 40rpx;
}

.grid-item {
	display: flex;
	flex-direction: column;
	align-items: center;
	width: 84rpx;
	flex-shrink: 0;
}

.grid-icon {
	width: 84rpx;
	height: 84rpx;
}

.grid-icon-placeholder {
	width: 84rpx;
	height: 84rpx;
}

.grid-text {
	margin-top: 16rpx;
	font-size: 22rpx;
	line-height: 40rpx;
	color: #3d3d3d;
	font-weight: 400;
	text-align: center;
	width: 120rpx;
	overflow: hidden;
	white-space: nowrap;
	text-overflow: ellipsis;
}

.lanmu-dots {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	margin-top: 24rpx;
	margin-bottom: 24rpx;
}

.lanmu-dot {
	width: 40rpx;
	height: 8rpx;
	border-radius: 4rpx;
	background-color: #d9d9d9;
	margin: 0 6rpx;
}

.lanmu-dot.active {
	background-color: #1269ff;
}

.promo-row {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	width: 100%;
	margin-top: 24rpx;
	box-sizing: border-box;
}

.promo-left {
	flex-shrink: 0;
	border-radius: 16rpx;
	display: block;
}

.promo-right {
	display: flex;
	flex-direction: column;
	flex-shrink: 0;
}

.promo-right-item {
	flex-shrink: 0;
	border-radius: 16rpx;
	display: block;
}

.promo-right-item + .promo-right-item {
	margin-top: 14rpx;
}

.section-header {
	width: 100%;
	display: flex;
	flex-direction: row;
	align-items: flex-end;
	justify-content: space-around;
	margin-top: 24rpx;
	padding-bottom: 8rpx;
	box-sizing: border-box;
}

.fenye-tab {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 0 8rpx;
}

.fenye-tab-text {
	font-size: 36rpx;
	line-height: 54rpx;
	color: #222222;
}

.fenye-tab-text.active {
	color: #4a92ff;
}

.fenye-tab-line {
	width: 48rpx;
	height: 6rpx;
	margin-top: 8rpx;
	border-radius: 3rpx;
	background-color: transparent;
}

.fenye-tab-line.active {
	background-color: #4a92ff;
}

.article-list {
	display: flex;
	flex-direction: column;
	width: 100%;
	margin-top: 10rpx;
	box-sizing: border-box;
}

.article-item {
	background-color: #ffffff;
	border-radius: 16rpx;
	padding: 20rpx;
	margin-bottom: 20rpx;
}

.article-content {
	display: flex;
	flex-direction: column;
	height: 160rpx;
}

.article-title {
	font-size: 30rpx;
	font-weight: bold;
	color: #000000;
	line-height: 1.4;
	display: -webkit-box;
	-webkit-box-orient: vertical;
	-webkit-line-clamp: 2;
	overflow: hidden;
}

.article-desc {
	font-size: 24rpx;
	color: #666666;
	margin-top: 8rpx;
	line-height: 1.4;
	display: -webkit-box;
	-webkit-box-orient: vertical;
	-webkit-line-clamp: 2;
	overflow: hidden;
	flex: 1;
}

.empty-text,
.loading-text,
.no-more-text {
	display: flex;
	justify-content: center;
	align-items: center;
	padding: 30rpx 0;
	font-size: 28rpx;
	color: #999999;
}
</style>
