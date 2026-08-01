<template>
	<view class="lanmu-page">
		<scroll-view class="scroll-container" scroll-y>
			<!-- Header Text Section -->
			<view class="header-text-section">
				<text class="main-title">科学刷题，高效备战</text>
				<text class="sub-title-blue">精选真题 · 高频考点 · 分类练习</text>
				<text class="desc-text">帮助你更高效地准备笔试，提升备考方向感与答题效率</text>
			</view>

			<!-- Header Banner -->
			<view class="banner-wrapper">
				<image class="banner-img" :src="parseimage('栏目/笔试题库/顶部.png')" mode="widthFix" />
			</view>

			<view class="divider-space"></view>

			<!-- Section Title -->
			<view class="why-us-header">
				<view class="line"></view>
				<text class="why-us-title">刷题模块</text>
				<view class="line"></view>
			</view>

			<view class="divider-space-small"></view>

			<!-- 2x2 Grid of Cards -->
			<view class="cards-grid">
				<view class="cards-row">
					<view class="type-card">
						<view class="icon-bg">
							<image class="card-icon" :src="parseimage('栏目/笔试题库/真题精选.png')" mode="aspectFit" />
						</view>
						<view class="card-text-col">
							<text class="card-title">真题精选</text>
							<text class="card-sub">贴近真实笔试场景</text>
						</view>
					</view>

					<view class="type-card">
						<view class="icon-bg">
							<image class="card-icon" :src="parseimage('栏目/笔试题库/高频考点.png')" mode="aspectFit" />
						</view>
						<view class="card-text-col">
							<text class="card-title">高频考点</text>
							<text class="card-sub">结合背景制定求职路径</text>
						</view>
					</view>
				</view>

				<view class="cards-row">
					<view class="type-card">
						<view class="icon-bg">
							<image class="card-icon" :src="parseimage('栏目/笔试题库/分类练习.png')" mode="aspectFit" />
						</view>
						<view class="card-text-col">
							<text class="card-title">分类练习</text>
							<text class="card-sub">按题型系统训练</text>
						</view>
					</view>

					<view class="type-card">
						<view class="icon-bg">
							<image class="card-icon" :src="parseimage('栏目/笔试题库/笔试辅导.png')" mode="aspectFit" />
						</view>
						<view class="card-text-col">
							<text class="card-title">笔试辅导</text>
							<text class="card-sub">顾问协助规划方向</text>
						</view>
					</view>
				</view>
			</view>

			<view class="divider-space"></view>

			<!-- Bottom Consult Banner -->
			<view class="consult-banner" @tap="KeFu">
				<view class="consult-btn">
					<image class="wechat-icon" :src="parseimage('栏目/笔试题库/微信.png')" mode="aspectFit" />
					<text class="consult-btn-text">立即咨询</text>
				</view>
				<text class="consult-tip">
					点击按钮，即可添加顾问老师企业微信 1v1获取专属题库推荐与备考建议
				</text>
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
	align-items: center;
	padding: 48rpx 40rpx 32rpx 40rpx;
}

.main-title {
	font-size: 48rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 12rpx;
}

.sub-title-blue {
	font-size: 32rpx;
	font-weight: 600;
	color: #2d7bff;
	margin-bottom: 20rpx;
}

.desc-text {
	font-size: 24rpx;
	color: #666666;
	text-align: center;
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
	height: 56rpx;
}

.divider-space-small {
	height: 32rpx;
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
	width: 80rpx;
	height: 80rpx;
	background-color: #ecf3fd;
	border-radius: 24rpx;
	margin-right: 20rpx;
	flex-shrink: 0;
}

.card-icon {
	width: 48rpx;
	height: 48rpx;
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

.consult-banner {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	width: calc(100% - 64rpx);
	margin: 0 32rpx;
	height: 320rpx;
	background-color: #eff6fa;
	border-radius: 36rpx;
	padding: 0 40rpx;
	box-sizing: border-box;
}

.consult-btn {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	width: 400rpx;
	height: 92rpx;
	background-color: #2d7bff;
	border-radius: 46rpx;
	margin-bottom: 20rpx;
}

.wechat-icon {
	width: 48rpx;
	height: 48rpx;
	margin-right: 20rpx;
}

.consult-btn-text {
	font-size: 36rpx;
	font-weight: bold;
	color: #ffffff;
}

.consult-tip {
	font-size: 24rpx;
	color: #3d3d3d;
	text-align: center;
	line-height: 1.5;
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
