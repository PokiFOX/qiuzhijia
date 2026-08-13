<template>
	<view class="kefu-page">
		<scroll-view class="scroll-container" scroll-y>
			<view class="content-wrapper">
				<!-- Advisor Info Card -->
				<view class="card">
					<view class="advisor-header">
						<image class="avatar" :src="parseimage('客服/头像.png')" mode="aspectFit" />
						<view class="advisor-details">
							<view class="name-row">
								<text class="name">求职家顾问老师</text>
								<image class="badge" :src="parseimage('客服/角标.png')" mode="aspectFit" />
							</view>
							<text class="subtitle">1V1求职咨询顾问</text>
							<view class="tagline-row">
								<image class="tagline-icon" :src="parseimage('客服/图标.png')" mode="aspectFit" />
								<text class="tagline">专注求职辅导·帮你拿到心仪Offer+同学</text>
							</view>
						</view>
					</view>

					<view class="qr-section">
						<image class="qr-code" :src="parseimage('客服/二维码.png')" mode="aspectFit" @tap="previewQr"/>
						<text class="qr-tip-1">长按识别二维码，添加顾问老师</text>
						<text class="qr-tip-2">获取岗位信息、投递建议与专属资料</text>
					</view>

					<image class="card-bottom-img" :src="parseimage('客服/底部.png')" mode="widthFix" />
				</view>

				<!-- Action Buttons -->
				<view class="actions-row">
					<view class="action-btn" @tap="saveQr">
						<image class="action-icon" :src="parseimage('客服/保存.png')" mode="aspectFit" />
						<view class="action-text-col">
							<text class="action-title">保存二维码</text>
							<text class="action-sub">保存到相册，方便查看</text>
						</view>
					</view>

					<view class="action-btn" @tap="copyWechat">
						<image class="action-icon" :src="parseimage('客服/复制.png')" mode="aspectFit" />
						<view class="action-text-col">
							<text class="action-title">复制微信号</text>
							<text class="action-sub">复制后去微信添加</text>
						</view>
					</view>
				</view>
			</view>
		</scroll-view>
	</view>
</template>

<script setup lang="ts">
import { parseimage } from "../../tapah/function";

const previewQr = () => {
	uni.previewImage({
		urls: [parseimage("客服/二维码.png")],
	});
};

const saveQr = () => {
	const qrUrl = parseimage("客服/二维码.png");
	uni.showLoading({
		title: "正在保存...",
	});
	uni.downloadFile({
		url: qrUrl,
		success: (res) => {
			if (res.statusCode === 200) {
				uni.saveImageToPhotosAlbum({
					filePath: res.tempFilePath,
					success: () => {
						uni.hideLoading();
						uni.showToast({
							title: "已保存到相册",
							icon: "success",
						});
					},
					fail: (err) => {
						uni.hideLoading();
						console.error("Save image failed:", err);
						uni.showToast({
							title: "保存失败，请重试",
							icon: "none",
						});
					},
				});
			} else {
				uni.hideLoading();
				uni.showToast({
					title: "下载失败",
					icon: "none",
				});
			}
		},
		fail: (err) => {
			uni.hideLoading();
			console.error("Download file failed:", err);
			uni.showToast({
				title: "下载失败",
				icon: "none",
			});
		},
	});
};

const copyWechat = () => {
	uni.setClipboardData({
		data: "FomaKK",
		success: () => {
			uni.showToast({
				title: "微信号已复制",
				icon: "success",
			});
		},
	});
};
</script>

<style scoped>
.kefu-page {
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

.content-wrapper {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 40rpx 32rpx;
	box-sizing: border-box;
}

/* Advisor Card */
.card {
	display: flex;
	flex-direction: column;
	width: 100%;
	background-color: #ffffff;
	border-radius: 40rpx;
	overflow: hidden;
	box-shadow: 0 4rpx 24rpx rgba(0, 0, 0, 0.04);
	margin-bottom: 40rpx;
}

.advisor-header {
	display: flex;
	flex-direction: row;
	padding: 40rpx 40rpx 0 40rpx;
}

.avatar {
	width: 120rpx;
	height: 120rpx;
	border-radius: 60rpx;
	margin-right: 30rpx;
}

.advisor-details {
	flex: 1;
	display: flex;
	flex-direction: column;
	justify-content: center;
}

.name-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-bottom: 4rpx;
}

.name {
	font-size: 36rpx;
	font-weight: bold;
	color: #3d3d3d;
}

.badge {
	width: 32rpx;
	height: 32rpx;
	margin-left: 16rpx;
}

.subtitle {
	font-size: 24rpx;
	color: #666666;
	margin-bottom: 12rpx;
}

.tagline-row {
	display: flex;
	flex-direction: row;
	align-items: center;
}

.tagline-icon {
	width: 24rpx;
	height: 24rpx;
	margin-right: 8rpx;
}

.tagline {
	font-size: 18rpx;
	color: #2d7bff;
}

.qr-section {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 60rpx 0;
}

.qr-code {
	width: 360rpx;
	height: 360rpx;
	margin-bottom: 30rpx;
}

.qr-tip-1 {
	font-size: 28rpx;
	color: #3d3d3d;
	font-weight: 500;
	margin-bottom: 12rpx;
}

.qr-tip-2 {
	font-size: 24rpx;
	color: #888888;
}

.card-bottom-img {
	width: 100%;
}

/* Action Buttons */
.actions-row {
	display: flex;
	flex-direction: row;
	width: 100%;
	justify-content: space-between;
}

.action-btn {
	display: flex;
	flex-direction: row;
	align-items: center;
	width: 47%;
	background-color: #ffffff;
	border-radius: 24rpx;
	padding: 24rpx 20rpx;
	box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.03);
	box-sizing: border-box;
}

.action-icon {
	width: 48rpx;
	height: 48rpx;
	margin-right: 16rpx;
}

.action-text-col {
	display: flex;
	flex-direction: column;
}

.action-title {
	font-size: 28rpx;
	font-weight: bold;
	color: #3d3d3d;
	margin-bottom: 4rpx;
}

.action-sub {
	font-size: 18rpx;
	color: #888888;
}
</style>
