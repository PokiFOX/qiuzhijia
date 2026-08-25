<template>
	<view class="sheet-page">
		<BottomSheet :visible="visible" title="企业列表" @close="onClose">
			<FieldEnterpriseListPanel :field-id="fieldId" :active="visible" />
		</BottomSheet>
	</view>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { onLoad } from "@dcloudio/uni-app";

import { fieldlist } from "../../../tapah/data";
import BottomSheet from "../../../components/BottomSheet.vue";
import FieldEnterpriseListPanel from "../../../components/FieldEnterpriseListPanel.vue";

const fieldId = ref(0);
const visible = ref(false);

const onClose = () => {
	visible.value = false;
	setTimeout(() => {
		uni.navigateBack();
	}, 300);
};

onLoad((options) => {
	if (options?.field) {
		fieldId.value = parseInt(options.field, 10) || 0;
	}
	if (fieldId.value > 0 && fieldlist.value.some((f) => f.id === fieldId.value)) {
		setTimeout(() => {
			visible.value = true;
		}, 50);
	} else {
		uni.navigateBack();
	}
});
</script>

<style scoped>
.sheet-page {
	width: 100vw;
	height: 100vh;
	background-color: transparent;
}
</style>
