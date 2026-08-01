<template>
	<view class="lanmu-page">
		<scroll-view class="scroll-container" scroll-y>
			<!-- Top Banner -->
			<image class="top-banner" :src="parseimage('栏目/岗位内推/顶部.png')" mode="widthFix" />

			<view class="content-wrapper">
				<!-- Section: 服务内容 -->
				<view class="section-title-row">
					<view class="indicator-bar"></view>
					<text class="section-title">服务内容</text>
				</view>

				<view class="cards-grid">
					<view class="cards-row">
						<view class="type-card">
							<view class="icon-bg" style="background-color: #c8dbfc;">
								<image class="card-icon" :src="parseimage('栏目/岗位内推/校招岗位.png')" mode="aspectFit" />
							</view>
							<view class="card-text-col">
								<text class="card-title">校招岗位</text>
								<text class="card-sub">应届/秋招/春招</text>
							</view>
						</view>

						<view class="type-card">
							<view class="icon-bg" style="background-color: #ded8fd;">
								<image class="card-icon" :src="parseimage('栏目/岗位内推/社招岗位.png')" mode="aspectFit" />
							</view>
							<view class="card-text-col">
								<text class="card-title">社招岗位</text>
								<text class="card-sub">社会招聘/转岗方向</text>
							</view>
						</view>
					</view>

					<view class="cards-row">
						<view class="type-card">
							<view class="icon-bg" style="background-color: #fce5d2;">
								<image class="card-icon" :src="parseimage('栏目/岗位内推/管培项目.png')" mode="aspectFit" />
							</view>
							<view class="card-text-col">
								<text class="card-title">管培项目</text>
								<text class="card-sub">管培生/储备干部方向</text>
							</view>
						</view>

						<view class="type-card">
							<view class="icon-bg" style="background-color: #d4f0e9;">
								<image class="card-icon" :src="parseimage('栏目/岗位内推/定向推荐.png')" mode="aspectFit" />
							</view>
							<view class="card-text-col">
								<text class="card-title">定向推荐</text>
								<text class="card-sub">结合背景精准匹配</text>
							</view>
						</view>
					</view>
				</view>

				<view class="divider-space"></view>

				<!-- Section: 推荐优势 -->
				<view class="section-title-row">
					<view class="indicator-bar"></view>
					<text class="section-title">推荐优势</text>
				</view>

				<view class="content-cards">
					<view class="content-card">
						<image class="content-img" :src="parseimage('栏目/岗位内推/精准岗位筛选.png')" mode="aspectFit" />
						<view class="content-text-col">
							<text class="content-title">精准岗位筛选</text>
							<text class="content-bullet">· 结合学历、专业、经历与意向城市匹配岗位</text>
							<text class="content-bullet">· 帮助缩小投递范围，提高投递效率</text>
						</view>
					</view>

					<view class="content-card">
						<image class="content-img" :src="parseimage('栏目/岗位内推/投递支持服务.png')" mode="aspectFit" />
						<view class="content-text-col">
							<text class="content-title">投递支持服务</text>
							<text class="content-bullet">· 简历优化、网申提醒、笔试面试节奏建议</text>
							<text class="content-bullet">· 从岗位推荐到投递跟进形成完整闭环</text>
						</view>
					</view>
				</view>
			</view>

			<!-- Bottom Banner -->
			<view class="bottom-banner-wrapper" @tap="KeFu">
				<image class="bottom-banner-img" :src="parseimage('栏目/岗位内推/底部.png')" mode="widthFix" />
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
	font-size: 24rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 8rpx;
}

.card-sub {
	font-size: 20rpx;
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
	align-items: center;
	background-color: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.03);
	margin-bottom: 24rpx;
	box-sizing: border-box;
}

.content-img {
	width: 120rpx;
	height: 120rpx;
	margin-right: 28rpx;
	flex-shrink: 0;
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
	margin-bottom: 16rpx;
}

.content-bullet {
	font-size: 20rpx;
	color: #555555;
	line-height: 1.5;
	margin-bottom: 8rpx;
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
