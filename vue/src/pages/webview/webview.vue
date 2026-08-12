<template>
	<web-view v-if="pageUrl" :src="pageUrl" @error="onError" />
</template>

<script setup lang="ts">
import { ref } from "vue";
import { onLoad } from "@dcloudio/uni-app";

const pageUrl = ref("");

onLoad((options) => {
	const raw = options?.url ? decodeURIComponent(String(options.url)) : "";
	pageUrl.value = raw;
});

const onError = () => {
	uni.showToast({ title: "无法打开链接", icon: "none" });
};
</script>
