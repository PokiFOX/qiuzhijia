<template>
	<view class="mainpage-layout">
		<view v-if="currentindex !== 4" class="page-nav" :style="navBarStyle">
			<view class="nav-side nav-side-left">
				<view v-if="currentindex === 1" class="nav-back" :style="navSideStyle" @tap="switchTab(0)">
					<text class="nav-back-icon">‹</text>
				</view>
			</view>
			<text class="nav-title" :style="navTitleStyle">{{ navTitle }}</text>
			<view class="nav-side nav-side-right"></view>
		</view>

		<!-- Tab contents -->
		<view class="tab-content-container">
			<scroll-view v-if="activated[0]" v-show="currentindex === 0" class="tab-view tab-scroll-view" scroll-y enhanced :show-scrollbar="false" :lower-threshold="80" @scrolltolower="onHomeReachBottom">
				<home ref="homeRef" />
			</scroll-view>
			<view v-if="activated[1]" v-show="currentindex === 1" class="tab-view">
				<enterprise ref="enterpriseRef" />
			</view>
			<view v-if="activated[2]" v-show="currentindex === 2" class="tab-view">
				<view class="placeholder-container">
					<text class="placeholder-text">OFFER占位</text>
				</view>
			</view>
			<view v-if="activated[3]" v-show="currentindex === 3" class="tab-view">
				<qiuzhifuwu embedded />
			</view>
			<view v-if="activated[4]" v-show="currentindex === 4" class="tab-view">
				<profile />
			</view>
		</view>

		<!-- Custom Bottom Tab Bar -->
		<view class="bottom-tab-bar">
			<view class="tab-bar-plate">
				<image class="tab-bar-strip" :src="parseimage('底部按钮/底部长条.png')" mode="widthFix" />
				<image class="tab-bar-center" :src="parseimage('底部按钮/底部中间.png')" mode="aspectFit" />
			</view>
			<view class="tab-bar-items">
				<view class="tab-item" @tap="switchTab(0)">
				<image class="tab-icon" :src="parseimage(currentindex === 0 ? '底部按钮/首页-选中.png' : '底部按钮/首页-普通.png')" mode="aspectFit"/>
					<text class="tab-text" :class="{ active: currentindex === 0 }">首页</text>
				</view>
				<view class="tab-item" @tap="switchTab(1)">
				<image class="tab-icon" :src="parseimage(currentindex === 1 ? '底部按钮/招聘企业-选中.png' : '底部按钮/招聘企业-普通.png')" mode="aspectFit"/>
				<text class="tab-text" :class="{ active: currentindex === 1 }">招聘企业</text>
			</view>
			<view class="tab-item offer-tab" @tap="onOfferTap">
				<image class="tab-icon offer-icon" :src="parseimage(currentindex === 2 ? '底部按钮/offer-选中.png' : '底部按钮/offer-普通.png')" mode="aspectFit"/>
				<text class="tab-text" :class="{ active: currentindex === 2 }">OFFER</text>
			</view>
			<view class="tab-item" @tap="switchTab(3)">
				<image class="tab-icon" :src="parseimage(currentindex === 3 ? '底部按钮/服务-选中.png' : '底部按钮/服务-普通.png')" mode="aspectFit"/>
				<text class="tab-text" :class="{ active: currentindex === 3 }">服务</text>
			</view>
			<view class="tab-item" @tap="switchTab(4)">
				<image class="tab-icon" :src="parseimage(currentindex === 4 ? '底部按钮/个人中心-选中.png' : '底部按钮/个人中心-普通.png')" mode="aspectFit"/>
				<text class="tab-text" :class="{ active: currentindex === 4 }">个人中心</text>
			</view>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from "vue";
import { onReachBottom, onLoad } from "@dcloudio/uni-app";

import { EventManager } from "../../tapah/class";
import { SceneID, EventType } from "../../tapah/enum";
import { parseimage, navigator, getWechatNavMetrics } from "../../tapah/function";

import home from "./components/home.vue";
import qiuzhifuwu from "../lanmu/qiuzhifuwu/qiuzhifuwu.vue";
import enterprise from "./components/enterprise.vue";
import profile from "./components/profile.vue";

const currentindex = ref(0);
const activated = ref([true, false, false, false, false]);
const homeRef = ref<InstanceType<typeof home> | null>(null);
const enterpriseRef = ref<InstanceType<typeof enterprise> | null>(null);

