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
					@confirm="onSearchSubmit"
				/>
				<image class="search-icon" :src="parseimage('企业列表/搜索.png')" mode="aspectFit" @tap="onSearchSubmit" />
			</view>
		</view>

		<scroll-view
			class="list-scroll"
			scroll-y
			:show-scrollbar="false"
			:style="listScrollStyle"
			:lower-threshold="80"
			@scrolltolower="loadMore"
		>
			<view class="list-container">
				<view v-if="isInitialLoading" class="state-row">
					<text class="state-text">加载中...</text>
				</view>
				<view v-else-if="enterprises.length === 0" class="state-row">
					<text class="state-text">暂无企业数据</text>
				</view>
				<template v-else>
					<view v-for="(ent, idx) in enterprises" :key="ent.id ?? idx" class="enterprise-card-wrap">
						<EnterpriseCard :enterprise="ent" compact @tap="onEnterpriseTap(ent.id)" />
					</view>
				</template>
				<view v-if="isLoading && !isInitialLoading" class="state-row">
					<text class="state-text">加载中...</text>
				</view>
				<view v-if="isFinish && enterprises.length > 0" class="state-row">
					<text class="state-text">没有更多了</text>
				</view>
			</view>
		</scroll-view>
	</view>
</template>

<script setup lang="ts">
import { ref, watch, computed, type CSSProperties } from "vue";

import { RequestEnterprise } from "../tapah/request";
import { parseimage, navigator } from "../tapah/function";
import type { Enterprise } from "../tapah/class";
import EnterpriseCard from "./EnterpriseCard.vue";

const PAGE_SIZE = 20;

const props = defineProps<{
	fieldId: number;
	active?: boolean;
}>();

const search = ref("");
const searchQuery = ref("");
const page = ref(1);
const enterprises = ref<Enterprise[]>([]);
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

const onEnterpriseTap = (id: number) => {
	navigator("/pages/enterprise/detail", { enterprise: id });
};

const onSearchSubmit = () => {
	searchQuery.value = search.value.trim();
	loadEnterprises();
};

const loadEnterprises = async () => {
	if (!props.fieldId || isLoading.value) return;
	isLoading.value = true;
	page.value = 1;
	isFinish.value = false;
	enterprises.value = [];
	try {
		const list = await RequestEnterprise(0, 0, 0, 0, props.fieldId, null, null, searchQuery.value, page.value);
		enterprises.value = list;
		isFinish.value = list.length < PAGE_SIZE;
	} catch (err) {
		console.error("Failed to load field enterprises:", err);
	} finally {
		isLoading.value = false;
		isInitialLoading.value = false;
		updateListHeight();
	}
};

const loadMore = async () => {
	if (isFinish.value || isLoading.value || isInitialLoading.value) return;
	isLoading.value = true;
	const nextPage = page.value + 1;
	try {
		const list = await RequestEnterprise(0, 0, 0, 0, props.fieldId, null, null, searchQuery.value, nextPage);
		if (list.length > 0) {
			enterprises.value.push(...list);
			page.value = nextPage;
		}
		isFinish.value = list.length < PAGE_SIZE;
	} catch (err) {
		console.error("Failed to load more field enterprises:", err);
	} finally {
		isLoading.value = false;
	}
};

const resetAndLoad = () => {
	search.value = "";
	searchQuery.value = "";
	page.value = 1;
	isFinish.value = false;
	isInitialLoading.value = true;
	loadEnterprises();
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

.list-scroll {
	width: 100%;
}

.list-container {
	display: flex;
	flex-direction: column;
	padding: 24rpx 48rpx 40rpx;
	box-sizing: border-box;
}

.enterprise-card-wrap + .enterprise-card-wrap {
	margin-top: 16rpx;
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
</style>
