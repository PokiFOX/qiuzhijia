<template>
	<view class="field-page">
		<!-- Search and Filter Row -->
		<view class="search-filter-row">
			<view class="filter-btn" @tap="goFieldList">
				<text class="filter-btn-text">专业列表</text>
				<text class="arrow-down">▼</text>
			</view>

			<view class="search-input-col">
				<icon type="search" size="16" color="#2d7bff" class="search-icon" />
				<input
					class="search-input"
					type="text"
					v-model="searchText"
					placeholder="搜索你的专业"
					confirm-type="search"
					@input="onSearchInput"
				/>
			</view>
		</view>

		<view class="divider-space"></view>

		<!-- Fields List -->
		<view class="list-container">
			<view
				class="field-card"
				v-for="(field, idx) in displayList"
				:key="idx"
				@tap="onFieldTap(field.id)"
			>
				<text class="field-title">{{ field.value }}</text>
				<text class="field-subtitle">学科门类: {{ field.type }}</text>

				<view class="stars-row">
					<text class="stars-label">专业热门度:</text>
					<text class="star-icon" v-for="n in field.star" :key="n">★</text>
				</view>

				<!-- Expandable Text -->
				<view :class="['field-desc', { 'field-desc-collapsed': !expandedFields[field.id] }]">
					<text>{{ field.content }}</text>
				</view>
				<view class="expand-btn-row" @tap.stop="toggleExpand(field.id)">
					<text class="expand-btn-text">
						{{ expandedFields[field.id] ? "收起" : "展开" }}
					</text>
				</view>
			</view>

			<!-- Empty State -->
			<view v-if="displayList.length === 0" class="empty-state">
				<text class="empty-text">暂无对口专业数据</text>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from "vue";
import { onLoad } from "@dcloudio/uni-app";
import { fieldlist } from "../../../tapah/data";
import { navigator } from "../../../tapah/function";
import type { Field } from "../../../tapah/class";

const searchText = ref("");
const selectedFieldIds = ref<number[]>([]);
const expandedFields = ref<Record<number, boolean>>({});

const displayList = computed(() => {
	return fieldlist.value.filter((e) => {
		if (e.id === 1) return false; // Skip placeholder/empty field
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

const onSearchInput = () => {
	// Computed property displayList handles filtering reactively
};

const toggleExpand = (id: number) => {
	expandedFields.value[id] = !expandedFields.value[id];
};

const onFieldTap = (id: number) => {
	navigator("/mainpage/fielddetail", { field: id });
};

const goFieldList = () => {
	const fieldsStr = selectedFieldIds.value.join(",");
	navigator("/mainpage/fieldlist", { fields: fieldsStr });
};

// Handle return value from FieldList page
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
			// Auto scroll or highlight can be handled if needed, here we filter by it
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
	min-height: 100vh;
	background-color: #ffffff;
	box-sizing: border-box;
}

/* Search and Filter Row */
.search-filter-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	padding: 20rpx 40rpx 10rpx 40rpx;
	box-sizing: border-box;
}

.filter-btn {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-right: 20rpx;
	flex-shrink: 0;
}

.filter-btn-text {
	font-size: 36rpx;
	font-weight: bold;
	color: #333333;
	margin-right: 4rpx;
}

.arrow-down {
	font-size: 20rpx;
	color: #666666;
}

.search-input-col {
	flex: 1;
	display: flex;
	flex-direction: row;
	align-items: center;
	background-color: #f2f4f8;
	border-radius: 48rpx;
	padding: 0 24rpx;
	height: 80rpx;
	box-sizing: border-box;
}

.search-icon {
	margin-right: 12rpx;
}

.search-input {
	flex: 1;
	font-size: 28rpx;
	color: #333333;
	height: 100%;
}

.divider-space {
	height: 20rpx;
}

/* Fields List */
.list-container {
	display: flex;
	flex-direction: column;
	padding: 0 40rpx 40rpx 40rpx;
	box-sizing: border-box;
}

.field-card {
	display: flex;
	flex-direction: column;
	border: 2rpx solid #2d7bff;
	border-radius: 16rpx;
	padding: 20rpx;
	margin-bottom: 20rpx;
	box-sizing: border-box;
}

.field-title {
	font-size: 30rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 10rpx;
}

.field-subtitle {
	font-size: 22rpx;
	color: #333333;
	margin-bottom: 10rpx;
}

.stars-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-bottom: 10rpx;
}

.stars-label {
	font-size: 22rpx;
	color: #333333;
	margin-right: 10rpx;
}

.star-icon {
	color: #ff9800;
	font-size: 32rpx;
	margin-right: 4rpx;
}

.field-desc {
	font-size: 26rpx;
	color: #666666;
	line-height: 1.4;
}

.field-desc-collapsed {
	display: -webkit-box;
	-webkit-line-clamp: 3;
	-webkit-box-orient: vertical;
	overflow: hidden;
}

.expand-btn-row {
	display: flex;
	justify-content: flex-end;
	margin-top: 10rpx;
}

.expand-btn-text {
	color: #2d7bff;
	font-size: 26rpx;
}

/* Empty State */
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
