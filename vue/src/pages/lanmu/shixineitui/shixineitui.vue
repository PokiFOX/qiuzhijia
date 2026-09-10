<template>
	<LanmuImageScrollPage folder="实习内推" :section-images="sectionImages" />
</template>

<script setup lang="ts">
import LanmuImageScrollPage from "../components/LanmuImageScrollPage.vue";

const sectionImages = [
	"1.计划简介.png",
	"2.适合人群.png",
	"3.服务内容.png",
	"4.服务流程.png",
	"5.服务企业类别.png",
	"6.实习项目.png",
];
</script>
