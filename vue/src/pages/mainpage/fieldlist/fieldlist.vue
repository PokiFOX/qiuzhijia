<template>
	<view class="fieldlist-page">
		<view class="main-content">
			<!-- Left Panel: Discipline Categories -->
			<scroll-view class="left-panel" scroll-y>
				<view
					v-for="(type, index) in typeKeys"
					:key="index"
					:class="['category-item', { 'category-item-active': index === activeTypeIndex }]"
					@tap="onCategoryTap(index)"
				>
					<text :class="['category-text', { 'category-text-active': index === activeTypeIndex }]">
						{{ type }}
					</text>
				</view>
			</scroll-view>

			<!-- Right Panel: Fields under Category -->
			<scroll-view
				class="right-panel"
				scroll-y
				:scroll-into-view="scrollTargetId"
				scroll-with-animation
				@scroll="onRightScroll"
			>
				<view
					v-for="(type, index) in typeKeys"
					:key="index"
					:id="'section-' + index"
					class="section-container"
				>
					<text class="section-title">{{ type }}</text>
					<view class="tags-wrap">
						<view
							v-for="field in fieldmap[type]"
							:key="field.id"
							:class="['tag-item', { 'tag-item-selected': selectedIds.has(field.id) }]"
							@tap="toggleSelect(field.id)"
						>
							<text :class="['tag-text', { 'tag-text-selected': selectedIds.has(field.id) }]">
								{{ field.value }}
							</text>
						</view>
					</view>
				</view>
			</scroll-view>
		</view>

		<!-- Bottom Action Bar -->
		<view class="bottom-bar">
			<button class="action-btn btn-reset" @tap="onReset">重置</button>
			<button class="action-btn btn-confirm" @tap="onConfirm">确定</button>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick } from "vue";
import { onLoad } from "@dcloudio/uni-app";
import { fieldlist } from "../../../tapah/data";
import type { Field } from "../../../tapah/class";

const fieldmap = ref<Record<string, Field[]>>({});
const typeKeys = ref<string[]>([]);
const selectedIds = ref<Set<number>>(new Set());
const activeTypeIndex = ref(0);
const scrollTargetId = ref("");
const isProgrammaticScroll = ref(false);
const sectionTops = ref<number[]>([]);

const initFieldMap = () => {
	const map: Record<string, Field[]> = {};
	fieldlist.value.forEach((field) => {
		if (field.id === 1) return; // Skip placeholder
		if (!map[field.type]) {
			map[field.type] = [];
		}
		map[field.type].push(field);
	});
	fieldmap.value = map;
	typeKeys.value = Object.keys(map);
};

const onCategoryTap = (index: number) => {
	isProgrammaticScroll.value = true;
	activeTypeIndex.value = index;
	scrollTargetId.value = "section-" + index;
	// Reset programmatic scroll lock after animation completes
	setTimeout(() => {
		isProgrammaticScroll.value = false;
	}, 350);
};

const toggleSelect = (id: number) => {
	if (selectedIds.value.has(id)) {
		selectedIds.value.delete(id);
	} else {
		selectedIds.value.add(id);
	}
};

const onReset = () => {
	selectedIds.value.clear();
};

const onConfirm = () => {
	const selectedFields = fieldlist.value.filter((f) => selectedIds.value.has(f.id));
	uni.$emit("fieldListSelected", selectedFields);
	uni.navigateBack();
};

const calculateSectionTops = () => {
	const query = uni.createSelectorQuery();
	typeKeys.value.forEach((_, index) => {
		query.select(`#section-${index}`).boundingClientRect();
	});
	query.select(".right-panel").boundingClientRect();
	query.exec((res) => {
		if (!res || res.length === 0) return;
		const rightPanelRect = res[res.length - 1];
		if (!rightPanelRect) return;
		const tops: number[] = [];
		for (let i = 0; i < typeKeys.value.length; i++) {
			const rect = res[i];
			if (rect) {
				// Section top relative to scroll view content
				tops.push(rect.top - rightPanelRect.top);
			} else {
				tops.push(0);
			}
		}
		sectionTops.value = tops;
	});
};

const onRightScroll = (e: any) => {
	if (isProgrammaticScroll.value || sectionTops.value.length === 0) return;
	const scrollTop = e.detail.scrollTop;
	let activeIndex = 0;
	for (let i = 0; i < sectionTops.value.length; i++) {
		if (scrollTop >= sectionTops.value[i] - 10) {
			activeIndex = i;
		}
	}
	activeTypeIndex.value = activeIndex;
};

onLoad((options) => {
	initFieldMap();
	if (options && options.fields) {
		const ids = options.fields.split(",");
		ids.forEach((id: string) => {
			const numId = parseInt(id, 10);
			if (!isNaN(numId)) {
				selectedIds.value.add(numId);
			}
		});
	}
	nextTick(() => {
		setTimeout(calculateSectionTops, 500);
	});
});
</script>

<style scoped>
.fieldlist-page {
	display: flex;
	flex-direction: column;
	width: 100vw;
	height: 100vh;
	background-color: #ffffff;
	box-sizing: border-box;
}

.main-content {
	flex: 1;
	display: flex;
	flex-direction: row;
	overflow: hidden;
	width: 100%;
}

/* Left Panel */
.left-panel {
	width: 180rpx;
	height: 100%;
	background-color: #f5f5f5;
	flex-shrink: 0;
}

.category-item {
	width: 100%;
	padding: 30rpx 20rpx;
	box-sizing: border-box;
	display: flex;
	align-items: center;
	justify-content: center;
	background-color: #f5f5f5;
	border-left: 6rpx solid transparent;
}

.category-item-active {
	background-color: #ffffff;
	border-left-color: #2d7bff;
}

.category-text {
	font-size: 28rpx;
	color: #555555;
	text-align: center;
	word-break: break-all;
}

.category-text-active {
	font-weight: bold;
	color: #2d7bff;
}

/* Right Panel */
.right-panel {
	flex: 1;
	height: 100%;
	background-color: #ffffff;
	padding: 24rpx;
	box-sizing: border-box;
}

.section-container {
	margin-bottom: 40rpx;
	display: flex;
	flex-direction: column;
}

.section-title {
	font-size: 30rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 20rpx;
}

.tags-wrap {
	display: flex;
	flex-direction: row;
	flex-wrap: wrap;
}

.tag-item {
	background-color: #f2f4f8;
	border-radius: 32rpx;
	padding: 12rpx 24rpx;
	margin-right: 16rpx;
	margin-bottom: 16rpx;
	display: flex;
	align-items: center;
	justify-content: center;
}

.tag-item-selected {
	background-color: #2d7bff;
}

.tag-text {
	font-size: 26rpx;
	color: #333333;
}

.tag-text-selected {
	color: #ffffff;
}

/* Bottom Action Bar */
.bottom-bar {
	height: 120rpx;
	border-top: 1rpx solid #e8e8e8;
	display: flex;
	flex-direction: row;
	align-items: center;
	padding: 0 30rpx;
	box-sizing: border-box;
	background-color: #ffffff;
}

.action-btn {
	height: 80rpx;
	border-radius: 40rpx;
	font-size: 32rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	line-height: 1;
}

.action-btn::after {
	border: none;
}

.btn-reset {
	flex: 1;
	background-color: #ffffff;
	color: #333333;
	border: 1rpx solid #dddddd;
	margin-right: 20rpx;
}

.btn-confirm {
	flex: 2;
	background-color: #2d7bff;
	color: #ffffff;
}
</style>
