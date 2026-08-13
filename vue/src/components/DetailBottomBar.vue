<template>
	<view class="bottom-nav-bar">
		<view class="bottom-nav-inner">
			<view class="nav-item-home" @tap="goHome">
				<image class="nav-icon" :src="parseimage('底部按钮/首页-普通.png')" mode="aspectFit" />
				<text class="nav-item-label">首页</text>
			</view>
			<view class="nav-item-fav">
				<button v-if="!accountinfo" open-type="getPhoneNumber" @getphonenumber="onGetPhoneNumber" class="fav-btn-unlogged">
					<image class="nav-icon" :src="parseimage('底部按钮/收藏-普通.png')" mode="aspectFit" />
					<text class="nav-item-label">{{ favoriteLabel }}</text>
				</button>
				<view v-else class="fav-btn-logged" @tap="emit('toggle-favorite')">
					<image
						class="nav-icon"
						:src="parseimage(isFavorited ? '底部按钮/收藏-选中.png' : '底部按钮/收藏-普通.png')"
						mode="aspectFit"
					/>
					<text class="nav-item-label" :class="{ 'nav-item-label-active': isFavorited }">
						{{ isFavorited ? favoritedLabel : favoriteLabel }}
					</text>
				</view>
			</view>
			<view class="nav-actions-spacer" />
			<view class="nav-btn-consult" @tap="goConsult">
				<text class="nav-btn-consult-text">在线咨询</text>
			</view>
			<view class="nav-btn-phone" @tap="showPhoneModal = true">
				<text class="nav-btn-phone-text">电话咨询</text>
			</view>
		</view>
	</view>

	<view v-if="showPhoneModal" class="modal-mask" @tap="showPhoneModal = false">
		<view class="phone-modal-container" @tap.stop>
			<text class="phone-modal-title">电话咨询</text>
			<view class="phone-modal-row">
				<image class="phone-modal-icon" :src="parseimage('底部按钮/电话.png')" mode="aspectFit" />
				<text class="phone-modal-number">{{ PHONE_NUMBER }}</text>
			</view>
			<view class="phone-modal-buttons">
				<button class="phone-modal-btn phone-btn-cancel" @tap="showPhoneModal = false">取消</button>
				<button class="phone-modal-btn phone-btn-dial" @tap="confirmPhoneCall">拨打</button>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { accountinfo } from "../tapah/data";
import { parseimage, navigator } from "../tapah/function";
import { RequestWxCode } from "../tapah/request";

withDefaults(
	defineProps<{
		isFavorited?: boolean;
		favoriteLabel?: string;
		favoritedLabel?: string;
	}>(),
	{
		isFavorited: false,
		favoriteLabel: "收藏",
		favoritedLabel: "已收藏",
	},
);

const emit = defineEmits<{
	"toggle-favorite": [];
	"logged-in": [];
}>();

const showPhoneModal = ref(false);
const PHONE_NUMBER = "051281660895";

const goHome = () => {
	navigator("/mainpage");
};

const goConsult = () => {
	navigator("/kefu");
};

const confirmPhoneCall = () => {
	showPhoneModal.value = false;
	uni.makePhoneCall({ phoneNumber: PHONE_NUMBER });
};

const onGetPhoneNumber = async (e: any) => {
	const code = e.detail.code;
	if (!code) {
		uni.showToast({ title: "获取手机号失败", icon: "none" });
		return;
	}
	try {
		await RequestWxCode(code);
		emit("logged-in");
	} catch (err) {
		console.error("Failed to login with WeChat code:", err);
		uni.showToast({ title: "登录失败", icon: "none" });
	}
};
</script>

<style scoped>
.bottom-nav-bar {
	position: fixed;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: #ffffff;
	border-radius: 30rpx 30rpx 0 0;
	box-shadow: 0 8rpx 32rpx 0 rgba(0, 0, 0, 0.16);
	box-sizing: border-box;
	z-index: 200;
}

.bottom-nav-inner {
	height: 132rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	padding-left: 64rpx;
	padding-right: 32rpx;
	box-sizing: border-box;
}

.nav-item-home,
.nav-item-fav {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
}

.nav-item-home {
	margin-right: 64rpx;
}

.nav-icon {
	width: 52rpx;
	height: 52rpx;
}

.nav-item-label {
	margin-top: 4rpx;
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 400;
	color: #3d3d3d;
}

.nav-item-label-active {
	color: #4f79fe;
}

.nav-actions-spacer {
	flex: 1;
	min-width: 16rpx;
}

.fav-btn-unlogged {
	background: none;
	border: none;
	padding: 0;
	margin: 0;
	line-height: 1;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.fav-btn-unlogged::after {
	border: none;
}

.fav-btn-logged {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.nav-btn-consult,
.nav-btn-phone {
	width: 200rpx;
	height: 86rpx;
	border-radius: 10rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
}

.nav-btn-consult {
	background-color: #5e80f7;
	margin-right: 36rpx;
}

.nav-btn-consult-text {
	color: #ffffff;
	font-size: 34rpx;
	line-height: 50rpx;
	font-weight: 500;
}

.nav-btn-phone {
	background-color: #f3ad2b;
}

.nav-btn-phone-text {
	color: #ffffff;
	font-size: 34rpx;
	line-height: 50rpx;
	font-weight: 500;
}

.modal-mask {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: rgba(0, 0, 0, 0.5);
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 1000;
}

.phone-modal-container {
	width: 560rpx;
	height: 314rpx;
	background-color: #ffffff;
	box-shadow:
		0 4rpx 8rpx 0 rgba(0, 0, 0, 0.02),
		0 2rpx 4rpx 0 rgba(0, 0, 0, 0.03);
	display: flex;
	flex-direction: column;
	align-items: center;
	box-sizing: border-box;
	padding-top: 32rpx;
}

.phone-modal-title {
	font-size: 44rpx;
	line-height: 64rpx;
	font-weight: 500;
	color: #000000;
}

.phone-modal-row {
	margin-top: 26rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	gap: 16rpx;
}

.phone-modal-icon {
	width: 52rpx;
	height: 52rpx;
	flex-shrink: 0;
}

.phone-modal-number {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 500;
	color: #000000;
}

.phone-modal-buttons {
	margin-top: 38rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	gap: 48rpx;
}

.phone-modal-btn {
	width: 224rpx;
	height: 64rpx;
	border-radius: 10rpx;
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 500;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 0;
	margin: 0;
	box-sizing: border-box;
}

.phone-modal-btn::after {
	border: none;
}

.phone-btn-cancel {
	background-color: #ffffff;
	color: #333333;
	border: 2rpx solid #b2b5bc;
}

.phone-btn-dial {
	background-color: #1269ff;
	color: #ffffff;
	border: none;
}
</style>
