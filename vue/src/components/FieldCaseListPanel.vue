<template>
	<view class="panel-root">
		<view class="search-row">
			<view class="search-box">
				<input
					class="search-input"
					type="text"
					v-model="search"
					placeholder="搜索相关企业"
					placeholder-class="search-placeholder"
					confirm-type="search"
				/>
				<image class="search-icon" :src="parseimage('企业列表/搜索.png')" mode="aspectFit" />
			</view>
		</view>

		<view class="cases-wrapper">
			<scroll-view
				class="list-scroll"
				scroll-y
				:show-scrollbar="false"
				:style="listScrollStyle"
				:lower-threshold="80"
				@scrolltolower="loadMore"
			>
				<view class="list-container">
					<view :class="['cases-list', { 'blur-content': !accountinfo }]">
						<view v-if="isInitialLoading" class="state-row">
							<text class="state-text">加载中...</text>
						</view>
						<view v-else-if="filteredCases.length === 0" class="state-row">
							<text class="state-text">暂无成功案例</text>
						</view>
						<template v-else>
							<view v-for="c in filteredCases" :key="c.id" class="case-card-wrap">
								<SimilarCaseCard :case-item="c" />
							</view>
						</template>
						<view v-if="isLoading && !isInitialLoading" class="state-row">
							<text class="state-text">加载中...</text>
						</view>
						<view v-if="isFinish && filteredCases.length > 0 && !search.trim()" class="state-row">
							<text class="state-text">没有更多了</text>
						</view>
					</view>
				</view>
			</scroll-view>

			<view v-if="!accountinfo" class="login-overlay">
				<button open-type="getPhoneNumber" @getphonenumber="onCaseLogin" class="login-btn">
					<text class="login-btn-label">请先登录后查看</text>
				</button>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, watch, type CSSProperties } from "vue";

import { accountinfo } from "../tapah/data";
import { RequestCase, RequestWxCode } from "../tapah/request";
import { parseimage } from "../tapah/function";
import type { Case } from "../tapah/class";
import SimilarCaseCard from "./SimilarCaseCard.vue";

const PAGE_SIZE = 20;

const props = defineProps<{
	fieldId: number;
	active?: boolean;
}>();

const search = ref("");
const page = ref(1);
const allCases = ref<Case[]>([]);
const isInitialLoading = ref(false);
const isLoading = ref(false);
const isFinish = ref(false);

const calcListHeight = () => {
	const { windowHeight } = uni.getSystemInfoSync();
	const panelHeight = windowHeight * 0.75;
	const headerHeight = uni.upx2px(96);
	const searchHeight = uni.upx2px(108);
	return Math.max(120, Math.floor(panelHeight - headerHeight - searchHeight));
};

const listHeightPx = ref(calcListHeight());

const listScrollStyle = computed((): CSSProperties => {
	return { height: `${listHeightPx.value}px` };
});

const updateListHeight = () => {
	listHeightPx.value = calcListHeight();
};

const filteredCases = computed(() => {
	const query = search.value.trim().toLowerCase();
	if (!query) return allCases.value;
	return allCases.value.filter((c) => {
		return (
			(c.entname || "").toLowerCase().includes(query) ||
			(c.name || "").toLowerCase().includes(query) ||
			(c.school1 || "").toLowerCase().includes(query) ||
			(c.school2 || "").toLowerCase().includes(query) ||
			(c.field1 || "").toLowerCase().includes(query) ||
			(c.field2 || "").toLowerCase().includes(query)
		);
	});
});

const onCaseLogin = async (e: any) => {
	const code = e.detail.code;
	if (!code) {
		uni.showToast({ title: "获取手机号失败", icon: "none" });
		return;
	}
	try {
		await RequestWxCode(code);
	} catch (err) {
		console.error("Failed to login:", err);
		uni.showToast({ title: "登录失败", icon: "none" });
	}
};

const loadCases = async () => {
	if (!props.fieldId || isLoading.value) return;
	isLoading.value = true;
	page.value = 1;
	isFinish.value = false;
	allCases.value = [];
	try {
		const list = await RequestCase(0, 0, 0, props.fieldId, 0, 0, 0, page.value);
		allCases.value = list;
		isFinish.value = list.length < PAGE_SIZE;
	} catch (err) {
		console.error("Failed to load field cases:", err);
	} finally {
		isLoading.value = false;
		isInitialLoading.value = false;
		updateListHeight();
	}
};

const loadMore = async () => {
	if (isFinish.value || isLoading.value || isInitialLoading.value || search.value.trim()) return;
	isLoading.value = true;
	const nextPage = page.value + 1;
	try {
		const list = await RequestCase(0, 0, 0, props.fieldId, 0, 0, 0, nextPage);
		if (list.length > 0) {
			allCases.value.push(...list);
			page.value = nextPage;
		}
		isFinish.value = list.length < PAGE_SIZE;
	} catch (err) {
		console.error("Failed to load more field cases:", err);
	} finally {
		isLoading.value = false;
	}
};

const resetAndLoad = () => {
	search.value = "";
	page.value = 1;
	isFinish.value = false;
	isInitialLoading.value = true;
	loadCases();
};

watch(
	() => [props.fieldId, props.active] as const,
	([fieldId, active]) => {
		if (fieldId > 0 && active) {
			updateListHeight();
			resetAndLoad();
		}
	},
	{ immediate: true },
);
</script>

<style scoped>
.panel-root {
	display: flex;
	flex-direction: column;
	flex: 1;
	min-height: 0;
	height: 100%;
}

.search-row {
	flex-shrink: 0;
	padding: 24rpx 48rpx;
	background-color: #ffffff;
	box-sizing: border-box;
}

.search-box {
	display: flex;
	flex-direction: row;
	align-items: center;
	height: 60rpx;
	background-color: #f5f5f5;
	border-radius: 12rpx;
	padding: 0 20rpx;
	box-sizing: border-box;
}

.search-input {
	flex: 1;
	min-width: 0;
	height: 60rpx;
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 350;
	color: #000000;
}

.search-placeholder {
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 350;
	color: #a4a4a4;
}

.search-icon {
	width: 32rpx;
	height: 32rpx;
	flex-shrink: 0;
	margin-left: 8rpx;
}

.cases-wrapper {
	position: relative;
	flex: 1;
	min-height: 0;
	display: flex;
	flex-direction: column;
}

.list-scroll {
	width: 100%;
}

.list-container {
	padding: 24rpx 48rpx 40rpx;
	box-sizing: border-box;
}

.cases-list {
	display: flex;
	flex-direction: column;
}

.case-card-wrap + .case-card-wrap {
	margin-top: 16rpx;
}

.blur-content {
	filter: blur(12px);
	pointer-events: none;
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

.login-overlay {
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	z-index: 10;
}

.login-btn {
	width: 100%;
	height: 100%;
	display: flex;
	align-items: center;
	justify-content: center;
	background-color: rgba(0, 0, 0, 0.05);
	border: none;
	padding: 0;
	margin: 0;
	line-height: normal;
	border-radius: 0;
}

.login-btn::after {
	border: none;
}

.login-btn-label {
	background-color: rgba(0, 0, 0, 0.65);
	color: #ffffff;
	font-size: 32rpx;
	font-weight: 600;
	border-radius: 16rpx;
	padding: 24rpx 48rpx;
	line-height: 1;
}
</style>
