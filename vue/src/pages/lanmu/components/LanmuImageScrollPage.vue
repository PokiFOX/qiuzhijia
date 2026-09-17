<template>
	<view class="lanmu-scroll-page">
		<image
			class="footer-9-fixed"
			:src="sharedImage('9.底背景.png')"
			mode="widthFix"
		/>

		<scroll-view class="service-scroll" scroll-y enhanced :show-scrollbar="false">
			<view class="service-page">
				<image
					class="img-full"
					:src="lanmuImage('海报.png')"
					mode="widthFix"
				/>

				<view class="gap-sm" />

				<view class="section-block">
					<image
						class="img-padded"
						:src="lanmuImage('题头.png')"
						mode="widthFix"
					/>
				</view>

				<view class="gap-xs" />

				<view
					v-for="(name, index) in sectionImages"
					:key="name"
					class="section-block"
				>
					<image
						class="img-padded"
						:src="lanmuImage(name)"
						mode="widthFix"
					/>
					<view v-if="index < sectionImages.length - 1" class="gap-xs" />
				</view>

				<view class="block-8">
					<image
						class="img-padded"
						:src="sharedImage('8.在线咨询方式.png')"
						mode="widthFix"
						show-menu-by-longpress
					/>
				</view>

				<!-- 8 离底 70（设计稿）= 140rpx，写死 -->
				<view class="gap-8-to-bottom" />
			</view>
		</scroll-view>
	</view>
</template>

<script setup lang="ts">
import { parseimage } from "../../../tapah/function";

const props = defineProps<{
	folder: string;
	sectionImages: string[];
}>();

const lanmuImage = (name: string) => parseimage(`${props.folder}/${name}`);
const sharedImage = (name: string) => parseimage(`求职家服务/${name}`);
</script>

<style scoped>
.lanmu-scroll-page {
	position: relative;
	width: 100%;
	height: 100vh;
	background-color: #e0ebfc;
	box-sizing: border-box;
	overflow: hidden;
}

.footer-9-fixed {
	position: fixed;
	left: 0;
	right: 0;
	bottom: 0;
	width: 100%;
	z-index: 0;
	display: block;
	pointer-events: none;
}

.service-scroll {
	position: relative;
	z-index: 1;
	width: 100%;
	height: 100%;
	background-color: transparent;
	box-sizing: border-box;
}

.service-page {
	display: flex;
	flex-direction: column;
	width: 100%;
	box-sizing: border-box;
}

.img-full {
	width: 100%;
	display: block;
}

.section-block {
	padding: 0 20rpx;
	box-sizing: border-box;
}

.img-padded {
	width: 100%;
	display: block;
}

.gap-sm {
	height: 10rpx;
	flex-shrink: 0;
}

.gap-xs {
	height: 8rpx;
	flex-shrink: 0;
}

.block-8 {
	padding: 0 20rpx;
	box-sizing: border-box;
}

/* 8 离底 70 → 140rpx，写死 */
.gap-8-to-bottom {
	height: 140rpx;
	flex-shrink: 0;
}
</style>
