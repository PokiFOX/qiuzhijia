<template>
	<view class="aizhushou-page">
		<view class="page-nav" :style="navBarStyle">
			<view class="nav-side nav-side-left">
				<view class="nav-back" :style="navSideStyle" @tap="onBack">
					<text class="nav-back-icon">‹</text>
				</view>
			</view>
			<text class="nav-title" :style="navTitleStyle">求职家AI助手</text>
			<view class="nav-side nav-side-right"></view>
		</view>

		<view class="page-body">
		<scroll-view
			class="chat-scroll"
			scroll-y
			enhanced
			:show-scrollbar="false"
			:scroll-top="scrollTop"
			@scrolltoupper="onScrollToUpper"
		>
			<view class="chat-container">
				<image
					class="hero-image"
					:src="parseimage('AI助手/智能助手.png')"
					mode="widthFix"
				/>

				<view class="hero-gap" />

				<view
					v-if="showSuggestCard"
					class="questions-card"
				>
					<text class="card-hint">您可以试着问我</text>
					<view class="questions-list">
						<view
							v-for="(q, index) in questions"
							:key="index"
							:class="['question-item', { 'disabled-click': !canInteract }]"
							@tap="canInteract ? onQuestionTap(q) : null"
						>
							<text class="question-text">{{ q }}</text>
						</view>
					</view>
				</view>

				<view class="chat-list">
					<view v-if="historyLoading" class="history-loading">
						<text class="loading-text">加载历史记录中...</text>
					</view>
					<view v-else-if="historyHasMore && chatlist.length > 0" class="history-tip">
						<text class="tip-text">下拉加载更多历史记录</text>
					</view>

					<block v-for="(msg, idx) in chatlist" :key="idx">
						<view class="time-divider" v-if="shouldShowTime(idx)">
							<text class="time-text">{{ formatTime(msg.timestamp) }}</text>
						</view>

						<view :class="['message-row', msg.isuser ? 'row-user' : 'row-ai']">
							<view :class="['bubble-card', msg.isuser ? 'bubble-user' : 'bubble-ai']">
								<text v-if="msg.isuser" class="bubble-text bubble-text-user">{{ msg.detail }}</text>
								<rich-text v-else class="bubble-text-ai" :nodes="renderMarkdown(msg.detail)"></rich-text>
							</view>
						</view>
					</block>

					<view class="message-row row-ai" v-if="sending">
						<view class="bubble-card bubble-ai typing-bubble">
							<text class="typing-text">正在输入(大概需要30秒){{ ".".repeat(typingDotCount) }}</text>
						</view>
					</view>
				</view>
			</view>
		</scroll-view>

		<view class="bottom-area">
			<view class="advisor-container">
				<view class="advisor-row">
					<text class="advisor-text">没解决问题？联系人工顾问为你提供更专业的解答</text>
					<view class="btn-human" @tap="goKefu">
						<text class="btn-human-text">转人工</text>
					</view>
				</view>
			</view>

			<view class="input-row" v-if="accountinfo">
				<image class="plus-icon" :src="parseimage('AI助手/加号.png')" mode="aspectFit" />

				<textarea
					class="message-input"
					v-model="messageText"
					placeholder="请输入你想咨询的问题"
					placeholder-class="input-placeholder"
					:disabled="!canInteract"
					:auto-height="true"
					:maxlength="500"
					:show-confirm-bar="false"
					confirm-type="send"
					@confirm="onSendClick"
				/>

				<view
					:class="['btn-send', { 'btn-send-disabled': !canInteract || messageText.trim().length === 0 }]"
					@tap="canInteract && messageText.trim().length > 0 ? onSendClick() : null"
				>
					<text class="btn-send-text">发送</text>
				</view>
			</view>

			<view class="unlogged-row" v-else>
				<button open-type="getPhoneNumber" @getphonenumber="onGetPhoneNumber" class="login-btn">
					请先登录再提问
				</button>
			</view>

			<text class="ai-disclaimer">内容由AI生成，仅供参考</text>
		</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onUnmounted, nextTick } from "vue";
import { onLoad } from "@dcloudio/uni-app";
import { accountinfo, chataiToken, chataiTokenExpiresAt } from "../../../tapah/data";
import { RequestQuestions, RequestAIChatHistory, RequestChatAIAuth, RequestChatAIChat, RequestWxCode } from "../../../tapah/request";
import { parseimage, navigator, getWechatNavMetrics } from "../../../tapah/function";
import { ChatItem } from "../../../tapah/class";

const agentKeys = ["resume", "joblevel"];

