<template>
	<view class="lanmu-page">
		<scroll-view class="scroll-container" scroll-y>
			<!-- Top Banner -->
			<image class="top-banner" :src="parseimage('栏目/实习内推/顶部.png')" mode="widthFix" />

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
								<image class="card-icon" :src="parseimage('栏目/实习内推/央国企实习.png')" mode="aspectFit" />
							</view>
							<view class="card-text-col">
								<text class="card-title">央国企实习</text>
								<text class="card-sub">国资平台/央企子公司</text>
							</view>
						</view>

						<view class="type-card">
							<view class="icon-bg" style="background-color: #ded8fd;">
								<image class="card-icon" :src="parseimage('栏目/实习内推/金融机构实习.png')" mode="aspectFit" />
							</view>
							<view class="card-text-col">
								<text class="card-title">金融机构实习</text>
								<text class="card-sub">银行/券商/保险/金科</text>
							</view>
						</view>
					</view>

					<view class="cards-row">
						<view class="type-card">
							<view class="icon-bg" style="background-color: #fce5d2;">
								<image class="card-icon" :src="parseimage('栏目/实习内推/岗位匹配.png')" mode="aspectFit" />
							</view>
							<view class="card-text-col">
								<text class="card-title">岗位匹配</text>
								<text class="card-sub">结合背景推荐合适岗位</text>
							</view>
						</view>

						<view class="type-card">
							<view class="icon-bg" style="background-color: #d4f0e9;">
								<image class="card-icon" :src="parseimage('栏目/实习内推/投递辅导.png')" mode="aspectFit" />
							</view>
							<view class="card-text-col">
								<text class="card-title">投递辅导</text>
								<text class="card-sub">网申/笔试/面试建议</text>
							</view>
						</view>
					</view>
				</view>

				<view class="divider-space"></view>

				<!-- Section: 内推说明 -->
				<view class="section-title-row">
					<view class="indicator-bar"></view>
					<text class="section-title">内推说明</text>
				</view>

				<!-- Target Audience Card -->
				<view class="info-card">
					<image class="info-card-img" :src="parseimage('栏目/实习内推/适合人群.png')" mode="aspectFit" />
					<view class="info-card-text">
						<text class="info-card-title">适合人群</text>
						<text class="info-bullet">· 在校大学生/研一研二学生</text>
						<text class="info-bullet">· 希望进入央国企/金融机构实习的同学</text>
						<text class="info-bullet">· 希望获得高质量内推与专业辅导的同学</text>
					</view>
				</view>

				<view class="divider-space-small"></view>

				<!-- Flow Card -->
				<view class="flow-card">
					<text class="flow-card-title">内推服务流程</text>
					<view class="flow-steps">
						<view class="flow-step">
							<view class="flow-icon-bg">
								<image class="flow-icon" :src="parseimage('栏目/实习内推/流程-咨询评估.png')" mode="aspectFit" />
							</view>
							<text class="flow-label">咨询评估</text>
						</view>
						<text class="flow-arrow">&gt;</text>

						<view class="flow-step">
							<view class="flow-icon-bg">
								<image class="flow-icon" :src="parseimage('栏目/实习内推/流程-岗位匹配.png')" mode="aspectFit" />
							</view>
							<text class="flow-label">岗位匹配</text>
						</view>
						<text class="flow-arrow">&gt;</text>

						<view class="flow-step">
							<view class="flow-icon-bg">
								<image class="flow-icon" :src="parseimage('栏目/实习内推/流程-投递辅导.png')" mode="aspectFit" />
							</view>
							<text class="flow-label">投递辅导</text>
						</view>
						<text class="flow-arrow">&gt;</text>

						<view class="flow-step">
							<view class="flow-icon-bg">
								<image class="flow-icon" :src="parseimage('栏目/实习内推/流程-跟进反馈.png')" mode="aspectFit" />
							</view>
							<text class="flow-label">跟进反馈</text>
						</view>
					</view>
				</view>
			</view>

			<!-- Bottom Banner -->
			<view class="bottom-banner-wrapper" @tap="KeFu">
				<image class="bottom-banner-img" :src="parseimage('栏目/实习内推/底部.png')" mode="widthFix" />
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

.divider-space-small {
	height: 24rpx;
}

/* Info Card */
.info-card {
	display: flex;
	flex-direction: row;
	align-items: center;
	background-color: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.03);
	box-sizing: border-box;
}

.info-card-img {
	width: 120rpx;
	height: 120rpx;
	margin-right: 28rpx;
}

.info-card-text {
	display: flex;
	flex-direction: column;
}

.info-card-title {
	font-size: 24rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 16rpx;
}

.info-bullet {
	font-size: 20rpx;
	color: #555555;
	line-height: 1.8;
}

/* Flow Card */
.flow-card {
	display: flex;
	flex-direction: column;
	background-color: #ffffff;
	border-radius: 24rpx;
	padding: 28rpx;
	box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.03);
	box-sizing: border-box;
}

.flow-card-title {
	font-size: 30rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 28rpx;
}

.flow-steps {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: space-around;
}

.flow-step {
	display: flex;
	flex-direction: column;
	align-items: center;
}

.flow-icon-bg {
	display: flex;
	align-items: center;
	justify-content: center;
	width: 80rpx;
	height: 80rpx;
	background-color: #ffffff;
	border-radius: 52rpx;
	box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.05);
	margin-bottom: 12rpx;
}

.flow-icon {
	width: 40rpx;
	height: 40rpx;
}

.flow-label {
	font-size: 24rpx;
	color: #555555;
}

.flow-arrow {
	font-size: 32rpx;
	color: #cccccc;
	margin-bottom: 36rpx;
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
