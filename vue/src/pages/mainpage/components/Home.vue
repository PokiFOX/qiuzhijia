<template>
	<view class="home-container">
		<!-- 动态顶部留白 -->
		<view :style="{ height: `${navBarHeight}px` }"></view>

		<!-- Swiper Banner -->
		<swiper
			class="swiper-banner"
			circular
			autoplay
			:interval="3000"
			indicator-dots
			indicator-active-color="#007aff"
			indicator-color="rgba(0,0,0,.3)"
		>
			<swiper-item v-for="(img, idx) in imageurls" :key="idx">
				<image class="swiper-image" :src="parseimage(img)" mode="aspectFill" />
			</swiper-item>
		</swiper>

		<view class="divider-space"></view>

		<!-- LanMu Grid -->
		<view class="grid-card">
			<view class="grid-container">
				<view
					class="grid-item"
					v-for="(item, idx) in lanmus"
					:key="idx"
					@tap="onLanMuTap(idx)"
				>
					<image class="grid-icon" :src="parseimage(item.image)" mode="aspectFit" />
					<text class="grid-text">{{ item.title }}</text>
				</view>
			</view>
		</view>

		<view class="divider-space"></view>

		<!-- FenYe Header -->
		<view class="section-header">
			<view class="section-title-container">
				<text class="section-title">求职解析</text>
			</view>
		</view>

		<!-- Article List -->
		<view class="article-list">
			<view
				class="article-item"
				v-for="(article, idx) in displayedArticles"
				:key="idx"
				@tap="openOfficialAccountArticle(article.article)"
			>
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
import { ref, computed, onMounted } from "vue";
import { RequestArticle1 } from "../../../tapah/request";
import { article1 } from "../../../tapah/data";
import {
	parseimage,
	openOfficialAccountArticle,
	navigator,
	activateMainPageTab,
	getWechatNavMetrics,
} from "../../../tapah/function";
import { lanmus, imageurls } from "../../../tapah/option";

const navBarHeight = computed(() => getWechatNavMetrics().navBarHeight);

const displayCount = ref(5);

const displayedArticles = computed(() => {
	return article1.value.slice(0, displayCount.value);
});

const hasMore = computed(() => {
	return displayCount.value < article1.value.length;
});

const loadMore = () => {
	if (!hasMore.value) return;
	displayCount.value = Math.min(article1.value.length, displayCount.value + 5);
};

// Expose the loadMore method so the parent page can call it
defineExpose({
	loadMore,
});

const onLanMuTap = (index: number) => {
	if (index === 0) {
		activateMainPageTab(1);
	} else if (index === 1) {
		navigator("/mainpage/field");
	} else if (index === 2) {
		// Open mini-program
		// @ts-ignore
		if (typeof wx !== "undefined" && wx.navigateToMiniProgram) {
			// @ts-ignore
			wx.navigateToMiniProgram({
				appId: "wx320a7a97e2f254e2",
				path: "/pages/entry/share?o=store&type=39&id=2",
			});
		} else {
			uni.showToast({
				title: "请在微信小程序中打开",
				icon: "none",
			});
		}
	} else if (index === 3) {
		navigator("/mainpage/example");
	} else if (index === 4) {
		navigator("/lanmu/aizhushou");
	} else if (index === 5) {
		navigator("/lanmu/qiuzhiziliao");
	} else if (index === 6) {
		navigator("/lanmu/shixineitui");
	} else if (index === 7) {
		navigator("/lanmu/gangweineitui");
	} else if (index === 8) {
		navigator("/lanmu/zixunguwen");
	} else if (index === 9) {
		navigator("/lanmu/bishitiku");
	} else if (index === 10) {
		navigator("/lanmu/mianshijingyan");
	} else if (index === 11) {
		navigator("/lanmu/qiuzhifuwu");
	}
};

onMounted(async () => {
	try {
		await RequestArticle1();
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
	padding: 0 20rpx;
	box-sizing: border-box;
}

.swiper-banner {
	width: 100%;
	height: 360rpx;
	border-radius: 16rpx;
	overflow: hidden;
}

.swiper-image {
	width: 100%;
	height: 100%;
}

.divider-space {
	height: 40rpx;
}

.grid-card {
	background-color: #ffffff;
	border-radius: 10rpx;
	padding: 10rpx;
}

.grid-container {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	row-gap: 36rpx;
	column-gap: 36rpx;
}

.grid-item {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.grid-icon {
	width: 106rpx;
	height: 106rpx;
}

.grid-text {
	font-size: 24rpx;
	color: #333333;
	margin-top: 8rpx;
}

.section-header {
	width: 100%;
	height: 50rpx;
	display: flex;
	align-items: center;
}

.section-title-container {
	padding-left: 10rpx;
}

.section-title {
	font-size: 26rpx;
	color: #000000;
	font-weight: bold;
}

.article-list {
	display: flex;
	flex-direction: column;
	margin-top: 10rpx;
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
