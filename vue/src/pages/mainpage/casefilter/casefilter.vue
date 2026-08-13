<template>
	<view class="casefilter-page">
		<view class="main-content">
			<!-- Left Panel: Categories -->
			<scroll-view class="left-panel" scroll-y>
				<view v-for="(cat, index) in categories" :key="index" :class="['category-item', { 'category-item-active': index === selectedCategory }]" @tap="scrollToSection(index)">
					<text :class="['category-text', { 'category-text-active': index === selectedCategory }]">
						{{ cat }}
					</text>
				</view>
			</scroll-view>

			<!-- Right Panel: Options under Category -->
			<scroll-view class="right-panel" scroll-y :scroll-into-view="scrollTargetId" scroll-with-animation @scroll="onRightScroll">
				<view v-for="(cat, index) in categories" :key="index" :id="'section-' + index" class="section-container">
					<text class="section-title">{{ cat }}</text>
					<view class="tags-wrap">
						<view v-for="(opt, oIdx) in options[index]" :key="oIdx" :class="['tag-item', { 'tag-item-selected': selections[index] === oIdx }]" @tap="onOptionTap(index, oIdx)">
							<text :class="['tag-text', { 'tag-text-selected': selections[index] === oIdx }]">
								{{ opt }}
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
import { levellist, sectorlist } from "../../../tapah/data";

const categories = ["本科层次", "硕士层次", "目前状态", "单位层次", "单位类别"];

const selections = ref<number[]>([0, 0, 0, 0, 0]);
const selectedCategory = ref(0);
const scrollTargetId = ref("");
const isProgrammaticScroll = ref(false);
const sectionTops = ref<number[]>([]);

const options = computed(() => {
	return [
		["不限", "C9", "985", "211", "双非", "海外Top10", "海外Top50", "海外Top100", "其他海外院校"],
		["不限", "C9", "985", "211", "双非", "海外Top10", "海外Top50", "海外Top100", "其他海外院校"],
		["不限", "应届生", "已毕业"],
		["不限", ...levellist.value.map((e) => e.value)],
		["不限", ...sectorlist.value.map((e) => e.value)],
	];
});

const onOptionTap = (catIdx: number, oIdx: number) => {
	selections.value[catIdx] = oIdx;
};

const scrollToSection = (index: number) => {
	isProgrammaticScroll.value = true;
	selectedCategory.value = index;
	scrollTargetId.value = "section-" + index;
	setTimeout(() => {
		isProgrammaticScroll.value = false;
	}, 350);
};

const onReset = () => {
	selections.value = [0, 0, 0, 0, 0];
};

const onConfirm = () => {
	uni.$emit("caseFilterSelected", selections.value);
	uni.navigateBack();
};

const calculateSectionTops = () => {
	const query = uni.createSelectorQuery();
	categories.forEach((_, index) => {
		query.select(`#section-${index}`).boundingClientRect();
	});
	query.select(".right-panel").boundingClientRect();
	query.exec((res) => {
		if (!res || res.length === 0) return;
		const rightPanelRect = res[res.length - 1];
		if (!rightPanelRect) return;
		const tops: number[] = [];
		for (let i = 0; i < categories.length; i++) {
			const rect = res[i];
			if (rect) {
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
	selectedCategory.value = activeIndex;
};

onLoad((options) => {
	if (options) {
		selections.value[0] = parseInt(options.stag1, 10) || 0;
		selections.value[1] = parseInt(options.stag2, 10) || 0;
		selections.value[2] = parseInt(options.year, 10) || 0;
		selections.value[3] = parseInt(options.level, 10) || 0;
		selections.value[4] = parseInt(options.sector, 10) || 0;
	}
	nextTick(() => {
		setTimeout(calculateSectionTops, 500);
	});
});
</script>

<style scoped>
.casefilter-page {
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
	border-left-color: #4a90e2;
}

.category-text {
	font-size: 28rpx;
	color: #555555;
	text-align: center;
}

.category-text-active {
	font-weight: bold;
	color: #4a90e2;
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
	background-color: #f0f0f0;
	border-radius: 12rpx;
	padding: 14rpx 24rpx;
	margin-right: 16rpx;
	margin-bottom: 16rpx;
	display: flex;
	align-items: center;
	justify-content: center;
}

.tag-item-selected {
	background-color: #4a90e2;
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
	flex: 2;
	background-color: #ffffff;
	color: #333333;
	border: 1rpx solid #dddddd;
	margin-right: 20rpx;
}

.btn-confirm {
	flex: 5;
	background-color: #4a90e2;
	color: #ffffff;
}
</style>
