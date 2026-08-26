<template>
	<view class="lanmu-page">
		<scroll-view class="scroll-container" scroll-y>
			<!-- Top Banner -->
			<view class="banner-wrapper">
				<image class="banner-img" :src="parseLanmuImage('栏目/求职服务/顶部.png')" mode="widthFix" />
			</view>

			<view class="content-wrapper">
				<!-- Section: 核心服务 -->
				<view class="section-title-row">
					<view class="indicator-bar"></view>
					<text class="section-title">核心服务</text>
				</view>

				<view class="cards-grid">
					<view class="cards-row">
						<view class="type-card">
							<image class="card-icon" :src="parseLanmuImage('栏目/求职服务/求职定位.png')" mode="aspectFit" />
							<view class="card-text-col">
								<text class="card-title">求职定位</text>
								<text class="card-sub">结合背景匹配方向</text>
							</view>
						</view>

						<view class="type-card">
							<image class="card-icon" :src="parseLanmuImage('栏目/求职服务/简历优化.png')" mode="aspectFit" />
							<view class="card-text-col">
								<text class="card-title">简历优化</text>
								<text class="card-sub">突出经历与岗位优势</text>
							</view>
						</view>
					</view>

					<view class="cards-row">
						<view class="type-card">
							<image class="card-icon" :src="parseLanmuImage('栏目/求职服务/投递规划.png')" mode="aspectFit" />
							<view class="card-text-col">
								<text class="card-title">投递规划</text>
								<text class="card-sub">筛选岗位与企业机会</text>
							</view>
						</view>

						<view class="type-card">
							<image class="card-icon" :src="parseLanmuImage('栏目/求职服务/笔面辅导.png')" mode="aspectFit" />
							<view class="card-text-col">
								<text class="card-title">笔面辅导</text>
								<text class="card-sub">提升笔试与面试表现</text>
							</view>
						</view>
					</view>

					<view class="cards-row">
						<view class="type-card">
							<image class="card-icon" :src="parseLanmuImage('栏目/求职服务/首席导师团队.png')" mode="aspectFit" />
							<view class="card-text-col">
								<text class="card-title">首席导师团队</text>
								<text class="card-sub">顶尖行业导师</text>
							</view>
						</view>

						<view class="type-card">
							<image class="card-icon" :src="parseLanmuImage('栏目/求职服务/实习内推.png')" mode="aspectFit" />
							<view class="card-text-col">
								<text class="card-title">实习内推</text>
								<text class="card-sub">定向内推实习</text>
							</view>
						</view>
					</view>

					<view class="cards-row">
						<view class="type-card">
							<image class="card-icon" :src="parseLanmuImage('栏目/求职服务/24h贴心陪伴.png')" mode="aspectFit" />
							<view class="card-text-col">
								<text class="card-title">24h贴心陪伴</text>
								<text class="card-sub">专属辅导组</text>
							</view>
						</view>

						<view class="type-card">
							<image class="card-icon" :src="parseLanmuImage('栏目/求职服务/能力提升工作坊.png')" mode="aspectFit" />
							<view class="card-text-col">
								<text class="card-title">能力提升工作坊</text>
								<text class="card-sub">助力能力提升</text>
							</view>
						</view>
					</view>

					<view class="cards-row">
						<view class="type-card">
							<image class="card-icon" :src="parseLanmuImage('栏目/求职服务/其他增值服务.png')" mode="aspectFit" />
							<view class="card-text-col">
								<text class="card-title">其他增值服务</text>
								<text class="card-sub">行业资料持续更新</text>
							</view>
						</view>

						<view class="type-card">
							<image class="card-icon" :src="parseLanmuImage('栏目/求职服务/专属社群支持.png')" mode="aspectFit" />
							<view class="card-text-col">
								<text class="card-title">专属社群支持</text>
								<text class="card-sub">消息及时同步</text>
							</view>
						</view>
					</view>
				</view>

				<view class="divider-space"></view>

				<!-- Flow Card -->
				<view class="flow-card">
					<view class="section-title-row">
						<view class="indicator-bar"></view>
						<text class="section-title">服务流程</text>
					</view>

					<view class="divider-space-small"></view>

					<view class="flow-steps">
						<view class="flow-step">
							<view class="flow-icon-bg">
								<image class="flow-icon" :src="parseLanmuImage('栏目/求职服务/需求沟通.png')" mode="aspectFit" />
							</view>
							<text class="flow-label">需求沟通</text>
						</view>
						<text class="flow-arrow">&gt;</text>

						<view class="flow-step">
							<view class="flow-icon-bg">
								<image class="flow-icon" :src="parseLanmuImage('栏目/求职服务/策略制定.png')" mode="aspectFit" />
							</view>
							<text class="flow-label">策略制定</text>
						</view>
						<text class="flow-arrow">&gt;</text>

						<view class="flow-step">
							<view class="flow-icon-bg">
								<image class="flow-icon" :src="parseLanmuImage('栏目/求职服务/技能提升.png')" mode="aspectFit" />
							</view>
							<text class="flow-label">技能提升</text>
						</view>
						<text class="flow-arrow">&gt;</text>

						<view class="flow-step">
							<view class="flow-icon-bg">
								<image class="flow-icon" :src="parseLanmuImage('栏目/求职服务/信息推荐.png')" mode="aspectFit" />
							</view>
							<text class="flow-label">信息推荐</text>
						</view>
						<text class="flow-arrow">&gt;</text>

						<view class="flow-step">
							<view class="flow-icon-bg">
								<image class="flow-icon" :src="parseLanmuImage('栏目/求职服务/面试上岸.png')" mode="aspectFit" />
							</view>
							<text class="flow-label">面试上岸</text>
						</view>
					</view>
				</view>
			</view>

			<view class="divider-space"></view>

			<!-- Bottom Consult Banner -->
			<view class="bottom-banner-wrapper" @tap="KeFu">
				<image class="bottom-banner-img" :src="parseLanmuImage('栏目/求职服务/底部.png')" mode="widthFix" />
			</view>

			<view class="divider-space-small"></view>

			<!-- Footer Badge -->
			<view class="footer-badge">
				<image class="badge-icon" :src="parseLanmuImage('栏目/笔试题库/标记.png')" mode="aspectFit" />
				<text class="badge-text">已为数千名学员提供专业咨询服务</text>
			</view>

			<view class="divider-space"></view>
		</scroll-view>
	</view>
</template>

<script setup lang="ts">
import { parseLanmuImage, KeFu } from "../../../tapah/function";
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

.banner-wrapper {
	width: 100%;
	padding: 0 32rpx;
	box-sizing: border-box;
	border-radius: 24rpx;
	overflow: hidden;
	margin-top: 24rpx;
}

.banner-img {
	width: 100%;
	border-radius: 24rpx;
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

.card-icon {
	width: 80rpx;
	height: 80rpx;
	margin-right: 16rpx;
	flex-shrink: 0;
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

.divider-space {
	height: 48rpx;
}

.divider-space-small {
	height: 24rpx;
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
	font-size: 20rpx;
	color: #555555;
}

.flow-arrow {
	font-size: 28rpx;
	color: #cccccc;
	margin-bottom: 36rpx;
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
