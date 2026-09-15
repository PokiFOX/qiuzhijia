<template>
	<view class="kefu-page">
		<scroll-view class="scroll-container" scroll-y enhanced :show-scrollbar="false">
			<view class="content-wrapper">
				<view class="profile-section">
					<view class="main-card">
						<image
							class="advisor-avatar"
							:src="parseimage('底部按钮/顾问老师.png')"
							mode="widthFix"
						/>
						<text class="advisor-name">求职家顾问老师</text>
						<text class="advisor-role">1V1求职咨询顾问</text>
						<image
							class="service-badge"
							:src="parseimage('底部按钮/专注服务.png')"
							mode="widthFix"
						/>
						<image
							class="qr-code"
							:src="kefuImage('二维码.png')"
							mode="widthFix"
							show-menu-by-longpress
							@tap="previewQr"
						/>
						<text class="qr-tip-main">长按识别二维码，添加顾问老师</text>
						<text class="qr-tip-sub">获取岗位信息、投递建议与专属资料</text>
					</view>
				</view>

				<view class="actions-card">
					<view class="action-item" @tap="saveQr">
						<image class="action-icon" :src="parseimage('底部按钮/保存.png')" mode="aspectFit" />
						<view class="action-text-col">
							<text class="action-title">保存二维码</text>
							<text class="action-sub">保存到相册，方便查看</text>
						</view>
					</view>

					<view class="action-divider" />

					<view class="action-item" @tap="copyWechat">
						<image class="action-icon" :src="parseimage('底部按钮/复制.png')" mode="aspectFit" />
						<view class="action-text-col">
							<text class="action-title">复制微信号</text>
							<text class="action-sub">复制后去微信添加</text>
						</view>
					</view>
				</view>

				<text class="security-tip">信息安全保障·隐私严格保密</text>
			</view>
		</scroll-view>
	</view>
</template>

<script setup lang="ts">
import { parseimage, parseLanmuImage } from "../../tapah/function";

const kefuImage = (name: string) => parseLanmuImage(`客服/${name}`);

const previewQr = () => {
	uni.previewImage({
		urls: [kefuImage("二维码.png")],
	});
};

const saveQr = () => {
	const qrUrl = kefuImage("二维码.png");
	uni.showLoading({ title: "正在保存..." });
	uni.downloadFile({
		url: qrUrl,
		success: (res) => {
			if (res.statusCode === 200) {
				uni.saveImageToPhotosAlbum({
					filePath: res.tempFilePath,
					success: () => {
						uni.hideLoading();
						uni.showToast({ title: "已保存到相册", icon: "success" });
					},
					fail: (err) => {
						uni.hideLoading();
						console.error("Save image failed:", err);
						uni.showToast({ title: "保存失败，请重试", icon: "none" });
					},
				});
			} else {
				uni.hideLoading();
				uni.showToast({ title: "下载失败", icon: "none" });
			}
		},
		fail: (err) => {
			uni.hideLoading();
			console.error("Download file failed:", err);
			uni.showToast({ title: "下载失败", icon: "none" });
		},
	});
};

const copyWechat = () => {
	uni.setClipboardData({
		data: "FomaKK",
		success: () => {
			uni.showToast({ title: "微信号已复制", icon: "success" });
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
	background: linear-gradient(180deg, #e0effc 0%, #fafbff 50%, #b8d8fd 100%);
	box-sizing: border-box;
	overflow: hidden;
}

.scroll-container {
	flex: 1;
	width: 100%;
	min-height: 0;
}

.content-wrapper {
	display: flex;
	flex-direction: column;
	align-items: center;
	padding: 40rpx 30rpx 48rpx;
	box-sizing: border-box;
}

.profile-section {
	width: 100%;
}

.main-card {
	width: 100%;
	margin-top: 60rpx;
	padding: 0 40rpx 40rpx;
	background-color: #ffffff;
	border-radius: 30rpx;
	box-shadow: 0 0 20rpx rgba(5, 22, 84, 0.1);
	box-sizing: border-box;
	display: flex;
	flex-direction: column;
	align-items: center;
	overflow: visible;
}

.advisor-avatar {
	width: 212rpx;
	display: block;
	margin: -60rpx auto 20rpx;
	flex-shrink: 0;
}

.advisor-name {
	font-size: 44rpx;
	line-height: 64rpx;
	font-weight: 700;
	color: #000000;
	text-align: center;
	margin: 0;
	padding: 0;
}

.advisor-role {
	margin-top: 20rpx;
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 300;
	color: #000000;
	text-align: center;
}

.service-badge {
	width: 100%;
	max-width: 520rpx;
	margin-top: 20rpx;
	display: block;
}

.qr-code {
	width: 100%;
	margin-top: 20rpx;
	display: block;
}

.qr-tip-main {
	margin-top: 20rpx;
	font-size: 36rpx;
	line-height: 52rpx;
	font-weight: 500;
	color: #000000;
	text-align: center;
}

.qr-tip-sub {
	margin-top: 20rpx;
	font-size: 26rpx;
	line-height: 38rpx;
	font-weight: 300;
	color: #3d3d3d;
	text-align: center;
}

.actions-card {
	width: 100%;
	margin-top: 30rpx;
	background-color: #ffffff;
	border-radius: 30rpx;
	box-shadow:
		0 4rpx 8rpx rgba(0, 0, 0, 0.02),
		0 2rpx 4rpx rgba(0, 0, 0, 0.03);
	display: flex;
	flex-direction: row;
	align-items: stretch;
	box-sizing: border-box;
	overflow: hidden;
}

.action-item {
	flex: 1;
	display: flex;
	flex-direction: row;
	align-items: center;
	padding: 32rpx 24rpx 32rpx 22rpx;
	box-sizing: border-box;
}

.action-divider {
	width: 1rpx;
	background-color: #edf0f4;
	flex-shrink: 0;
}

.action-icon {
	width: 96rpx;
	height: 96rpx;
	flex-shrink: 0;
	margin-right: 10rpx;
}

.action-text-col {
	display: flex;
	flex-direction: column;
	flex: 1;
	min-width: 0;
}

.action-title {
	font-size: 32rpx;
	line-height: 44rpx;
	font-weight: 500;
	color: #3d3d3d;
	white-space: nowrap;
}

.action-sub {
	font-size: 22rpx;
	line-height: 32rpx;
	font-weight: 300;
	color: #3d3d3d;
	white-space: nowrap;
}

.security-tip {
	margin-top: 30rpx;
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 300;
	color: #3d3d3d;
	text-align: center;
}
</style>
