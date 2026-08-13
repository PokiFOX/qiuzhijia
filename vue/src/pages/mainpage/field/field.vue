<template>
	<view class="field-page">
		<view class="page-nav" :style="navBarStyle">
			<view class="nav-side nav-side-left">
				<view class="nav-back" :style="navSideStyle" @tap="onBack">
					<text class="nav-back-icon">‹</text>
				</view>
			</view>
			<text class="nav-title" :style="navTitleStyle">招聘专业</text>
			<view class="nav-side nav-side-right"></view>
		</view>

		<view class="page-body">
			<view class="toolbar-wrap">
				<view class="toolbar-row">
					<view class="filter-btn" @tap="goFieldList">
						<text class="filter-btn-text">专业列表</text>
						<image class="filter-arrow" :src="parseimage('企业列表/下箭头.png')" mode="aspectFit" />
					</view>
					<view class="search-box">
						<input class="search-input" type="text" v-model="searchText" placeholder="搜索你的专业" placeholder-class="search-placeholder" confirm-type="search"/>
						<image class="search-icon" :src="parseimage('企业列表/搜索.png')" mode="aspectFit" />
					</view>
				</view>
			</view>

			<scroll-view class="list-scroll" scroll-y enhanced :show-scrollbar="false">
				<view class="list-container">
					<FieldCard v-for="(field, idx) in displayList" :key="idx" :field="field" @tap="onFieldTap(field.id)"/>

					<view v-if="displayList.length === 0" class="empty-state">
						<text class="empty-text">暂无对口专业数据</text>
					</view>
				</view>
			</scroll-view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from "vue";
import { onLoad } from "@dcloudio/uni-app";

import { fieldlist } from "../../../tapah/data";
import { navigator, parseimage, getWechatNavMetrics } from "../../../tapah/function";
import type { Field } from "../../../tapah/class";
import FieldCard from "../../../components/FieldCard.vue";

const searchText = ref("");
const selectedFieldIds = ref<number[]>([]);

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

const displayList = computed(() => {
	return fieldlist.value.filter((e) => {
		if (e.id === 1) return false;
		if (selectedFieldIds.value.length > 0) {
			if (!selectedFieldIds.value.includes(e.id)) return false;
		}
		if (searchText.value.trim().length === 0) return true;
		const query = searchText.value.trim().toLowerCase();
		return (
			e.value.toLowerCase().includes(query) ||
			e.type.toLowerCase().includes(query) ||
			e.content.toLowerCase().includes(query)
		);
	});
});

const onBack = () => {
	uni.navigateBack();
};

const onFieldTap = (id: number) => {
	navigator("/mainpage/fielddetail", { field: id });
};

const goFieldList = () => {
	const fieldsStr = selectedFieldIds.value.join(",");
	navigator("/mainpage/fieldlist", { fields: fieldsStr });
};

const onFieldListSelected = (fields: Field[]) => {
	selectedFieldIds.value = fields.map((f) => f.id);
};

onMounted(() => {
	uni.$on("fieldListSelected", onFieldListSelected);
});

onUnmounted(() => {
	uni.$off("fieldListSelected", onFieldListSelected);
});

onLoad((options) => {
	if (options && options.field) {
		const targetId = parseInt(options.field, 10);
		if (!isNaN(targetId)) {
			selectedFieldIds.value = [targetId];
		}
	}
});
</script>

<style scoped>
.field-page {
	display: flex;
	flex-direction: column;
	width: 100vw;
	height: 100vh;
	background-color: #ffffff;
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

.page-body {
	flex: 1;
	display: flex;
	flex-direction: column;
	min-height: 0;
	background-color: #f8f8f8;
	box-sizing: border-box;
}

.toolbar-wrap {
	width: 100%;
	height: 88rpx;
	background-color: #ffffff;
	flex-shrink: 0;
	display: flex;
	align-items: center;
	justify-content: center;
	box-sizing: border-box;
}

.toolbar-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	width: 100%;
	height: 88rpx;
	padding: 0 52rpx;
	box-sizing: border-box;
}

.filter-btn {
	display: flex;
	flex-direction: row;
	align-items: center;
	flex-shrink: 0;
	margin-right: 30rpx;
}

.filter-btn-text {
	font-size: 36rpx;
	line-height: 52rpx;
	font-weight: 500;
	color: #000000;
}

.filter-arrow {
	width: 20rpx;
	height: 20rpx;
	margin-left: 4rpx;
	flex-shrink: 0;
}

.search-box {
	flex: 1;
	min-width: 0;
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
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 350;
	color: #000000;
}

.search-placeholder {
	font-size: 28rpx;
	line-height: 40rpx;
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
	flex: 1;
	min-height: 0;
	width: 100%;
	margin-top: 12rpx;
}

.list-container {
	display: flex;
	flex-direction: column;
	padding: 0 20rpx 40rpx;
	box-sizing: border-box;
	gap: 16rpx;
}

.empty-state {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 100rpx 0;
}

.empty-text {
	font-size: 28rpx;
	color: #888888;
}
</style>
