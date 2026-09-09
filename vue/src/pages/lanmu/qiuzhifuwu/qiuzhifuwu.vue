<template>
	<view class="qiuzhifuwu-page" :class="{ 'qiuzhifuwu-page-embedded': embedded }">
		<image
			class="footer-9-fixed"
			:src="serviceImage('9.底背景.png')"
			mode="widthFix"
		/>

		<scroll-view class="service-scroll" scroll-y enhanced :show-scrollbar="false">
			<view class="service-page">
				<image
					class="img-full"
					:src="serviceImage('0.海报.png')"
					mode="widthFix"
				/>

				<view class="gap-sm" />

				<view
					v-for="(name, index) in sectionImages"
					:key="name"
					class="section-block"
				>
					<image
						class="img-padded"
						:src="serviceImage(name)"
						mode="widthFix"
					/>
					<view v-if="index < sectionImages.length - 1" class="gap-xs" />
				</view>

				<view class="block-8">
					<image
						class="img-padded"
						:src="serviceImage('8.在线咨询方式.png')"
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

withDefaults(
	defineProps<{
		embedded?: boolean;
	}>(),
	{
		embedded: false,
	},
);

const sectionImages = [
	"1.关于我们.png",
	"2.服务模式.png",
	"3.覆盖辅导专业大类.png",
	"4.上岸范围.png",
	"5.全程无忧服务明细.png",
	"6.首席辅导团队.png",
	"7.辅导团队支持.png",
];

const serviceImage = (name: string) => parseimage(`求职家服务/${name}`);
</script>

<style scoped>
.qiuzhifuwu-page {
	position: relative;
	width: 100%;
	height: 100vh;
	background-color: #e0ebfc;
	box-sizing: border-box;
	overflow: hidden;
}

.qiuzhifuwu-page-embedded {
	height: 100%;
	min-height: 0;
}

.footer-9-fixed {
	position: absolute;
	left: 0;
	right: 0;
	bottom: 0;
	width: 100%;
	z-index: 0;
	display: block;
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
