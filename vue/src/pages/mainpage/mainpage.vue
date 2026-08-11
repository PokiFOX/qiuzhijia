<template>
	<view class="mainpage-layout">
		<!-- Tab contents -->
		<view class="tab-content-container">
			<view v-if="activated[0]" v-show="currentindex === 0" class="tab-view">
				<Home ref="homeRef" />
			</view>
			<view v-if="activated[1]" v-show="currentindex === 1" class="tab-view">
				<Enterprise ref="enterpriseRef" />
			</view>
			<view v-if="activated[2]" v-show="currentindex === 2" class="tab-view">
				<view class="placeholder-container">
					<text class="placeholder-text">OFFER占位</text>
				</view>
			</view>
			<view v-if="activated[3]" v-show="currentindex === 3" class="tab-view">
				<scroll-view scroll-y :show-scrollbar="false" style="height: 100%; width: 100%;">
					<Service />
				</scroll-view>
			</view>
			<view v-if="activated[4]" v-show="currentindex === 4" class="tab-view">
				<Profile />
			</view>
		</view>

		<!-- Custom Bottom Tab Bar -->
		<view class="bottom-tab-bar">
			<view class="tab-bar-bg" />
			<view class="tab-item" @tap="switchTab(0)">
				<image
					class="tab-icon"
					:src="parseimage(currentindex === 0 ? '底部按钮/首页-选中.png' : '底部按钮/首页-普通.png')"
					mode="aspectFit"
				/>
				<text class="tab-text" :class="{ active: currentindex === 0 }">首页</text>
			</view>
			<view class="tab-item" @tap="switchTab(1)">
				<image
					class="tab-icon"
					:src="parseimage(currentindex === 1 ? '底部按钮/招聘企业-选中.png' : '底部按钮/招聘企业-普通.png')"
					mode="aspectFit"
				/>
				<text class="tab-text" :class="{ active: currentindex === 1 }">招聘企业</text>
			</view>
			<view class="tab-item offer-tab" @tap="onOfferTap">
				<view class="offer-bump" />
				<image
					class="tab-icon offer-icon"
					:src="parseimage(currentindex === 2 ? '底部按钮/offer-选中.png' : '底部按钮/offer-普通.png')"
					mode="aspectFit"
				/>
				<text class="tab-text" :class="{ active: currentindex === 2 }">OFFER</text>
			</view>
			<view class="tab-item" @tap="switchTab(3)">
				<image
					class="tab-icon"
					:src="parseimage(currentindex === 3 ? '底部按钮/服务-选中.png' : '底部按钮/服务-普通.png')"
					mode="aspectFit"
				/>
				<text class="tab-text" :class="{ active: currentindex === 3 }">服务</text>
			</view>
			<view class="tab-item" @tap="switchTab(4)">
				<image
					class="tab-icon"
					:src="parseimage(currentindex === 4 ? '底部按钮/个人中心-选中.png' : '底部按钮/个人中心-普通.png')"
					mode="aspectFit"
				/>
				<text class="tab-text" :class="{ active: currentindex === 4 }">个人中心</text>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import { onReachBottom, onLoad } from "@dcloudio/uni-app";
import Home from "./components/Home.vue";
import Service from "./components/Service.vue";
import Enterprise from "./components/Enterprise.vue";
import Profile from "./components/Profile.vue";
import { parseimage, navigator } from "../../tapah/function";
import { EventManager } from "../../tapah/class";
import { SceneID, EventType } from "../../tapah/enum";

const currentindex = ref(0);
const activated = ref([true, false, false, false, false]);
const homeRef = ref<InstanceType<typeof Home> | null>(null);
const enterpriseRef = ref<InstanceType<typeof Enterprise> | null>(null);

const switchTab = (index: number) => {
	activated.value[index] = true;
	currentindex.value = index;
};

const onOfferTap = () => {
	navigator("/mainpage/example");
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

// Handle infinite scroll on reach bottom
onReachBottom(() => {
	if (currentindex.value === 0) {
		homeRef.value?.loadMore();
	} else if (currentindex.value === 1) {
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

.tab-content-container {
	flex: 1;
	width: 100%;
	padding-bottom: calc(148rpx + env(safe-area-inset-bottom));
	box-sizing: border-box;
	overflow: hidden;
}

.tab-view {
	width: 100%;
	height: 100%;
	overflow-y: auto;
	scrollbar-width: none;
	-ms-overflow-style: none;
}

.tab-view::-webkit-scrollbar {
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
	height: calc(148rpx + env(safe-area-inset-bottom));
	display: flex;
	flex-direction: row;
	align-items: flex-end;
	background-color: transparent;
	padding: 0;
	padding-bottom: env(safe-area-inset-bottom);
	box-sizing: border-box;
	z-index: 999;
}

.tab-bar-bg {
	position: absolute;
	left: 0;
	right: 0;
	bottom: 0;
	height: calc(110rpx + env(safe-area-inset-bottom));
	background-color: #ffffff;
	border-radius: 24rpx 24rpx 0 0;
	z-index: 0;
}

.tab-item {
	flex: 1;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: flex-end;
	padding-bottom: 10rpx;
	height: 110rpx;
	box-sizing: border-box;
	position: relative;
	z-index: 1;
}

.tab-icon {
	width: 48rpx;
	height: 48rpx;
}

.offer-tab {
	justify-content: flex-end;
	height: 148rpx;
	padding-bottom: 10rpx;
}

/* Keep width === height; bump is centered inside the middle tab */
.offer-bump {
	position: absolute;
	left: 50%;
	bottom: 42rpx;
	width: 112rpx;
	height: 108rpx;
	margin-left: -56rpx;
	border-radius: 50%;
	background-color: #ffffff;
	z-index: 0;
}

.offer-icon {
	position: relative;
	z-index: 1;
	width: 96rpx;
	height: 96rpx;
	margin-bottom: 0;
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
