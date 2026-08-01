<template>
	<view class="aizhushou-page">
		<!-- Main Scroll Area -->
		<scroll-view
			class="chat-scroll"
			scroll-y
			:scroll-top="scrollTop"
			@scrolltoupper="onScrollToUpper"
		>
			<view class="chat-container">
				<!-- Header Intro -->
				<view class="ai-header">
					<text class="ai-title">求职家智能咨询</text>
					<text class="ai-subtitle">智能客服在线，帮你快速了解服务内容</text>
					<image class="ai-avatar-large" :src="parseimage('栏目/AI助手/机器人头像.png')" mode="aspectFit" />
					<text class="ai-welcome">你好，我是求职家智能ai助手👋</text>
					<text class="ai-desc">
						我可以帮你解答课程服务、简历精修、模拟面试、秋招计划、岗位内推等内容。也可以为你提供求职建议。
					</text>
				</view>

				<!-- Guess What You Want to Ask -->
				<view class="questions-card" v-if="questions.length > 0">
					<view class="card-header">
						<image class="bulb-icon" :src="parseimage('栏目/AI助手/灯泡.png')" mode="aspectFit" />
						<text class="card-title">猜你想问</text>
					</view>
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

				<!-- Chat Message List -->
				<view class="chat-list">
					<view v-if="historyLoading" class="history-loading">
						<text class="loading-text">加载历史记录中...</text>
					</view>
					<view v-else-if="historyHasMore && chatlist.length > 0" class="history-tip">
						<text class="tip-text">下拉加载更多历史记录</text>
					</view>

					<block v-for="(msg, idx) in chatlist" :key="idx">
						<!-- Timestamp divider if gap > 5 mins (300s) -->
						<view class="time-divider" v-if="shouldShowTime(idx)">
							<text class="time-text">{{ formatTime(msg.timestamp) }}</text>
						</view>

						<!-- Message Bubble -->
						<view :class="['message-row', msg.isuser ? 'row-user' : 'row-ai']">
							<image
								class="chat-avatar"
								:src="msg.isuser ? (accountinfo?.avatar || parseimage('客服/头像.png')) : parseimage('栏目/AI助手/机器人头像.png')"
								mode="aspectFill"
							/>
							<view :class="['bubble-card', msg.isuser ? 'bubble-user' : 'bubble-ai']">
								<!-- Standard Text for user, Rich Text for AI Markdown -->
								<text v-if="msg.isuser" class="bubble-text">{{ msg.detail }}</text>
								<rich-text v-else class="bubble-text-ai" :nodes="renderMarkdown(msg.detail)"></rich-text>
							</view>
						</view>
					</block>

					<!-- Typing Indicator -->
					<view class="message-row row-ai" v-if="sending">
						<image class="chat-avatar" :src="parseimage('栏目/AI助手/机器人头像.png')" mode="aspectFill" />
						<view class="bubble-card bubble-ai typing-bubble">
							<text class="typing-text">正在输入(大概需要30秒){{ ".".repeat(typingDotCount) }}</text>
						</view>
					</view>
				</view>
			</view>
		</scroll-view>

		<!-- Bottom Action and Input Area -->
		<view class="bottom-area">
			<!-- Human Advisor Banner -->
			<view class="advisor-row">
				<text class="advisor-text">没解决问题？联系人工顾问为你提供更专业的解答</text>
				<view class="btn-human" @tap="goKefu">
					<text class="btn-human-text">转人工</text>
				</view>
			</view>

			<!-- Input Form -->
			<view class="input-row" v-if="accountinfo">
				<!-- Agent Picker -->
				<picker
					mode="selector"
					:range="agentLabels"
					:value="agentIndex"
					@change="onAgentChange"
					:disabled="!canInteract"
				>
					<view class="agent-picker">
						<text class="agent-picker-text">{{ agentLabels[agentIndex] }}</text>
						<text class="picker-arrow">▼</text>
					</view>
				</picker>

				<!-- Text Input -->
				<input
					class="message-input"
					type="text"
					v-model="messageText"
					placeholder="请输入你想咨询的问题"
					:disabled="!canInteract"
					confirm-type="send"
					@confirm="onSendClick"
				/>

				<!-- Send Button -->
				<view
					:class="['btn-send', { 'btn-send-disabled': !canInteract || messageText.trim().length === 0 }]"
					@tap="canInteract && messageText.trim().length > 0 ? onSendClick() : null"
				>
					<text class="btn-send-text">发送</text>
				</view>
			</view>

			<!-- Unlogged Login Button -->
			<view class="unlogged-row" v-else>
				<button open-type="getPhoneNumber" @getphonenumber="onGetPhoneNumber" class="login-btn">
					请先登录再提问
				</button>
			</view>

			<text class="ai-disclaimer">内容由AI生成，仅供参考</text>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick } from "vue";
