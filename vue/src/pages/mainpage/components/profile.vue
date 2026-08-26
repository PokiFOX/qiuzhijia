<template>
	<scroll-view class="profile-scroll" scroll-y enhanced :show-scrollbar="false" :style="scrollStyle">
		<view class="profile-page">
			<image class="top-banner" :src="parseimage('底部按钮/个人中心.png')" mode="widthFix" />

			<button
				v-if="!accountinfo"
				class="user-row user-row-login"
				open-type="getPhoneNumber"
				@getphonenumber="onGetPhoneNumber"
			>
				<view class="avatar-placeholder" />
				<view class="user-info-col">
					<text class="nickname-text">未登录</text>
					<text class="id-text">ID: ----</text>
				</view>
			</button>

			<view v-else class="user-row">
				<view class="avatar-wrap">
					<image v-if="avatarSrc" class="avatar-image" :src="avatarSrc" mode="aspectFill" />
					<view v-else class="avatar-placeholder" />
					<button open-type="chooseAvatar" @chooseavatar="onChooseAvatar" class="avatar-choose-btn" />
				</view>

				<view class="user-info-col">
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
			</view>

			<view class="menu-cards">
				<view v-for="item in menuItems" :key="item.key" class="menu-card" @tap="item.onTap">
					<image class="menu-card-icon" :src="parseimage(item.icon)" mode="aspectFit" />
					<text class="menu-card-text">{{ item.label }}</text>
					<image class="menu-card-arrow" :src="parseimage('底部按钮/右箭头.png')" mode="aspectFit" />
				</view>
			</view>

			<view v-if="accountinfo" class="logout-row" @tap="onLogout">
				<image class="logout-icon" :src="parseimage('底部按钮/退出登录.png')" mode="aspectFit" />
				<text class="logout-text">退出登录</text>
			</view>
		</view>
	</scroll-view>
</template>

<script setup lang="ts">
import { ref, watch, computed } from "vue";

import { accountinfo } from "../../../tapah/data";
import { parseimage, navigator, KeFu, openAiInterviewMiniProgram, getWechatNavMetrics } from "../../../tapah/function";
import { RequestWxCode, RequestUserInfo } from "../../../tapah/request";

const nicknameInput = ref("");

const metrics = computed(() => getWechatNavMetrics());

const scrollStyle = computed(() => ({
	paddingTop: `${metrics.value.statusBarHeight}px`,
}));

const avatarSrc = computed(() => accountinfo.value?.avatar?.trim() || "");

watch(
	() => accountinfo.value,
	(newVal) => {
		if (newVal) {
			nicknameInput.value = newVal.nickname || "微信名称";
		} else {
			nicknameInput.value = "";
		}
	},
	{ immediate: true },
);

const menuItems = [
	{
		key: "enterprise",
		label: "收藏企业",
		icon: "底部按钮/收藏企业.png",
		onTap: () => goFavorites(0),
	},
	{
		key: "field",
		label: "收藏专业",
		icon: "底部按钮/收藏专业.png",
		onTap: () => goFavorites(1),
	},
	{
		key: "course",
		label: "求职课程",
		icon: "底部按钮/求职课程.png",
		onTap: () => openAiInterviewMiniProgram(),
	},
	{
		key: "service",
		label: "联系客服",
		icon: "底部按钮/联系客服.png",
		onTap: () => KeFu(),
	},
];

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

const goFavorites = (tab: number) => {
	if (!accountinfo.value) {
		uni.showToast({ title: "请先登录", icon: "none" });
		return;
	}
	navigator("/mainpage/favorite", { tab });
};

const onLogout = () => {
	accountinfo.value = null;
};
</script>

<style scoped>
.profile-scroll {
	width: 100%;
	height: 100%;
	background-color: #f8f8f8;
	box-sizing: border-box;
}

.profile-page {
	display: flex;
	flex-direction: column;
	padding-bottom: 40rpx;
	box-sizing: border-box;
}

.top-banner {
	width: 100%;
	display: block;
}

.user-row,
.user-row-login {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	min-height: 136rpx;
	margin-top: 90rpx;
	padding-left: 90rpx;
	padding-right: 48rpx;
	box-sizing: border-box;
}

.user-row-login {
	width: 100%;
	margin-top: 90rpx;
	margin-left: 0;
	margin-right: 0;
	padding-top: 0;
	padding-bottom: 0;
	border: none;
	background: none;
	line-height: normal;
	text-align: left;
	border-radius: 0;
}

.user-row-login::after {
	border: none;
}

.avatar-placeholder {
	width: 136rpx;
	height: 136rpx;
	border-radius: 50%;
	background-color: #e8e8e8;
	flex-shrink: 0;
}

.avatar-wrap {
	position: relative;
	width: 136rpx;
	height: 136rpx;
	flex-shrink: 0;
}

.avatar-choose-btn {
	position: absolute;
	top: 0;
	left: 0;
	width: 136rpx;
	height: 136rpx;
	padding: 0;
	margin: 0;
	border: none;
	background: transparent;
	line-height: 1;
	border-radius: 50%;
	opacity: 0;
}

.avatar-choose-btn::after {
	border: none;
}

.avatar-image {
	width: 136rpx;
	height: 136rpx;
	border-radius: 50%;
}

.user-info-col {
	flex: 1;
	min-width: 0;
	display: flex;
	flex-direction: column;
	margin-left: 48rpx;
	justify-content: center;
}

.nickname-text,
.nickname-input {
	margin-top: 32rpx;
	font-size: 36rpx;
	line-height: 52rpx;
	font-weight: 500;
	color: #3d3d3d;
	height: 52rpx;
	border: none;
	background: transparent;
	padding: 0;
}

.id-text {
	margin-top: 10rpx;
	font-size: 26rpx;
	line-height: 38rpx;
	font-weight: 300;
	color: #3d3d3d;
}

.menu-cards {
	display: flex;
	flex-direction: column;
	gap: 24rpx;
	margin-top: 60rpx;
	padding: 0 48rpx;
	box-sizing: border-box;
}

.menu-card {
	display: flex;
	flex-direction: row;
	align-items: center;
	height: 132rpx;
	padding: 0 34rpx;
	background-color: #ffffff;
	border-radius: 10rpx;
	box-sizing: border-box;
}

.menu-card-icon {
	width: 64rpx;
	height: 64rpx;
	flex-shrink: 0;
}

.menu-card-text {
	flex: 1;
	min-width: 0;
	margin-left: 44rpx;
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 400;
	color: #3d3d3d;
}

.menu-card-arrow {
	width: 32rpx;
	height: 32rpx;
	flex-shrink: 0;
	margin-left: 8rpx;
}

.logout-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	margin-top: 26rpx;
	padding: 16rpx 0;
}

.logout-icon {
	width: 32rpx;
	height: 32rpx;
	flex-shrink: 0;
}

.logout-text {
	margin-left: 10rpx;
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 300;
	color: #3d3d3d;
}
</style>
