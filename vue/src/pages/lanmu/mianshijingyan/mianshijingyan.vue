<template>
	<view class="lanmu-page">
		<scroll-view class="scroll-container" scroll-y>
			<!-- Header Text Section -->
			<view class="header-text-section">
				<text class="main-title">掌握面试流程，提前准备上岸</text>
				<text class="desc-text">覆盖面试礼仪、常见题型、答题策略与不同轮次面试技巧</text>
			</view>

			<!-- Header Banner -->
			<view class="banner-wrapper">
				<image class="banner-img" :src="parseimage('栏目/面试经验/顶部.png')" mode="widthFix" />
			</view>

			<view class="divider-space"></view>

			<!-- Section Title: 面试备考模块 -->
			<view class="why-us-header">
				<view class="line"></view>
				<text class="why-us-title">面试备考模块</text>
				<view class="line"></view>
			</view>

			<view class="divider-space-small"></view>

			<!-- 2x2 Grid of Cards -->
			<view class="cards-grid">
				<view class="cards-row">
					<view class="type-card">
						<view class="icon-bg">
							<image class="card-icon" :src="parseimage('栏目/面试经验/面试礼仪.png')" mode="aspectFit" />
						</view>
						<view class="card-text-col">
							<text class="card-title">面试礼仪</text>
							<text class="card-sub">着装禁忌与行为规范</text>
						</view>
					</view>

					<view class="type-card">
						<view class="icon-bg">
							<image class="card-icon" :src="parseimage('栏目/面试经验/高频题型.png')" mode="aspectFit" />
						</view>
						<view class="card-text-col">
							<text class="card-title">高频题型</text>
							<text class="card-sub">自我介绍与动机问题</text>
						</view>
					</view>
				</view>

				<view class="cards-row">
					<view class="type-card">
						<view class="icon-bg">
							<image class="card-icon" :src="parseimage('栏目/面试经验/面试形式.png')" mode="aspectFit" />
						</view>
						<view class="card-text-col">
							<text class="card-title">面试形式</text>
							<text class="card-sub">半结构化与无领导小组</text>
						</view>
					</view>

					<view class="type-card">
						<view class="icon-bg">
							<image class="card-icon" :src="parseimage('栏目/面试经验/轮次辅导.png')" mode="aspectFit" />
						</view>
						<view class="card-text-col">
							<text class="card-title">轮次辅导</text>
							<text class="card-sub">HR面试与领导面试</text>
						</view>
					</view>
				</view>
			</view>

			<view class="divider-space"></view>

			<!-- Section Title: 适合哪些需求 -->
			<view class="why-us-header">
				<view class="line"></view>
				<text class="why-us-title">适合哪些需求</text>
				<view class="line"></view>
			</view>

			<view class="divider-space-small"></view>

			<!-- 3-Column Targets Grid -->
			<view class="targets-grid">
				<view class="target-card">
					<image class="target-img" :src="parseimage('栏目/面试经验/面试突击.png')" mode="aspectFit" />
					<text class="target-title">面试前突击</text>
					<text class="target-sub">快速掌握注意事项</text>
				</view>

				<view class="target-card">
					<image class="target-img" :src="parseimage('栏目/面试经验/回答没思路.png')" mode="aspectFit" />
					<text class="target-title">回答没思路</text>
					<text class="target-sub">学习结构化表达</text>
				</view>

				<view class="target-card">
					<image class="target-img" :src="parseimage('栏目/面试经验/多轮面试准备.png')" mode="aspectFit" />
					<text class="target-title">多轮面试准备</text>
					<text class="target-sub">匹配不同面试场景</text>
				</view>
			</view>

			<view class="divider-space"></view>

			<!-- Bottom Consult Banner -->
			<view class="bottom-banner-wrapper" @tap="KeFu">
				<image class="bottom-banner-img" :src="parseimage('栏目/面试经验/底部.png')" mode="widthFix" />
			</view>

			<view class="divider-space-small"></view>

			<!-- Footer Badge -->
			<view class="footer-badge">
				<image class="badge-icon" :src="parseimage('栏目/笔试题库/标记.png')" mode="aspectFit" />
				<text class="badge-text">已为数千名学员提供专业咨询服务</text>
			</view>

			<view class="divider-space"></view>
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

.header-text-section {
	display: flex;
	flex-direction: column;
	padding: 40rpx 40rpx 32rpx 40rpx;
}

.main-title {
	font-size: 40rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 16rpx;
}

.desc-text {
	font-size: 26rpx;
	color: #666666;
	line-height: 1.4;
}

.banner-wrapper {
	width: 100%;
	padding: 0 32rpx;
	box-sizing: border-box;
	border-radius: 24rpx;
	overflow: hidden;
}

.banner-img {
	width: 100%;
	border-radius: 24rpx;
}

.divider-space {
	height: 48rpx;
}

.divider-space-small {
	height: 24rpx;
}

.why-us-header {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	width: 100%;
	padding: 0 32rpx;
	box-sizing: border-box;
}

.line {
	flex: 1;
	height: 1rpx;
	background-color: #dddddd;
}

.why-us-title {
	font-size: 28rpx;
	font-weight: bold;
	color: #333333;
	margin: 0 24rpx;
}

.cards-grid {
	display: flex;
	flex-direction: column;
	width: 100%;
	padding: 0 32rpx;
	box-sizing: border-box;
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
	width: 96rpx;
	height: 96rpx;
	background-color: #ecf3fd;
	border-radius: 24rpx;
	margin-right: 20rpx;
	flex-shrink: 0;
}

.card-icon {
	width: 56rpx;
	height: 56rpx;
}

.card-text-col {
	display: flex;
	flex-direction: column;
	overflow: hidden;
}

.card-title {
	font-size: 26rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 8rpx;
}

.card-sub {
	font-size: 18rpx;
	color: #888888;
	line-height: 1.2;
}

/* Targets Grid */
.targets-grid {
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	width: 100%;
	padding: 0 32rpx;
	box-sizing: border-box;
}

.target-card {
	display: flex;
	flex-direction: column;
	align-items: center;
	width: 31%;
	background-color: #ffffff;
	border-radius: 24rpx;
	padding: 24rpx 16rpx;
	box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.03);
	box-sizing: border-box;
}

.target-img {
	width: 100rpx;
	height: 100rpx;
	margin-bottom: 16rpx;
}

.target-title {
	font-size: 20rpx;
	font-weight: bold;
	color: #333333;
	text-align: center;
	margin-bottom: 8rpx;
}

.target-sub {
	font-size: 18rpx;
	color: #888888;
	text-align: center;
	line-height: 1.2;
}

.bottom-banner-wrapper {
	display: flex;
	justify-content: center;
	width: 100%;
	padding: 0 32rpx;
	box-sizing: border-box;
}

.bottom-banner-img {
	width: 100%;
}

.footer-badge {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	width: 100%;
}

.badge-icon {
	width: 32rpx;
	height: 32rpx;
	margin-right: 12rpx;
}

.badge-text {
	font-size: 24rpx;
	color: #555555;
}
</style>