const agentIndex = ref(0);
const questions = ref<string[]>([]);
const chatlist = ref<ChatItem[]>([]);
const messageText = ref("");
const scrollTop = ref(0);

const sending = ref(false);
const inCooldown = ref(false);
const historyLoading = ref(false);
const historyHasMore = ref(true);

const typingDotCount = ref(1);
let typingTimer: ReturnType<typeof setInterval> | null = null;

const metrics = computed(() => getWechatNavMetrics());

const navBarStyle = computed(() => ({
	height: `${metrics.value.navBarHeight}px`,
	paddingTop: `${metrics.value.statusBarHeight}px`,
	paddingLeft: `${metrics.value.paddingHorizontal}px`,
	paddingRight: `${metrics.value.paddingHorizontal}px`,
	boxSizing: "border-box" as const,
}));

const navSideStyle = computed(() => {
	const capsuleTopOffset = metrics.value.capsuleTop - metrics.value.statusBarHeight;
	return {
		height: `${metrics.value.capsuleHeight}px`,
		marginTop: `${capsuleTopOffset}px`,
	};
});

const navTitleStyle = computed(() => {
	const capsuleTopOffset = metrics.value.capsuleTop - metrics.value.statusBarHeight;
	return {
		height: `${metrics.value.capsuleHeight}px`,
		lineHeight: `${metrics.value.capsuleHeight}px`,
		marginTop: `${capsuleTopOffset}px`,
	};
});

const selectedAgent = computed(() => agentKeys[agentIndex.value] || "resume");
const canSend = computed(() => !sending.value && !inCooldown.value);
const canInteract = computed(() => accountinfo.value !== null && canSend.value);
const showSuggestCard = computed(() => questions.value.length > 0 && chatlist.value.length === 0);

const onBack = () => {
	uni.navigateBack();
};

const formatTime = (ts: number) => {
	const dt = new Date(ts * 1000);
	const now = new Date();
	const hour = String(dt.getHours()).padStart(2, "0");
	const minute = String(dt.getMinutes()).padStart(2, "0");
	const time = `${hour}:${minute}`;
	if (dt.getFullYear() === now.getFullYear() && dt.getMonth() === now.getMonth() && dt.getDate() === now.getDate()) {
		return time;
	}
	return `${dt.getMonth() + 1}月${dt.getDate()}日 ${time}`;
};

const shouldShowTime = (idx: number) => {
	if (idx === 0) return true;
	const current = chatlist.value[idx];
	const prev = chatlist.value[idx - 1];
	if (!current || !prev) return false;
	return current.timestamp - prev.timestamp > 300;
};