import { onLoad } from "@dcloudio/uni-app";
import { accountinfo, chataiToken, chataiTokenExpiresAt } from "../../../tapah/data";
import { RequestQuestions, RequestAIChatHistory, RequestChatAIAuth, RequestChatAIChat, RequestWxCode } from "../../../tapah/request";
import { parseimage, navigator } from "../../../tapah/function";
import { ChatItem } from "../../../tapah/class";

const agents = {
	resume: "简历助手",
	joblevel: "岗位分析",
};
const agentKeys = ["resume", "joblevel"];
const agentLabels = ["简历助手", "岗位分析"];

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
let typingTimer: any = null;

const selectedAgent = computed(() => agentKeys[agentIndex.value] || "resume");
const canSend = computed(() => !sending.value && !inCooldown.value);
const canInteract = computed(() => accountinfo.value !== null && canSend.value);

const formatTime = (ts: number) => {
	const dt = new Date(ts * 1000);
	const now = new Date();
	const hour = String(dt.getHours()).padStart(2, "0");
	const minute = String(dt.getMinutes()).padStart(2, "0");
	const time = `${hour}:${minute}`;
	if (dt.getFullYear() === now.getFullYear() && dt.getMonth() === now.getMonth() && dt.getDate() === now.getDate()) {
		return time;
	} else {
		return `${dt.getMonth() + 1}月${dt.getDate()}日 ${time}`;
	}
};

const shouldShowTime = (idx: number) => {
	if (idx === 0) return true;
	const current = chatlist.value[idx];
	const prev = chatlist.value[idx - 1];
	if (!current || !prev) return false;
	return current.timestamp - prev.timestamp > 300; // 5 minutes
};

