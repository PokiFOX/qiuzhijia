<template>
	<view class="favorite-page">
		<view class="page-nav" :style="navBarStyle">
			<view class="nav-side nav-side-left">
				<view class="nav-back" :style="navSideStyle" @tap="onBack">
					<text class="nav-back-icon">‹</text>
				</view>
			</view>
			<text class="nav-title" :style="navTitleStyle">{{ pageTitle }}</text>
			<view class="nav-side nav-side-right"></view>
		</view>

		<view v-if="!isManageMode" class="toolbar-row">
			<view class="search-box">
				<input
					class="search-input"
					type="text"
					v-model="searchKeyword"
					:placeholder="searchPlaceholder"
					placeholder-class="search-placeholder"
					confirm-type="search"
				/>
				<image class="search-icon" :src="parseimage('企业列表/搜索.png')" mode="aspectFit" />
			</view>
			<button class="manage-btn" @tap="enterManageMode">管理</button>
		</view>

		<view v-else class="toolbar-row manage-toolbar">
			<text class="manage-action" @tap="onSelectAll">全选</text>
			<text class="manage-count">已选择{{ selectedIds.length }}个{{ unitLabel }}</text>
			<text class="manage-action" @tap="exitManageMode">取消</text>
		</view>

		<scroll-view
			class="list-scroll"
			scroll-y
			enhanced
			:show-scrollbar="false"
			:class="{ 'list-scroll-with-bottom': isManageMode }"
		>
			<view v-if="isLoading" class="state-box">
				<text class="state-text">加载中...</text>
			</view>

			<view v-else-if="filteredEnterprises.length === 0 && isEnterpriseTab" class="state-box">
				<text class="state-text">暂无收藏的企业</text>
			</view>

			<view v-else-if="filteredFields.length === 0 && !isEnterpriseTab" class="state-box">
				<text class="state-text">暂无收藏的专业</text>
			</view>

			<view v-else class="list-container">
				<template v-if="isEnterpriseTab">
					<view
						v-for="ent in filteredEnterprises"
						:key="ent.id"
						class="card-wrap"
						@tap="onCardTap(ent.id)"
						@touchstart="onCardTouchStart(ent.id)"
						@touchmove="onCardTouchEnd"
						@touchend="onCardTouchEnd"
						@touchcancel="onCardTouchEnd"
					>
						<EnterpriseCard
							:enterprise="ent"
							:selected="isSelected(ent.id)"
						/>
					</view>
				</template>
				<template v-else>
					<view
						v-for="field in filteredFields"
						:key="field.id"
						class="card-wrap"
						@tap="onCardTap(field.id)"
						@touchstart="onCardTouchStart(field.id)"
						@touchmove="onCardTouchEnd"
						@touchend="onCardTouchEnd"
						@touchcancel="onCardTouchEnd"
					>
						<FieldCard
							:field="field"
							:selected="isSelected(field.id)"
						/>
					</view>
				</template>
			</view>
		</scroll-view>

		<view v-if="isManageMode" class="bottom-bar">
			<button class="unfavorite-btn" @tap="onUnfavorite">取消收藏</button>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { onLoad } from "@dcloudio/uni-app";

import { accountinfo, myenterpriselist, myfieldlist } from "../../../tapah/data";
import { RequestFavorite, RequestUserInfo } from "../../../tapah/request";
import { parseimage, navigator, getWechatNavMetrics } from "../../../tapah/function";
import EnterpriseCard from "../../../components/EnterpriseCard.vue";
import FieldCard from "../../../components/FieldCard.vue";

const activeTab = ref(0);
const isLoading = ref(true);
const searchKeyword = ref("");
const isManageMode = ref(false);
const selectedIds = ref<number[]>([]);
const longPressTriggered = ref(false);
let longPressTimer: ReturnType<typeof setTimeout> | null = null;

const selectedIdSet = computed(() => new Set(selectedIds.value));

const isSelected = (id: number) => selectedIdSet.value.has(id);

const metrics = computed(() => getWechatNavMetrics());

const isEnterpriseTab = computed(() => activeTab.value === 0);

const pageTitle = computed(() => (isEnterpriseTab.value ? "收藏企业" : "收藏专业"));

const searchPlaceholder = computed(() =>
	isEnterpriseTab.value ? "搜索收藏企业" : "搜索收藏专业",
);

const unitLabel = computed(() => (isEnterpriseTab.value ? "企业" : "专业"));

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

const filteredEnterprises = computed(() => {
	const keyword = searchKeyword.value.trim().toLowerCase();
	if (!keyword) return myenterpriselist.value;
	return myenterpriselist.value.filter((ent) => {
		const name = (ent.name || "").toLowerCase();
		const english = (ent.englishname || "").toLowerCase();
		return name.includes(keyword) || english.includes(keyword);
	});
});

const filteredFields = computed(() => {
	const keyword = searchKeyword.value.trim().toLowerCase();
	if (!keyword) return myfieldlist.value;
	return myfieldlist.value.filter((field) => {
		const value = (field.value || "").toLowerCase();
		const type = (field.type || "").toLowerCase();
		return value.includes(keyword) || type.includes(keyword);
	});
});

const currentFilteredIds = computed(() => {
	if (isEnterpriseTab.value) {
		return filteredEnterprises.value.map((ent) => ent.id);
	}
	return filteredFields.value.map((field) => field.id);
});

const onBack = () => {
	uni.navigateBack();
};

const enterManageMode = () => {
	isManageMode.value = true;
	selectedIds.value = [];
};

const exitManageMode = () => {
	isManageMode.value = false;
	selectedIds.value = [];
};

