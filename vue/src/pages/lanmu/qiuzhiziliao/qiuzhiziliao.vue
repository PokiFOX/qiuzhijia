<template>
	<view class="lanmu-page">
		<scroll-view class="scroll-container" scroll-y>
			<!-- Top Banner -->
			<image class="top-banner" :src="parseimage('栏目/求职资料/顶部.png')" mode="widthFix" />

			<view class="content-wrapper">
				<!-- Section: 资料类型 -->
				<view class="section-title-row">
					<view class="indicator-bar"></view>
					<text class="section-title">资料类型</text>
				</view>

				<view class="cards-grid">
					<view class="cards-row">
						<view class="type-card">
							<view class="icon-bg" style="background-color: #c8dbfc;">
								<image class="card-icon" :src="parseimage('栏目/求职资料/简历模板.png')" mode="aspectFit" />
							</view>
							<view class="card-text-col">
								<text class="card-title">简历模板</text>
								<text class="card-sub">精选模板&优化技巧</text>
							</view>
						</view>

						<view class="type-card">
							<view class="icon-bg" style="background-color: #ded8fd;">
								<image class="card-icon" :src="parseimage('栏目/求职资料/面试资料.png')" mode="aspectFit" />
							</view>
							<view class="card-text-col">
								<text class="card-title">面试资料</text>
								<text class="card-sub">高频题库&回答思路</text>
							</view>
						</view>
					</view>

					<view class="cards-row">
						<view class="type-card">
							<view class="icon-bg" style="background-color: #fce5d2;">
								<image class="card-icon" :src="parseimage('栏目/求职资料/岗位指南.png')" mode="aspectFit" />
							</view>
							<view class="card-text-col">
								<text class="card-title">岗位指南</text>
								<text class="card-sub">岗位解析&能力要求</text>
							</view>
						</view>

						<view class="type-card">
							<view class="icon-bg" style="background-color: #d4f0e9;">
								<image class="card-icon" :src="parseimage('栏目/求职资料/求职规划.png')" mode="aspectFit" />
							</view>
							<view class="card-text-col">
								<text class="card-title">求职规划</text>
								<text class="card-sub">校招流程&时间安排</text>
							</view>
						</view>
					</view>
				</view>

				<view class="divider-space"></view>

				<!-- Section: 重点内容 -->
				<view class="section-title-row">
					<view class="indicator-bar"></view>
					<text class="section-title">重点内容</text>
				</view>

				<view class="content-cards">
					<view class="content-card">
						<view class="content-icon-bg" style="background-color: #dde9fc;">
							<image class="content-icon" :src="parseimage('栏目/求职资料/应届生简历模板.png')" mode="aspectFit" />
						</view>
						<view class="content-text-col">
							<text class="content-title">应届生简历模板合集</text>
							<text class="content-desc">适合无实习/少项目经历同学，提供多行业简历模板，快速套用提升简历通过率</text>
						</view>
					</view>

					<view class="content-card">
						<view class="content-icon-bg" style="background-color: #fce5d2;">
							<image class="content-icon" :src="parseimage('栏目/求职资料/春招秋招冲刺资料包.png')" mode="aspectFit" />
						</view>
						<view class="content-text-col">
							<text class="content-title">春招秋招冲刺资料包</text>
							<text class="content-desc">涵盖校招流程、时间规划、笔面试技巧，祝你高效备战春招秋招，先人一步拿offer</text>
						</view>
					</view>
				</view>
			</view>

			<!-- Bottom Banner -->
			<view class="bottom-banner-wrapper" @tap="KeFu">
				<image class="bottom-banner-img" :src="parseimage('栏目/求职资料/底部.png')" mode="widthFix" />
			</view>
		</scroll-view>
	</view>
</template>

<script setup lang="ts">
import { parseimage, KeFu } from "../../../tapah/function";
</script>

<style scoped>
.lanmu-page {
	display: flex;
	flex-direction: column;
	width: 100vw;
	height: 100vh;
	background-color: #f8f8f8;
	box-sizing: border-box;
}

.scroll-container {
	flex: 1;
	width: 100%;
}

.top-banner {
	width: 100%;
}

.content-wrapper {
	display: flex;
	flex-direction: column;
	padding: 40rpx 32rpx;
	box-sizing: border-box;
}

.section-title-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-bottom: 24rpx;
}

.indicator-bar {
	width: 8rpx;
	height: 36rpx;
	background-color: #2d7bff;
	border-radius: 4rpx;
	margin-right: 16rpx;
}

.section-title {
	font-size: 32rpx;
	font-weight: bold;
	color: #333333;
}

.cards-grid {
	display: flex;
	flex-direction: column;
	width: 100%;
}

.cards-row {
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	margin-bottom: 24rpx;
}

.type-card {
	display: flex;
	flex-direction: row;
	align-items: center;
	width: 48%;
	background-color: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx 20rpx;
	box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.03);
	box-sizing: border-box;
}

.icon-bg {
	display: flex;
	align-items: center;
	justify-content: center;
	width: 86rpx;
	height: 86rpx;
	border-radius: 24rpx;
	margin-right: 20rpx;
	flex-shrink: 0;
}

.card-icon {
	width: 50rpx;
	height: 50rpx;
}

.card-text-col {
	display: flex;
	flex-direction: column;
	overflow: hidden;
}

.card-title {
	font-size: 28rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 8rpx;
}

.card-sub {
	font-size: 22rpx;
	color: #888888;
	line-height: 1.2;
}

.divider-space {
	height: 48rpx;
}

.content-cards {
	display: flex;
	flex-direction: column;
	width: 100%;
}

.content-card {
	display: flex;
	flex-direction: row;
	background-color: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.03);
	margin-bottom: 24rpx;
	box-sizing: border-box;
}

.content-icon-bg {
	display: flex;
	align-items: center;
	justify-content: center;
	width: 104rpx;
	height: 96rpx;
	border-radius: 24rpx;
	margin-right: 24rpx;
	flex-shrink: 0;
}

.content-icon {
	width: 70rpx;
	height: 70rpx;
}

.content-text-col {
	display: flex;
	flex-direction: column;
	justify-content: center;
}

.content-title {
	font-size: 24rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 12rpx;
}

.content-desc {
	font-size: 20rpx;
	color: #666666;
	line-height: 1.5;
}

.bottom-banner-wrapper {
	display: flex;
	justify-content: center;
	width: 100%;
	padding-bottom: 40rpx;
}

.bottom-banner-img {
	width: 100%;
}
</style>
