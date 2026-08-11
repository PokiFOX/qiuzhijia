<template>
	<view class="lanmu-page">
		<scroll-view class="scroll-container" scroll-y>
			<Service />
		</scroll-view>
	</view>
</template>

<script setup lang="ts">
import Service from "../../mainpage/components/service.vue";
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
</style>
