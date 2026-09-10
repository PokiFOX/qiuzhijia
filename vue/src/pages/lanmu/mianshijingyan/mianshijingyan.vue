<template>
	<LanmuImageScrollPage folder="面试经验" :section-images="sectionImages" />
</template>

<script setup lang="ts">
import LanmuImageScrollPage from "../components/LanmuImageScrollPage.vue";

const sectionImages = [
	"1.你将获得.png",
	"2.适合人群.png",
	"3.服务内容.png",
	"4.服务流程.png",
	"5.提升重点.png",
	"6.行业认知提升.png",
	"7.辅导团队支持.png",
];
</script>
