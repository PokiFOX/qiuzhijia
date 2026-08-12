<template>
	<view class="profile-container">
		<view class="page-title-row">
			<text class="page-title">个人中心</text>
		</view>

		<view class="profile-content">
			<!-- User Info Card -->
			<view class="card-row">
				<button
					v-if="!accountinfo"
					open-type="getPhoneNumber"
					@getphonenumber="onGetPhoneNumber"
					class="login-btn-wrapper"
				>
					<view class="user-info-card">
						<view class="avatar-col">
							<image class="avatar-image" :src="parseimage('客服/头像.png')" mode="aspectFill" />
						</view>
						<view class="info-col">
							<text class="nickname-text">未登录</text>
							<text class="sub-text">点击登录微信小程序</text>
						</view>
						<text class="arrow-right">▶</text>
					</view>
				</button>

				<view v-else class="user-info-card">
					<button
						open-type="chooseAvatar"
						@chooseavatar="onChooseAvatar"
						class="avatar-btn-wrapper"
					>
						<image
							class="avatar-image"
							:src="accountinfo.avatar || parseimage('客服/头像.png')"
							mode="aspectFill"
						/>
					</button>
					<view class="info-col">
						<input
							class="nickname-input"
							type="text"
							v-model="nicknameInput"
							@blur="onNicknameBlur"
							confirm-type="done"
							placeholder="请输入昵称"
						/>
						<text class="id-text">ID: {{ accountinfo.id }}</text>
					</view>
					<text class="arrow-right">▶</text>
				</view>
			</view>

			<view class="divider-space"></view>

			<!-- My Favorites Card -->
			<view class="card-row" @tap="goFavorites">
				<view class="menu-item-card">
					<image class="menu-icon" :src="parseimage('客服/关注.png')" mode="aspectFit" />
					<view class="menu-info">
						<text class="menu-title">我的关注</text>
						<text class="menu-desc">查看已关注的公司与专业方向</text>
					</view>
					<text class="arrow-right">▶</text>
				</view>
			</view>

			<view class="divider-space"></view>

			<!-- Contact Customer Service Card -->
			<view class="card-row" @tap="goKefu">
				<view class="menu-item-card small-padding">
					<image class="menu-icon" :src="parseimage('客服/联系客服.png')" mode="aspectFit" />
					<view class="menu-info">
						<text class="menu-title">联系客服</text>
					</view>
					<text class="arrow-right">▶</text>
				</view>
			</view>

			<view class="divider-space-large"></view>

			<!-- Logout Button -->
			<view v-if="accountinfo" class="logout-row" @tap="onLogout">
				<image class="logout-icon" :src="parseimage('客服/退出登录.png')" mode="aspectFit" />
				<text class="logout-text">退出登录</text>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from "vue";
import { accountinfo } from "../../../tapah/data";
import { parseimage, navigator } from "../../../tapah/function";
import { RequestWxCode, RequestUserInfo } from "../../../tapah/request";

const nicknameInput = ref("");

watch(
	() => accountinfo.value,
	(newVal) => {
		if (newVal) {
			nicknameInput.value = newVal.nickname || "微信名称";
		} else {
			nicknameInput.value = "";
		}
	},
	{ immediate: true }
);

const onGetPhoneNumber = async (e: any) => {
	const code = e.detail.code;
	if (code) {
		try {
			await RequestWxCode(code);
		} catch (err) {
			console.error("Failed to login:", err);
			uni.showToast({ title: "登录失败", icon: "none" });
		}
	} else {
		uni.showToast({ title: "获取手机号失败", icon: "none" });
	}
};

const onChooseAvatar = async (e: any) => {
	if (!accountinfo.value) return;
	const avatarUrl = e.detail.avatarUrl;
	if (avatarUrl) {
		accountinfo.value.avatar = avatarUrl;
		try {
			await RequestUserInfo();
		} catch (err) {
			console.error("Failed to update avatar:", err);
		}
	}
};