const renderMarkdown = (text: string) => {
	let html = text
		.replace(/&/g, "&amp;")
		.replace(/</g, "&lt;")
		.replace(/>/g, "&gt;")
		.replace(/\n/g, "<br/>")
		.replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>")
		.replace(/\*(.*?)\*/g, "<em>$1</em>")
		.replace(/`(.*?)`/g, "<code>$1</code>")
		.replace(/### (.*?)(<br\/>|$)/g, "<h3>$1</h3>")
		.replace(/## (.*?)(<br\/>|$)/g, "<h2>$1</h2>")
		.replace(/# (.*?)(<br\/>|$)/g, "<h1>$1</h1>");
	return html;
};

const startTypingAnimation = () => {
	stopTypingAnimation();
	typingDotCount.value = 1;
	typingTimer = setInterval(() => {
		typingDotCount.value = (typingDotCount.value % 3) + 1;
	}, 500);
};

const stopTypingAnimation = () => {
	if (typingTimer) {
		clearInterval(typingTimer);
		typingTimer = null;
	}
	typingDotCount.value = 1;
};

const scrollToBottom = () => {
	nextTick(() => {
		setTimeout(() => {
			scrollTop.value = 99999 + Math.random();
		}, 100);
	});
};

const loadQuestions = async () => {
	try {
		const list = await RequestQuestions(selectedAgent.value);
		questions.value = list;
	} catch (err) {
		console.error("Failed to load questions:", err);
	}
};

const initChat = async () => {
	if (!accountinfo.value) return;
	try {
		const now = Math.floor(Date.now() / 1000);
		if (!chataiToken.value || (chataiTokenExpiresAt.value && now >= chataiTokenExpiresAt.value)) {
			await RequestChatAIAuth();
		}
		const result = await RequestAIChatHistory({ agent: selectedAgent.value });
		chatlist.value = result.messages;
		historyHasMore.value = result.hasMore;
		scrollToBottom();
	} catch (err) {
		console.error("Failed to init chat:", err);
	}
};

const onScrollToUpper = async () => {
	if (historyLoading.value || !historyHasMore.value || chatlist.value.length === 0 || !accountinfo.value) return;
	historyLoading.value = true;
	try {
		const before = chatlist.value[0]?.timestamp || 0;
		const result = await RequestAIChatHistory({
			agent: selectedAgent.value,
			before: before,
		});
		if (result.messages.length === 0) {
			historyHasMore.value = false;
		} else {
			chatlist.value.unshift(...result.messages);
			historyHasMore.value = result.hasMore;
		}
	} catch (err) {
		console.error("Failed to load older history:", err);
	} finally {
		historyLoading.value = false;
	}
};

const sendMessage = async (text: string) => {
	if (text.trim().length === 0 || !canSend.value || !accountinfo.value) return;
	const ts = Math.floor(Date.now() / 1000);
	chatlist.value.push(new ChatItem({ isuser: true, detail: text, timestamp: ts }));
	sending.value = true;
	startTypingAnimation();
	scrollToBottom();

	try {
		if (!chataiToken.value) {
			await RequestChatAIAuth();
		}
		const reply = await RequestChatAIChat(text, selectedAgent.value);
		chatlist.value.push(new ChatItem({ isuser: false, detail: reply, timestamp: ts }));
		sending.value = false;
		inCooldown.value = true;
		stopTypingAnimation();
		scrollToBottom();

		setTimeout(() => {
			inCooldown.value = false;
		}, 10000);
	} catch (err) {
		console.error("Failed to send message:", err);
		sending.value = false;
		stopTypingAnimation();
		uni.showToast({ title: "发送失败", icon: "none" });
	}
};

const onQuestionTap = (q: string) => {
	sendMessage(q);
};

const onSendClick = () => {
	const text = messageText.value.trim();
	if (text.length > 0) {
		sendMessage(text);
		messageText.value = "";
	}
};

const goKefu = () => {
	navigator("/kefu");
};

const onGetPhoneNumber = async (e: { detail: { code?: string } }) => {
	const code = e.detail.code;
	if (code) {
		try {
			await RequestWxCode(code);
			initChat();
		} catch (err) {
			console.error("Failed to login:", err);
			uni.showToast({ title: "登录失败", icon: "none" });
		}
	} else {
		uni.showToast({ title: "获取手机号失败", icon: "none" });
	}
};

onLoad(() => {
	loadQuestions();
	if (accountinfo.value) {
		initChat();
	}
});

onUnmounted(() => {
	stopTypingAnimation();
});
</script>

<style scoped>
.aizhushou-page {
	display: flex;
	flex-direction: column;
	width: 100vw;
	height: 100vh;
	background: linear-gradient(180deg, #e0effc 0%, #fafbff 50%, #b8d8fd 100%);
	box-sizing: border-box;
	overflow: hidden;
}

.page-nav {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	justify-content: space-between;
	width: 100%;
	flex-shrink: 0;
	box-sizing: border-box;
	background: transparent;
}

.nav-side {
	display: flex;
	align-items: center;
	min-width: 64rpx;
}

.nav-side-left {
	justify-content: flex-start;
}

.nav-side-right {
	justify-content: flex-end;
}

.nav-back {
	display: flex;
	align-items: center;
	justify-content: center;
	min-width: 64rpx;
	padding-right: 8rpx;
}

.nav-back-icon {
	font-size: 48rpx;
	line-height: 1;
	color: #000000;
	font-weight: 400;
}

.nav-title {
	flex: 1;
	text-align: center;
	font-size: 32rpx;
	font-weight: 700;
	color: #000000;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.page-body {
	flex: 1;
	display: flex;
	flex-direction: column;
	min-height: 0;
	width: 100%;
}

.chat-scroll {
	flex: 1;
	width: 100%;
	min-height: 0;
	overflow: hidden;
}

.chat-container {
	display: flex;
	flex-direction: column;
	padding-bottom: 24rpx;
	box-sizing: border-box;
}

.hero-image {
	width: 100%;
	display: block;
}

.hero-gap {
	height: 10rpx;
	flex-shrink: 0;
}

.questions-card {
	margin: 0 40rpx 24rpx;
	background-color: #ffffff;
	border-radius: 40rpx;
	box-shadow:
		0 4rpx 8rpx rgba(0, 0, 0, 0.02),
		0 0 6rpx rgba(0, 0, 0, 0.05);
	box-sizing: border-box;
	overflow: hidden;
}

.card-hint {
	display: block;
	padding: 24rpx 0 0 34rpx;
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #1269ff;
}

.questions-list {
	display: flex;
	flex-direction: column;
	gap: 20rpx;
	padding: 20rpx 34rpx 24rpx;
	box-sizing: border-box;
}

.question-item {
	background-color: #ffffff;
	border-radius: 16rpx;
	padding: 16rpx 24rpx;
	box-shadow: 0 0 12rpx -2rpx rgba(0, 0, 0, 0.2);
	box-sizing: border-box;
}

.question-text {
	font-size: 28rpx;
	line-height: 44rpx;
	font-weight: 400;
	color: #3d3d3d;
}

.disabled-click {
	opacity: 0.5;
	pointer-events: none;
}

.chat-list {
	display: flex;
	flex-direction: column;
	padding: 0 40rpx;
	box-sizing: border-box;
}

.history-loading,
.history-tip {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 20rpx 0;
}

.loading-text,
.tip-text {
	font-size: 24rpx;
	color: #b3b3b3;
}

.time-divider {
	display: flex;
	align-items: center;
	justify-content: center;
	margin: 24rpx 0;
}

.time-text {
	font-size: 24rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #b3b3b3;
}

.message-row {
	display: flex;
	flex-direction: row;
	margin-bottom: 24rpx;
	width: 100%;
}

.row-user {
	justify-content: flex-end;
}

.row-ai {
	justify-content: flex-start;
}

.bubble-card {
	max-width: 75%;
	padding: 16rpx 24rpx;
	border-radius: 16rpx;
	box-sizing: border-box;
	word-break: break-all;
}

.bubble-ai {
	background-color: #ffffff;
	color: #000000;
}

.bubble-user {
	background-color: #3774fd;
}

.bubble-text-user {
	font-size: 32rpx;
	line-height: 48rpx;
	font-weight: 400;
	color: #ffffff;
}

.bubble-text-ai {
	font-size: 32rpx;
	line-height: 48rpx;
	color: #000000;
}

.typing-bubble {
	display: flex;
	align-items: center;
}

.typing-text {
	font-size: 28rpx;
	color: #b3b3b3;
}

.bottom-area {
	flex-shrink: 0;
	margin-top: auto;
	background-color: #ffffff;
	display: flex;
	flex-direction: column;
	padding-bottom: env(safe-area-inset-bottom);
	box-sizing: border-box;
}

.advisor-container {
	background-color: #f2f7fd;
	width: 100%;
	flex-shrink: 0;
}

.advisor-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	height: 80rpx;
	padding: 0 20rpx;
	box-sizing: border-box;
}

.advisor-text {
	font-size: 24rpx;
	color: #3d3d3d;
	margin-right: 16rpx;
}

.btn-human {
	background-color: #ffffff;
	border: 1rpx solid #2d7bff;
	border-radius: 30rpx;
	padding: 6rpx 20rpx;
	display: flex;
	align-items: center;
	justify-content: center;
}

.btn-human-text {
	font-size: 24rpx;
	color: #2d7bff;
}

.input-row {
	display: flex;
	flex-direction: row;
	align-items: flex-end;
	padding: 20rpx 30rpx 16rpx;
	box-sizing: border-box;
}

.plus-icon {
	width: 48rpx;
	height: 48rpx;
	flex-shrink: 0;
	margin-right: 30rpx;
	margin-bottom: 8rpx;
}

.message-input {
	flex: 1;
	min-height: 72rpx;
	max-height: 240rpx;
	background-color: #f5f7fb;
	border-radius: 16rpx;
	padding: 16rpx 24rpx;
	font-size: 30rpx;
	line-height: 44rpx;
	color: #3d3d3d;
	box-sizing: border-box;
}

.input-placeholder {
	font-size: 30rpx;
	line-height: 44rpx;
	color: #3d3d3d;
	font-weight: 400;
}

.btn-send {
	flex-shrink: 0;
	width: 170rpx;
	min-height: 72rpx;
	margin-left: 30rpx;
	background-color: #3774fd;
	border-radius: 16rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 16rpx 0;
	box-sizing: border-box;
}

.btn-send-disabled {
	background-color: #aac4fe;
}

.btn-send-text {
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 400;
	color: #ffffff;
}

.unlogged-row {
	padding: 20rpx 30rpx 16rpx;
}

.login-btn {
	background-color: #f5f7fb;
	border: 1rpx solid #edf0f4;
	color: #3d3d3d;
	font-size: 28rpx;
	font-weight: 600;
	border-radius: 16rpx;
	height: 80rpx;
	display: flex;
	align-items: center;
	justify-content: center;
}

.login-btn::after {
	border: none;
}

.ai-disclaimer {
	font-size: 22rpx;
	color: #c9cdd4;
	text-align: center;
	margin-top: 8rpx;
	padding: 0 30rpx;
}
</style>