const onSelectAll = () => {
	const ids = currentFilteredIds.value;
	if (ids.length === 0) return;
	const allSelected = ids.every((id) => selectedIdSet.value.has(id));
	if (allSelected) {
		selectedIds.value = [];
		return;
	}
	selectedIds.value = [...ids];
};

const toggleSelected = (id: number) => {
	if (selectedIdSet.value.has(id)) {
		selectedIds.value = selectedIds.value.filter((item) => item !== id);
	} else {
		selectedIds.value = [...selectedIds.value, id];
	}
};

const onCardTap = (id: number) => {
	if (longPressTriggered.value) {
		longPressTriggered.value = false;
		return;
	}
	if (isManageMode.value) {
		toggleSelected(id);
		return;
	}
	if (isEnterpriseTab.value) {
		navigator("/pages/enterprise/detail", { enterprise: id });
	} else {
		navigator("/mainpage/fielddetail", { field: id });
	}
};

const onCardLongPress = (id: number) => {
	longPressTriggered.value = true;
	if (!isManageMode.value) {
		isManageMode.value = true;
		selectedIds.value = [];
	}
	toggleSelected(id);
};

const onCardTouchStart = (id: number) => {
	onCardTouchEnd();
	longPressTimer = setTimeout(() => {
		longPressTimer = null;
		onCardLongPress(id);
	}, 350);
};

const onCardTouchEnd = () => {
	if (longPressTimer) {
		clearTimeout(longPressTimer);
		longPressTimer = null;
	}
};

const onUnfavorite = async () => {
	if (!accountinfo.value) {
		uni.showToast({ title: "请先登录", icon: "none" });
		return;
	}
	if (selectedIds.value.length === 0) {
		uni.showToast({ title: "请先选择", icon: "none" });
		return;
	}

	const targetSet = isEnterpriseTab.value ? accountinfo.value.enterprise : accountinfo.value.field;
	selectedIds.value.forEach((id) => targetSet.delete(id));

	try {
		await RequestUserInfo();
		await loadFavorites();
		exitManageMode();
		uni.showToast({ title: "已取消收藏", icon: "none" });
	} catch (err) {
		console.error("Failed to unfavorite:", err);
		uni.showToast({ title: "操作失败", icon: "none" });
	}
};

const loadFavorites = async () => {
	isLoading.value = true;
	myenterpriselist.value = [];
	myfieldlist.value = [];
	try {
		await RequestFavorite();
	} catch (err) {
		console.error("Failed to load favorites:", err);
	} finally {
		isLoading.value = false;
	}
};

onLoad((options) => {
	if (options?.tab != null) {
		const tab = parseInt(String(options.tab), 10);
		if (tab === 0 || tab === 1) {
			activeTab.value = tab;
		}
	}
});

onMounted(() => {
	loadFavorites();
});
</script>

<style scoped>
.favorite-page {
	display: flex;
	flex-direction: column;
	width: 100vw;
	height: 100vh;
	background-color: rgba(184, 216, 253, 0.5);
	box-sizing: border-box;
	overflow: hidden;
}

.page-nav {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	justify-content: space-between;
	background-color: rgba(184, 216, 253, 0.5);
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

.toolbar-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	height: 88rpx;
	padding: 0 32rpx;
	box-sizing: border-box;
	flex-shrink: 0;
}

.search-box {
	flex: 1;
	min-width: 0;
	display: flex;
	flex-direction: row;
	align-items: center;
	height: 88rpx;
	background-color: #ffffff;
	border-radius: 12rpx;
	padding: 0 24rpx;
	box-sizing: border-box;
}

.search-input {
	flex: 1;
	min-width: 0;
	height: 88rpx;
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

.manage-btn {
	width: 156rpx;
	height: 68rpx;
	margin-left: 20rpx;
	padding: 0;
	border: none;
	background-color: #1269ff;
	border-radius: 12rpx;
	font-size: 32rpx;
	line-height: 68rpx;
	font-weight: 700;
	color: #ffffff;
	flex-shrink: 0;
}

.manage-btn::after {
	border: none;
}

.manage-toolbar {
	justify-content: space-between;
}

.manage-action {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 350;
	color: #1269ff;
	flex-shrink: 0;
}

.manage-count {
	flex: 1;
	text-align: center;
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 400;
	color: #000000;
	padding: 0 16rpx;
	box-sizing: border-box;
}

.list-scroll {
	flex: 1;
	min-height: 0;
	width: 100%;
	margin-top: 32rpx;
	box-sizing: border-box;
}

.list-scroll-with-bottom {
	padding-bottom: 120rpx;
}

.list-container {
	display: flex;
	flex-direction: column;
	padding: 0 32rpx 32rpx;
	box-sizing: border-box;
}

.card-wrap + .card-wrap {
	margin-top: 16rpx;
}

.state-box {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 120rpx 32rpx;
	box-sizing: border-box;
}

.state-text {
	font-size: 28rpx;
	color: #666666;
}

.bottom-bar {
	position: fixed;
	left: 0;
	right: 0;
	bottom: 0;
	height: 120rpx;
	display: flex;
	align-items: center;
	padding: 0 32rpx;
	background-color: rgba(184, 216, 253, 0.5);
	box-sizing: border-box;
	z-index: 10;
}

.unfavorite-btn {
	width: 100%;
	height: 88rpx;
	padding: 0;
	border: none;
	background-color: #1269ff;
	border-radius: 20rpx;
	font-size: 32rpx;
	line-height: 88rpx;
	font-weight: 700;
	color: #ffffff;
}

.unfavorite-btn::after {
	border: none;
}
</style>
