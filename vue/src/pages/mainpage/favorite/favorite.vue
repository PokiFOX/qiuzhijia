<template>
	<view class="favorite-page">
		<!-- Tab Header -->
		<view class="tab-header">
			<view
				v-for="(tab, index) in tabs"
				:key="index"
				:class="['tab-item', { 'tab-item-active': activeTab === index }]"
				@tap="activeTab = index"
			>
				<text :class="['tab-text', { 'tab-text-active': activeTab === index }]">
					{{ tab }}
				</text>
				<view :class="['tab-line', { 'tab-line-active': activeTab === index }]"></view>
			</view>
		</view>

		<view class="divider-space"></view>

		<!-- Loading State -->
		<view v-if="isLoading" class="loading-state">
			<text class="loading-text">加载中...</text>
		</view>

		<!-- Content Lists -->
		<view v-else class="list-container">
			<!-- Enterprise List -->
			<view v-if="activeTab === 0" class="enterprise-list">
				<view v-if="myenterpriselist.length === 0" class="empty-state">
					<text class="empty-text">暂无关注的企业</text>
				</view>
				<view
					v-else
					class="enterprise-card"
					v-for="(ent, idx) in myenterpriselist"
					:key="idx"
					@tap="onEnterpriseTap(ent.id)"
				>
					<image
						v-if="ent.icon"
						class="enterprise-logo"
						:src="parseimage(`小图标/${ent.icon}.png`)"
						mode="aspectFit"
					/>
					<view v-else class="logo-placeholder"></view>

					<view class="enterprise-info">
						<text class="enterprise-name">{{ ent.name || "" }}</text>
						<text class="enterprise-english" v-if="ent.englishname">{{ ent.englishname }}</text>
						<view class="enterprise-tags" v-if="ent.tags && ent.tags.length > 0">
							<view class="tag-badge" v-for="(tag, tIdx) in ent.tags" :key="tIdx">
								<text class="tag-text">{{ tag }}</text>
							</view>
						</view>
						<text class="enterprise-location">
							{{ ent.zone?.value || "" }} {{ ent.city || "" }}
						</text>
					</view>
				</view>
			</view>

			<!-- Field List -->
			<view v-if="activeTab === 1" class="field-list">
				<view v-if="myfieldlist.length === 0" class="empty-state">
					<text class="empty-text">暂无关注的专业</text>
				</view>
				<view
					v-else
					class="field-card"
					v-for="(field, idx) in myfieldlist"
					:key="idx"
					@tap="onFieldTap(field.id)"
				>
					<text class="field-title">{{ field.value }}</text>
					<text class="field-subtitle">学科门类: {{ field.type }}</text>

					<view class="stars-row">
						<text class="stars-label">专业热门度:</text>
						<FieldStars :star="field.star" />
					</view>

					<view :class="['field-desc', { 'field-desc-collapsed': !expandedFields[field.id] }]">
						<text>{{ field.content }}</text>
					</view>
					<view class="expand-btn-row" v-if="field.content && field.content.length > 100" @tap.stop="toggleFieldExpand(field.id)">
						<text class="expand-btn-text">
							{{ expandedFields[field.id] ? "收起" : "展开" }}
						</text>
					</view>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { myenterpriselist, myfieldlist } from "../../../tapah/data";
import { RequestFavorite } from "../../../tapah/request";
import { parseimage, navigator } from "../../../tapah/function";
import FieldStars from "../../../components/FieldStars.vue";

const tabs = ["招聘企业", "招聘专业"];
const activeTab = ref(0);
const isLoading = ref(true);
const expandedFields = ref<Record<number, boolean>>({});

const toggleFieldExpand = (id: number) => {
	expandedFields.value[id] = !expandedFields.value[id];
};

const onEnterpriseTap = (id: number) => {
	navigator("/pages/enterprise/detail", { enterprise: id });
};

const onFieldTap = (id: number) => {
	navigator("/mainpage/fielddetail", { field: id });
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

onMounted(() => {
	uni.setNavigationBarTitle({
		title: "我的关注",
	});
	loadFavorites();
});
</script>

<style scoped>
.favorite-page {
	display: flex;
	flex-direction: column;
	width: 100vw;
	min-height: 100vh;
	background-color: #f8f8f8;
	box-sizing: border-box;
}

/* Tab Header */
.tab-header {
	background-color: #ffffff;
	border-bottom: 1rpx solid #e2e2e2;
	height: 108rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	padding: 0 12rpx;
	box-sizing: border-box;
}

.tab-item {
	flex: 1;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	height: 100%;
}

.tab-text {
	font-size: 32rpx;
	font-weight: bold;
	color: #444444;
	line-height: 1;
}

.tab-text-active {
	color: #2d7bff;
}

.tab-line {
	height: 4rpx;
	width: 60rpx;
	background-color: transparent;
	margin-top: 12rpx;
	border-radius: 2rpx;
}

.tab-line-active {
	background-color: #2d7bff;
}

.divider-space {
	height: 20rpx;
}

/* List Container */
.list-container {
	display: flex;
	flex-direction: column;
	padding: 0 24rpx 24rpx 24rpx;
	box-sizing: border-box;
}

/* Enterprise List */
.enterprise-list {
	display: flex;
	flex-direction: column;
}

.enterprise-card {
	display: flex;
	flex-direction: row;
	background-color: #ffffff;
	border-radius: 16rpx;
	padding: 20rpx;
	margin-bottom: 20rpx;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
	box-sizing: border-box;
}

.enterprise-logo {
	width: 90rpx;
	height: 90rpx;
	margin-right: 20rpx;
	flex-shrink: 0;
}

.logo-placeholder {
	width: 90rpx;
	height: 90rpx;
	background-color: #e0e0e0;
	border-radius: 8rpx;
	margin-right: 20rpx;
	flex-shrink: 0;
}

.enterprise-info {
	flex: 1;
	display: flex;
	flex-direction: column;
	overflow: hidden;
}

.enterprise-name {
	font-size: 32rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 6rpx;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.enterprise-english {
	font-size: 22rpx;
	color: #888888;
	margin-bottom: 8rpx;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.enterprise-tags {
	display: flex;
	flex-direction: row;
	flex-wrap: wrap;
	margin-bottom: 12rpx;
}

.tag-badge {
	background-color: #feeddf;
	border-radius: 8rpx;
	padding: 2rpx 12rpx;
	margin-right: 10rpx;
	margin-bottom: 6rpx;
}

.tag-text {
	font-size: 20rpx;
	color: #692e1f;
}

.enterprise-location {
	font-size: 20rpx;
	color: #666666;
}

/* Field List */
.field-list {
	display: flex;
	flex-direction: column;
}

.field-card {
	display: flex;
	flex-direction: column;
	background-color: #ffffff;
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

/* States */
.loading-state,
.empty-state {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 100rpx 0;
}

.loading-text,
.empty-text {
	font-size: 28rpx;
	color: #888888;
}
</style>