const onNicknameBlur = async () => {
	if (!accountinfo.value) return;
	let text = nicknameInput.value.trim();
	if (text.length === 0) {
		text = "微信名称";
		nicknameInput.value = text;
	}
	accountinfo.value.nickname = text;
	try {
		await RequestUserInfo();
	} catch (err) {
		console.error("Failed to update nickname:", err);
	}
};

const goFavorites = () => {
	if (!accountinfo.value) {
		uni.showToast({ title: "请先登录", icon: "none" });
		return;
	}
	navigator("/mainpage/favorite");
};

const goKefu = () => {
	navigator("/kefu");
};

const onLogout = () => {
	accountinfo.value = null;
};
</script>

<style scoped>
.profile-container {
	display: flex;
	flex-direction: column;
	width: 100vw;
	min-height: 100vh;
	background-color: #f8f8f8;
	box-sizing: border-box;
}

.page-title-row {
	display: flex;
	align-items: center;
	padding: 20rpx 40rpx;
}

.page-title {
	font-size: 36rpx;
	font-weight: bold;
	color: #333333;
}

.profile-content {
	display: flex;
	flex-direction: column;
	padding: 20rpx 40rpx;
	box-sizing: border-box;
}

.card-row {
	width: 100%;
}

/* User Info Card */
.login-btn-wrapper,
.avatar-btn-wrapper {
	background: none;
	border: none;
	padding: 0;
	margin: 0;
	line-height: 1;
	text-align: left;
	width: 100%;
}

.login-btn-wrapper::after,
.avatar-btn-wrapper::after {
	border: none;
}

.user-info-card {
	display: flex;
	flex-direction: row;
	align-items: center;
	background-color: #ffffff;
	border-radius: 20rpx;
	padding: 30rpx 20rpx;
	box-sizing: border-box;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
	width: 100%;
}

.avatar-col {
	width: 140rpx;
	height: 140rpx;
	border-radius: 70rpx;
	overflow: hidden;
	margin-right: 20rpx;
	flex-shrink: 0;
}

.avatar-image {
	width: 140rpx;
	height: 140rpx;
	border-radius: 70rpx;
}

.info-col {
	flex: 1;
	display: flex;
	flex-direction: column;
	justify-content: center;
}

.nickname-text {
	font-size: 36rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 12rpx;
}

.nickname-input {
	font-size: 36rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 12rpx;
	height: 50rpx;
	border: none;
}

.sub-text {
	font-size: 26rpx;
	color: #888888;
}

.id-text {
	font-size: 26rpx;
	color: #888888;
}

.arrow-right {
	font-size: 24rpx;
	color: #cccccc;
	margin-left: 10rpx;
}

.divider-space {
	height: 30rpx;
}

.divider-space-large {
	height: 60rpx;
}

/* Menu Item Card */
.menu-item-card {
	display: flex;
	flex-direction: row;
	align-items: center;
	background-color: #ffffff;
	border-radius: 20rpx;
	padding: 30rpx 20rpx;
	box-sizing: border-box;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
	width: 100%;
}

.small-padding {
	padding: 20rpx;
}

.menu-icon {
	width: 64rpx;
	height: 64rpx;
	margin-right: 20rpx;
	flex-shrink: 0;
}

.menu-info {
	flex: 1;
	display: flex;
	flex-direction: column;
	justify-content: center;
}

.menu-title {
	font-size: 32rpx;
	font-weight: 500;
	color: #333333;
}

.menu-desc {
	font-size: 24rpx;
	color: #888888;
	margin-top: 8rpx;
}

/* Logout Row */
.logout-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	padding: 20rpx 0;
}

.logout-icon {
	width: 40rpx;
	height: 40rpx;
	margin-right: 12rpx;
}

.logout-text {
	font-size: 32rpx;
	font-weight: 500;
	color: #333333;
}
</style>