const renderMarkdown = (text: string) => {
	// A simple markdown to HTML parser for standard rich-text rendering
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
			scrollTop.value = 99999 + Math.random(); // Force scroll update
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

		// 10 seconds cooldown
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

const onAgentChange = (e: any) => {
	const idx = parseInt(e.detail.value, 10);
	if (idx !== agentIndex.value && canInteract.value) {
		agentIndex.value = idx;
		chatlist.value = [];
		historyHasMore.value = true;
		loadQuestions();
		initChat();
	}
};

const goKefu = () => {
	navigator("/kefu");
};

const onGetPhoneNumber = async (e: any) => {
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
	background-color: #f8f8f8;
	box-sizing: border-box;
}

.chat-scroll {
	flex: 1;
	width: 100%;
	overflow: hidden;
}

.chat-container {
	display: flex;
	flex-direction: column;
	padding: 30rpx;
	box-sizing: border-box;
}

/* Header Intro */
.ai-header {
	display: flex;
	flex-direction: column;
	align-items: center;
	margin-bottom: 40rpx;
}

.ai-title {
	font-size: 40rpx;
	font-weight: 600;
	color: #1d2129;
	margin-bottom: 12rpx;
}

.ai-subtitle {
	font-size: 26rpx;
	color: #979797;
	margin-bottom: 30rpx;
}

.ai-avatar-large {
	width: 160rpx;
	height: 160rpx;
	margin-bottom: 30rpx;
}

.ai-welcome {
	font-size: 40rpx;
	font-weight: 600;
	color: #1d2129;
	margin-bottom: 20rpx;
}

.ai-desc {
	font-size: 32rpx;
	color: #979797;
	text-align: center;
	line-height: 1.4;
	padding: 0 40rpx;
}

/* Guess Questions Card */
.questions-card {
	background-color: #ffffff;
	border-radius: 24rpx;
	padding: 30rpx;
	margin-bottom: 40rpx;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
}

.card-header {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-bottom: 20rpx;
}

.bulb-icon {
	width: 40rpx;
	height: 40rpx;
	margin-right: 12rpx;
}

.card-title {
	font-size: 32rpx;
	font-weight: 600;
	color: #1d2129;
}

.questions-list {
	display: flex;
	flex-direction: column;
}

.question-item {
	background-color: #ecf3fd;
	border: 1rpx solid #d1dffd;
	border-radius: 20rpx;
	padding: 16rpx 32rpx;
	margin-bottom: 16rpx;
	box-sizing: border-box;
}

.question-item:last-child {
	margin-bottom: 0;
}

.question-text {
	font-size: 32rpx;
	color: #3774fd;
}

.disabled-click {
	opacity: 0.5;
	pointer-events: none;
}

/* Chat Message List */
.chat-list {
	display: flex;
	flex-direction: column;
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
	color: #c9cdd4;
}

.time-divider {
	display: flex;
	align-items: center;
	justify-content: center;
	margin: 24rpx 0;
}

.time-text {
	font-size: 24rpx;
	color: #c9cdd4;
}

.message-row {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	margin-bottom: 30rpx;
	width: 100%;
}

.row-user {
	flex-direction: row-reverse;
}

.chat-avatar {
	width: 72rpx;
	height: 72rpx;
	border-radius: 36rpx;
	flex-shrink: 0;
}

.bubble-card {
	max-width: 70%;
	padding: 20rpx 32rpx;
	border-radius: 24rpx;
	box-sizing: border-box;
	word-break: break-all;
}

.bubble-ai {
	background-color: #ffffff;
	color: #1d2129;
	margin-left: 16rpx;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
}

.bubble-user {
	background-color: #3774fd;
	color: #ffffff;
	margin-right: 16rpx;
}

.bubble-text {
	font-size: 32rpx;
	line-height: 1.4;
}

.bubble-text-ai {
	font-size: 32rpx;
	line-height: 1.4;
}

.typing-bubble {
	display: flex;
	align-items: center;
}

.typing-text {
	font-size: 28rpx;
	color: #c9cdd4;
}

/* Bottom Area */
.bottom-area {
	border-top: 1rpx solid #edf0f4;
	background-color: #ffffff;
	display: flex;
	flex-direction: column;
	padding-bottom: 20rpx;
}

.advisor-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	background-color: #f8f9fc;
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

/* Input Form */
.input-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	padding: 20rpx;
	box-sizing: border-box;
}

.agent-picker {
	background-color: #f5f7fb;
	border: 1rpx solid #edf0f4;
	border-radius: 36rpx;
	height: 80rpx;
	width: 160rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	margin-right: 16rpx;
}

.agent-picker-text {
	font-size: 24rpx;
	color: #3d3d3d;
	margin-right: 4rpx;
}

.picker-arrow {
	font-size: 16rpx;
	color: #3774fd;
}

.message-input {
	flex: 1;
	background-color: #f5f7fb;
	border: 1rpx solid #edf0f4;
	border-radius: 36rpx;
	height: 80rpx;
	padding: 0 24rpx;
	font-size: 28rpx;
	color: #3d3d3d;
	margin-right: 16rpx;
}

.btn-send {
	background-color: #3774fd;
	border-radius: 36rpx;
	height: 80rpx;
	width: 120rpx;
	display: flex;
	align-items: center;
	justify-content: center;
}

.btn-send-disabled {
	background-color: #aac4fe;
}

.btn-send-text {
	font-size: 28rpx;
	color: #ffffff;
}

/* Unlogged Row */
.unlogged-row {
	padding: 20rpx 40rpx;
}

.login-btn {
	background-color: #f5f7fb;
	border: 1rpx solid #edf0f4;
	color: #3d3d3d;
	font-size: 28rpx;
	font-weight: 600;
	border-radius: 36rpx;
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
	margin-top: 10rpx;
}
</style>
