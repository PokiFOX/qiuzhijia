<template>
	<LanmuImageScrollPage folder="教授科研" :section-images="sectionImages" />
</template>

<script setup lang="ts">
import LanmuImageScrollPage from "../components/LanmuImageScrollPage.vue";

const sectionImages = [
	"1.计划简介.png",
	"2.适合人群.png",
	"3.服务类别.png",
	"4.服务流程.png",
	"5.导师库及研究方向.png",
];
</script>