const metrics = computed(() => getWechatNavMetrics());

const navTitle = computed(() => {
	switch (currentindex.value) {
		case 1:
			return "招聘企业";
		case 2:
			return "OFFER";
		case 3:
			return "服务";
		case 4:
			return "个人中心";
		default:
			return "浦浦求职家";
	}
});

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

const switchTab = (index: number) => {
	activated.value[index] = true;
	currentindex.value = index;
};

const onOfferTap = () => {
	navigator("/mainpage/example");
};

const onHomeReachBottom = () => {
	if (currentindex.value !== 0) return;
	homeRef.value?.loadMore();
};

// Handle programmatical tab activation
onMounted(() => {
	EventManager().init(SceneID.mainpage);
	EventManager().add(SceneID.mainpage, EventType.mainpage_activate, (param?: any[]) => {
		if (param && typeof param[0] === "number") {
			switchTab(param[0]);
		}
	});
});

onUnmounted(() => {
	EventManager().uninit(SceneID.mainpage);
});

// Handle page arguments (e.g. index passed via route settings)
onLoad((options) => {
	if (options && options.index) {
		const idx = parseInt(options.index, 10);
		if (!isNaN(idx) && idx >= 0 && idx < 5) {
			switchTab(idx);
		}
	}
});

// Handle infinite scroll on reach bottom (enterprise tab; home uses scroll-view scrolltolower)
onReachBottom(() => {
	if (currentindex.value === 1) {
		enterpriseRef.value?.loadMore();
	}
});
</script>

<style scoped>
.mainpage-layout {
	display: flex;
	flex-direction: column;
	width: 100vw;
	height: 100vh;
	box-sizing: border-box;
	background-color: #f8f8f8;
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

.tab-content-container {
	flex: 1;
	width: 100%;
	box-sizing: border-box;
	overflow: hidden;
	min-height: 0;
}

.tab-view {
	width: 100%;
	height: 100%;
	overflow: hidden;
	min-height: 0;
}

.tab-scroll-view {
	height: 100%;
	overflow: hidden;
	scrollbar-width: none;
	-ms-overflow-style: none;
}

.tab-scroll-view::-webkit-scrollbar {
	display: none;
	width: 0;
	height: 0;
}

.placeholder-container {
	display: flex;
	width: 100%;
	height: 100%;
	align-items: center;
	justify-content: center;
	padding-top: 200rpx;
}

.placeholder-text {
	font-size: 32rpx;
	color: #999999;
}

.bottom-tab-bar {
	position: fixed;
	left: 0;
	right: 0;
	bottom: 0;
	height: calc(152rpx + env(safe-area-inset-bottom));
	padding-bottom: env(safe-area-inset-bottom);
	box-sizing: border-box;
	z-index: 999;
	background-color: transparent;
}

.tab-bar-plate {
	position: absolute;
	left: 0;
	right: 0;
	bottom: 0;
	width: 100%;
	pointer-events: none;
	background-color: transparent;
}

.tab-bar-strip {
	position: relative;
	z-index: 0;
	display: block;
	width: 100%;
}

.tab-bar-center {
	position: absolute;
	left: 50%;
	bottom: 32rpx;
	width: 120rpx;
	height: 120rpx;
	transform: translateX(-50%);
	z-index: 1;
}

.tab-bar-items {
	display: flex;
	flex-direction: row;
	align-items: flex-end;
	position: absolute;
	left: 0;
	right: 0;
	bottom: 0;
	z-index: 2;
	height: 104rpx;
	padding-bottom: 12rpx;
	box-sizing: border-box;
	overflow: visible;
}

.tab-item {
	flex: 1;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: flex-end;
	height: 100%;
	box-sizing: border-box;
	position: relative;
}

.tab-icon {
	width: 48rpx;
	height: 48rpx;
	flex-shrink: 0;
}

.offer-tab {
	position: relative;
	justify-content: flex-end;
	overflow: visible;
}

.offer-icon {
	position: absolute;
	left: 50%;
	bottom: 24rpx;
	width: 96rpx;
	height: 96rpx;
	transform: translateX(-50%);
	flex-shrink: 0;
	z-index: 1;
}

.tab-text {
	position: relative;
	z-index: 1;
	font-size: 20rpx;
	line-height: 28rpx;
	color: #3d3d3d;
	margin-top: 4rpx;
}

.tab-text.active {
	color: #1269ff;
}
</style>
