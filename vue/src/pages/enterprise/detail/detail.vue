<template>
	<view class="detail-page" v-if="initialized && enterprise">
		<!-- Swiper Banner -->
		<view class="swiper-container" v-if="enterprise.images && enterprise.images.length > 0">
			<swiper
				class="top-swiper"
				circular
				autoplay
				:interval="3000"
				duration="500"
				@change="onSwiperChange"
			>
				<swiper-item v-for="(img, index) in enterprise.images" :key="index">
					<image
						class="swiper-image"
						:src="parseimage(`大图标/${img}.png`)"
						mode="aspectFill"
					/>
				</swiper-item>
			</swiper>
			<!-- Swiper Indicator -->
			<view class="swiper-indicator">
				<text class="indicator-text">
					{{ swiperIndex + 1 }}/{{ enterprise.images.length }}
				</text>
			</view>
		</view>

		<!-- Sticky Tab Bar -->
		<view class="sticky-tab-bar">
			<scroll-view class="tab-scroll" scroll-x show-scrollbar="false">
				<view class="tab-items-row">
					<view
						class="tab-item"
						v-for="(tab, index) in entfenyes"
						:key="index"
						@tap="scrollToSection(index)"
					>
						<text :class="['tab-text', { 'tab-text-active': fenyeindex === index }]">
							{{ tab }}
						</text>
						<view :class="['tab-line', { 'tab-line-active': fenyeindex === index }]"></view>
					</view>
				</view>
			</scroll-view>
		</view>

		<!-- Content Sections -->
		<view class="sections-container">
			<!-- Section 0: 公司简介 -->
			<view id="section-0" class="section-card">
				<view class="brief-header">
					<view class="brief-title-col">
						<text class="brief-name">{{ enterprise.name || "" }}</text>
						<view class="brief-tags-row" v-if="enterprise.tags && enterprise.tags.length > 0">
							<view class="brief-tag-badge" v-for="(tag, idx) in enterprise.tags" :key="idx">
								<text class="brief-tag-text">{{ tag }}</text>
							</view>
						</view>
						<view class="brief-badges-row">
							<view class="badge-item" v-if="enterprise.zone">
								<text class="badge-text">{{ enterprise.zone.value }}</text>
							</view>
							<view class="badge-item" v-if="enterprise.city">
								<text class="badge-text">{{ enterprise.city }}</text>
							</view>
						</view>
					</view>
					<image
						v-if="enterprise.icon"
						class="brief-logo"
						:src="parseimage(`小图标/${enterprise.icon}.png`)"
						mode="aspectFit"
					/>
				</view>

				<view class="brief-content">
					<view :class="['brief-desc', { 'brief-desc-collapsed': !isBriefExpanded }]">
						<text>{{ enterprise.brief || "" }}</text>
					</view>
					<view class="expand-btn-row" v-if="enterprise.brief && enterprise.brief.length > 100">
						<text class="expand-btn-text" @tap="isBriefExpanded = !isBriefExpanded">
							{{ isBriefExpanded ? "收起" : "展开" }}
						</text>
					</view>
				</view>

				<view class="info-table">
					<view class="table-row">
						<text class="table-label">全称:</text>
						<text class="table-value">{{ enterprise.name || "" }}</text>
						<text class="table-action"></text>
					</view>
					<view class="table-row" v-if="enterprise.englishname">
						<text class="table-label">英文名:</text>
						<text class="table-value">{{ enterprise.englishname }}</text>
						<text class="table-action"></text>
					</view>
					<view class="table-row" v-if="enterprise.shortname">
						<text class="table-label">简称:</text>
						<text class="table-value">{{ enterprise.shortname }}</text>
						<text class="table-action"></text>
					</view>
					<view class="table-row" v-if="enterprise.upper">
						<text class="table-label">上级单位:</text>
						<text class="table-value">{{ enterprise.upper }}</text>
						<text class="table-action"></text>
					</view>
					<view class="table-row" v-if="enterprise.sector">
						<text class="table-label">行业类别:</text>
						<text class="table-value">{{ enterprise.sector.value }}</text>
						<text class="table-action"></text>
					</view>
					<view class="table-row" v-if="enterprise.level">
						<text class="table-label">公司层级:</text>
						<text class="table-value">{{ enterprise.level.value }}</text>
						<text class="table-action"></text>
					</view>
					<view class="table-row" v-if="enterprise.website1">
						<text class="table-label">公司官网:</text>
						<text class="table-value text-blue">{{ enterprise.website1 }}</text>
						<text class="table-action text-blue" @tap="copyWebsite(enterprise.website1)">点击复制</text>
					</view>
					<view class="table-row" v-if="enterprise.website2">
						<text class="table-label">招聘官网:</text>
						<text class="table-value text-blue">{{ enterprise.website2 }}</text>
						<text class="table-action text-blue" @tap="copyWebsite(enterprise.website2)">点击复制</text>
					</view>
				</view>
			</view>

			<view class="section-divider"></view>

			<!-- Section 1: 招聘专业 -->
			<view id="section-1" class="section-card">
				<view class="section-title-row">
					<text class="section-title">招聘专业</text>
				</view>
				<view class="fields-list" v-if="enterprise.fields && enterprise.fields.length > 0">
					<view
						class="field-card"
						v-for="(field, idx) in enterprise.fields"
						:key="idx"
						@tap="onFieldTap(field.id)"
					>
						<text class="field-title">{{ field.value }}</text>
						<text class="field-subtitle">学科门类: {{ field.type }}</text>
						<view class="field-stars-row">
							<text class="field-stars-label">专业热门度:</text>
							<text class="star-icon" v-for="n in field.star" :key="n">★</text>
						</view>
						<view :class="['field-desc', { 'field-desc-collapsed': !expandedFields[field.id] }]">
							<text>{{ field.content }}</text>
						</view>
						<view class="expand-btn-row" @tap.stop="toggleFieldExpand(field.id)">
							<text class="expand-btn-text">
								{{ expandedFields[field.id] ? "收起" : "展开" }}
							</text>
						</view>
					</view>
				</view>
				<view v-else class="section-empty">
					<text class="empty-text">暂无招聘专业信息</text>
				</view>
			</view>

			<view class="section-divider"></view>

			<!-- Section 2: 深度解读 -->
			<view id="section-2" class="section-card">
				<view class="section-title-row">
					<text class="section-title">深度解读</text>
				</view>
				<view class="articles-list" v-if="enterprise.article1 && enterprise.article1.length > 0">
					<view
						class="article-card"
						v-for="(art, idx) in enterprise.article1"
						:key="idx"
						@tap="onArticleTap(art.article)"
					>
						<view class="article-info">
							<text class="article-title">{{ art.title || "未知标题" }}</text>
							<text class="article-desc">{{ art.description }}</text>
						</view>
					</view>
				</view>
				<view v-else class="section-empty">
					<text class="empty-text">暂无深度解读文章</text>
				</view>
			</view>

			<view class="section-divider"></view>

			<!-- Section 3: 成功案例 -->
			<view id="section-3" class="section-card">
				<view class="section-title-row">
					<text class="section-title">成功案例</text>
				</view>

				<view class="cases-wrapper">
					<view :class="['cases-list', { 'blur-content': !accountinfo }]">
						<view v-if="isCasesLoading" class="cases-loading">
							<text class="loading-text">加载中...</text>
						</view>
						<view v-else-if="cases.length === 0" class="section-empty">
							<text class="empty-text">暂无成功案例</text>
						</view>
						<view
							v-else
							class="case-card"
							v-for="(c, idx) in cases"
							:key="idx"
						>
							<view class="case-header">
								<text class="student-name">{{ c.student || "" }}</text>
								<view class="student-target-col">
									<text class="target-entname">{{ c.entname || "" }}</text>
									<text class="target-position">{{ c.name }}</text>
								</view>
							</view>

							<view class="case-tags-row">
								<view class="case-tags-left">
									<view
										v-for="(tag, tIdx) in c.tags.filter(t => t.trim() !== '')"
										:key="tIdx"
										:class="['case-tag-badge', `tag-color-${tIdx % 3}`]"
									>
										<text class="case-tag-text">{{ tag }}</text>
									</view>
								</view>
								<text class="case-expand-toggle" @tap="toggleCaseExpand(idx)">
									{{ expandedCases[idx] ? "收起" : "展开" }}
								</text>
							</view>

							<!-- Expanded Case Details -->
							<view class="case-expanded-details" v-if="expandedCases[idx]">
								<view class="case-divider"></view>
								
								<view class="detail-section-title">
									<view class="title-indicator"></view>
									<text class="title-text">基础信息</text>
								</view>

								<view class="detail-table">
									<view class="detail-row">
										<text class="detail-label">· 学生姓名</text>
										<text class="detail-value">{{ c.student || "--" }}</text>
									</view>
									<view class="detail-row">
										<text class="detail-label">· 本科院校</text>
										<text class="detail-value">{{ c.school1 || "--" }}</text>
									</view>
									<view class="detail-row">
										<text class="detail-label">· 本科层次</text>
										<text class="detail-value">{{ stagStr(c.stag1) }}</text>
									</view>
									<view class="detail-row">
										<text class="detail-label">· 本科专业</text>
										<text
											:class="['detail-value', { 'text-blue': c.field1 }]"
											@tap="onFieldTapByName(c.field1)"
										>
											{{ c.field1 || "--" }}
										</text>
									</view>
									<view class="detail-row">
										<text class="detail-label">· 硕士院校</text>
										<text class="detail-value">{{ c.school2 || "--" }}</text>
									</view>
									<view class="detail-row">
										<text class="detail-label">· 硕士层次</text>
										<text class="detail-value">{{ stagStr(c.stag2) }}</text>
									</view>
									<view class="detail-row">
										<text class="detail-label">· 硕士专业</text>
										<text
											:class="['detail-value', { 'text-blue': c.field2 }]"
											@tap="onFieldTapByName(c.field2)"
										>
											{{ c.field2 || "--" }}
										</text>
									</view>
									<view class="detail-row">
										<text class="detail-label">· 主要实习</text>
										<view class="detail-value list-value">
											<text v-for="(s, sIdx) in (c.detail ? c.detail.split(',') : [])" :key="sIdx" class="internship-item">
												{{ s.trim() }}
											</text>
											<text v-if="!c.detail">--</text>
										</view>
									</view>
								</view>

								<view class="detail-section-title margin-top-sm">
									<view class="title-indicator"></view>
									<text class="title-text">求职结果</text>
								</view>

								<view class="result-info">
									<text class="result-text">· 去向单位 &nbsp;&nbsp;&nbsp;&nbsp;{{ c.entname || "--" }}</text>
									<text class="result-text">· 所在部门 &nbsp;&nbsp;&nbsp;&nbsp;{{ c.dep || "--" }}</text>
									<text class="result-text">· 录取岗位 &nbsp;&nbsp;&nbsp;&nbsp;{{ c.name }}</text>
								</view>
							</view>
						</view>
					</view>

					<!-- Login Blur Overlay -->
					<view v-if="!accountinfo" class="login-overlay">
						<button open-type="getPhoneNumber" @getphonenumber="onGetPhoneNumber" class="login-btn">
							请先登录后查看
						</button>
					</view>
				</view>
			</view>
		</view>

		<!-- Bottom Navigation Bar -->
		<view class="bottom-nav-bar">
			<view class="nav-item-home" @tap="goHome">
				<image class="nav-icon" :src="parseimage('企业详情/首页.png')" mode="aspectFit" />
				<text class="nav-text">首页</text>
			</view>

			<view class="nav-item-fav">
				<button
					v-if="!accountinfo"
					open-type="getPhoneNumber"
					@getphonenumber="onGetPhoneNumber"
					class="fav-btn-unlogged"
				>
					<image class="nav-icon" :src="parseimage('企业详情/关注.png')" mode="aspectFit" />
					<text class="nav-text">关注</text>
				</button>
				<view v-else class="fav-btn-logged" @tap="toggleFavorite">
					<image
						class="nav-icon"
						:src="parseimage(isFavorited ? '企业详情/已收藏.png' : '企业详情/关注.png')"
						mode="aspectFit"
					/>
					<text class="nav-text">{{ isFavorited ? "已收藏" : "关注" }}</text>
				</view>
			</view>

			<view class="nav-btn-consult" @tap="goConsult">
				<text class="consult-btn-text">在线咨询</text>
			</view>

			<view class="nav-btn-phone" @tap="callPhone">
				<text class="phone-btn-text">电话咨询</text>
			</view>
		</view>

		<!-- Copy Success Modal -->
		<view v-if="showCopyModal" class="modal-mask" @tap="showCopyModal = false">
			<view class="modal-container" @tap.stop>
				<view class="modal-icon-circle">
					<text class="modal-icon-check">✓</text>
				</view>
				<text class="modal-title">链接已复制</text>
				<text class="modal-desc">立即咨询顾问老师，获取岗位信息，投递建议和专属资料吧！</text>
				<image class="modal-image" :src="parseimage('copy.png')" mode="aspectFit" />
				<view class="modal-buttons">
					<button class="modal-btn btn-later" @tap="showCopyModal = false">稍后查看</button>
					<button class="modal-btn btn-consult" @tap="onConsultTap">立即咨询</button>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick } from "vue";
import { onLoad, onPageScroll } from "@dcloudio/uni-app";
import { enterpriselist, accountinfo, caselist, fieldlist } from "../../../tapah/data";
import { entfenyes } from "../../../tapah/option";
import { RequestEnterpriseDetail, RequestCaseList, RequestWxCode, RequestUserInfo } from "../../../tapah/request";
import { parseimage, navigator, stagStr, openOfficialAccountArticle } from "../../../tapah/function";
import type { Enterprise, Case } from "../../../tapah/class";

const initialized = ref(false);
const enterprise = ref<Enterprise | null>(null);
const swiperIndex = ref(0);
const fenyeindex = ref(0);
const isBriefExpanded = ref(false);
const expandedFields = ref<Record<number, boolean>>({});
const expandedCases = ref<Record<number, boolean>>({});

// Cases
const cases = ref<Case[]>([]);
const isCasesLoading = ref(true);

// Copy Modal
const showCopyModal = ref(false);
const copiedUrl = ref("");

// Scroll Spy
const sectionTops = ref<number[]>([]);
const isScrollingToSection = ref(false);

const isFavorited = computed(() => {
	if (!accountinfo.value || !enterprise.value) return false;
	return accountinfo.value.enterprise.has(enterprise.value.id);
});

const onSwiperChange = (e: any) => {
	swiperIndex.value = e.detail.current;
};

const toggleFieldExpand = (id: number) => {
	expandedFields.value[id] = !expandedFields.value[id];
};

const toggleCaseExpand = (idx: number) => {
	expandedCases.value[idx] = !expandedCases.value[idx];
};

const onFieldTap = (id: number) => {
	navigator("/mainpage/fielddetail", { field: id });
};

const onFieldTapByName = (name?: string) => {
	if (!name) return;
	const field = fieldlist.value.find((f) => f.value === name);
	if (field) {
		navigator("/mainpage/fielddetail", { field: field.id });
	}
};

const onArticleTap = (url: string) => {
	openOfficialAccountArticle(url);
};

const copyWebsite = (url: string) => {
	uni.setClipboardData({
		data: url,
		success: () => {
			copiedUrl.value = url;
			showCopyModal.value = true;
		},
	});
};

const onConsultTap = () => {
	showCopyModal.value = false;
	navigator("/kefu");
};

const goHome = () => {
	navigator("/mainpage");
};

const goConsult = () => {
	navigator("/kefu");
};

const callPhone = () => {
	uni.makePhoneCall({
		phoneNumber: "051281660895",
	});
};

const toggleFavorite = async () => {
	if (!accountinfo.value || !enterprise.value) return;
	if (accountinfo.value.enterprise.has(enterprise.value.id)) {
		accountinfo.value.enterprise.delete(enterprise.value.id);
	} else {
		accountinfo.value.enterprise.add(enterprise.value.id);
	}
	try {
		await RequestUserInfo();
	} catch (err) {
		console.error("Failed to update favorite status:", err);
		uni.showToast({ title: "操作失败", icon: "none" });
	}
};

const onGetPhoneNumber = async (e: any) => {
	const code = e.detail.code;
	if (code) {
		try {
			await RequestWxCode(code);
			// Refresh cases if logged in
			if (enterprise.value) {
				loadCases();
			}
		} catch (err) {
			console.error("Failed to login with WeChat code:", err);
			uni.showToast({ title: "登录失败", icon: "none" });
		}
	} else {
		uni.showToast({ title: "获取手机号失败", icon: "none" });
	}
};

const loadCases = async () => {
	if (!enterprise.value) return;
	isCasesLoading.value = true;
	caselist.value = [];
	try {
		await RequestCaseList(enterprise.value.id, 0, 0, 0, 0, 0, 0, 1);
		cases.value = [...caselist.value];
	} catch (err) {
		console.error("Failed to load cases:", err);
	} finally {
		isCasesLoading.value = false;
		nextTick(() => {
			setTimeout(calculateSectionTops, 500);
		});
	}
};

const calculateSectionTops = () => {
	const query = uni.createSelectorQuery();
	for (let i = 0; i < 4; i++) {
		query.select(`#section-${i}`).boundingClientRect();
	}
	query.selectViewport().scrollOffset(() => {});
	query.exec((res) => {
		if (!res || res.length < 5) return;
		const viewport = res[4];
		if (!viewport) return;
		const scrollTop = viewport.scrollTop;
		const tops: number[] = [];
		for (let i = 0; i < 4; i++) {
			const rect = res[i];
			if (rect) {
				tops.push(scrollTop + rect.top);
			} else {
				tops.push(0);
			}
		}
		sectionTops.value = tops;
	});
};

const scrollToSection = (index: number) => {
	isScrollingToSection.value = true;
	fenyeindex.value = index;
	const query = uni.createSelectorQuery();
	query.select(`#section-${index}`).boundingClientRect();
	query.selectViewport().scrollOffset(() => {});
	query.exec((res) => {
		if (res && res[0] && res[1]) {
			const sectionTop = res[0].top;
			const scrollTop = res[1].scrollTop;
			// Tab bar is sticky, height is 35px (approx 70rpx)
			const targetScrollTop = scrollTop + sectionTop - 40;
			uni.pageScrollTo({
				scrollTop: targetScrollTop,
				duration: 300,
				complete: () => {
					setTimeout(() => {
						isScrollingToSection.value = false;
					}, 100);
				},
			});
		} else {
			isScrollingToSection.value = false;
		}
	});
};

onPageScroll((e) => {
	if (isScrollingToSection.value || sectionTops.value.length === 0) return;
	const scrollTop = e.scrollTop;
	let activeIndex = 0;
	for (let i = 0; i < sectionTops.value.length; i++) {
		if (scrollTop >= sectionTops.value[i] - 50) {
			activeIndex = i;
		}
	}
	fenyeindex.value = activeIndex;
});

onLoad(async (options) => {
	let enterpriseId = 0;
	if (options && options.enterprise) {
		enterpriseId = parseInt(options.enterprise, 10) || 0;
	}

	if (enterpriseId > 0) {
		// Try to find in enterpriselist first
		const found = enterpriselist.value.find((e) => e.id === enterpriseId);
		if (found) {
			enterprise.value = found;
			initialized.value = true;
			loadCases();
		} else {
			try {
				const detail = await RequestEnterpriseDetail(enterpriseId);
				enterprise.value = detail;
				initialized.value = true;
				loadCases();
			} catch (err) {
				console.error("Failed to load enterprise detail:", err);
				uni.showToast({ title: "加载失败", icon: "none" });
			}
		}
	}

	if (enterprise.value && enterprise.value.name) {
		uni.setNavigationBarTitle({
			title: enterprise.value.name,
		});
	}
});
</script>

<style scoped>
.detail-page {
	display: flex;
	flex-direction: column;
	width: 100vw;
	min-height: 100vh;
	background-color: #f8f8f8;
	padding-bottom: 120rpx; /* Space for bottom nav bar */
	box-sizing: border-box;
}

/* Swiper Banner */
.swiper-container {
	position: relative;
	width: 100%;
	height: 400rpx;
}

.top-swiper {
	width: 100%;
	height: 100%;
}

.swiper-image {
	width: 100%;
	height: 100%;
}

.swiper-indicator {
	position: absolute;
	right: 30rpx;
	bottom: 20rpx;
	background-color: rgba(0, 0, 0, 0.5);
	padding: 4rpx 16rpx;
	border-radius: 20rpx;
}

.indicator-text {
	color: #ffffff;
	font-size: 20rpx;
}

/* Sticky Tab Bar */
.sticky-tab-bar {
	position: sticky;
	top: 0;
	z-index: 100;
	background-color: #ffffff;
	border-bottom: 1rpx solid #eeeeee;
	height: 70rpx;
}

.tab-scroll {
	width: 100%;
	height: 100%;
}

.tab-items-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	padding: 0 10rpx;
	height: 100%;
}

.tab-item {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	padding: 0 20rpx;
	height: 100%;
	flex-shrink: 0;
}

.tab-text {
	font-size: 28rpx;
	color: #333333;
	line-height: 1;
}

.tab-text-active {
	font-weight: bold;
	color: #2d7bff;
}

.tab-line {
	height: 4rpx;
	width: 40rpx;
	background-color: transparent;
	margin-top: 6rpx;
	border-radius: 2rpx;
}

.tab-line-active {
	background-color: #2d7bff;
}

/* Sections Container */
.sections-container {
	display: flex;
	flex-direction: column;
}

.section-card {
	background-color: #ffffff;
	padding: 30rpx 20rpx;
	box-sizing: border-box;
}

.section-divider {
	height: 20rpx;
	background-color: #f5f5f5;
}

/* Section 0: 公司简介 */
.brief-header {
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	align-items: flex-start;
	margin-bottom: 20rpx;
}

.brief-title-col {
	flex: 1;
	display: flex;
	flex-direction: column;
	margin-right: 20rpx;
}

.brief-name {
	font-size: 36rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 16rpx;
}

.brief-tags-row {
	display: flex;
	flex-direction: row;
	flex-wrap: wrap;
	margin-bottom: 16rpx;
}

.brief-tag-badge {
	background-color: #feeddf;
	border-radius: 8rpx;
	padding: 4rpx 16rpx;
	margin-right: 12rpx;
	margin-bottom: 8rpx;
}

.brief-tag-text {
	font-size: 20rpx;
	color: #692e1f;
}

.brief-badges-row {
	display: flex;
	flex-direction: row;
}

.badge-item {
	background-color: #eeeeee;
	border-radius: 8rpx;
	padding: 2rpx 16rpx;
	margin-right: 20rpx;
}

.badge-text {
	font-size: 18rpx;
	color: #333333;
}

.brief-logo {
	width: 120rpx;
	height: 120rpx;
	flex-shrink: 0;
}

.brief-content {
	margin-bottom: 30rpx;
}

.brief-desc {
	font-size: 30rpx;
	color: #333333;
	line-height: 1.5;
}

.brief-desc-collapsed {
	display: -webkit-box;
	-webkit-line-clamp: 4;
	-webkit-box-orient: vertical;
	overflow: hidden;
}

.expand-btn-row {
	display: flex;
	justify-content: flex-end;
	margin-top: 10rpx;
}

.expand-btn-text {
	color: #2d7bff;
	font-size: 26rpx;
}

/* Info Table */
.info-table {
	display: flex;
	flex-direction: column;
	border-top: 1rpx solid #eeeeee;
	padding-top: 20rpx;
}

.table-row {
	display: flex;
	flex-direction: row;
	padding: 12rpx 0;
	font-size: 28rpx;
	align-items: flex-start;
}

.table-label {
	width: 150rpx;
	font-weight: bold;
	color: #333333;
	text-align: right;
	margin-right: 20rpx;
}

.table-value {
	flex: 1;
	color: #333333;
	word-break: break-all;
}

.table-action {
	width: 140rpx;
	font-weight: bold;
	text-align: right;
}

.text-blue {
	color: #2d7bff !important;
}

/* Section 1: 招聘专业 */
.section-title-row {
	margin-bottom: 30rpx;
}

.section-title {
	font-size: 32rpx;
	font-weight: bold;
	color: #333333;
	border-left: 6rpx solid #2d7bff;
	padding-left: 16rpx;
}

.fields-list {
	display: flex;
	flex-direction: column;
}

.field-card {
	border: 1rpx solid #2d7bff;
	border-radius: 16rpx;
	padding: 20rpx;
	margin-bottom: 20rpx;
	box-sizing: border-box;
}

.field-title {
	font-size: 30rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 10rpx;
}

.field-subtitle {
	font-size: 22rpx;
	color: #333333;
	margin-bottom: 10rpx;
}

.field-stars-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-bottom: 10rpx;
}

.field-stars-label {
	font-size: 22rpx;
	color: #333333;
	margin-right: 10rpx;
}

.star-icon {
	color: #ff9800;
	font-size: 32rpx;
	margin-right: 4rpx;
}

.field-desc {
	font-size: 26rpx;
	color: #666666;
	line-height: 1.4;
}

.field-desc-collapsed {
	display: -webkit-box;
	-webkit-line-clamp: 3;
	-webkit-box-orient: vertical;
	overflow: hidden;
}

/* Section 2: 深度解读 */
.articles-list {
	display: flex;
	flex-direction: column;
}

.article-card {
	background-color: #ffffff;
	border-radius: 16rpx;
	padding: 20rpx;
	margin-bottom: 20rpx;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
	border: 1rpx solid #eeeeee;
}

.article-info {
	display: flex;
	flex-direction: column;
}

.article-title {
	font-size: 30rpx;
	font-weight: bold;
	color: #333333;
	margin-bottom: 8rpx;
	overflow: hidden;
	text-overflow: ellipsis;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
}

.article-desc {
	font-size: 24rpx;
	color: #666666;
	overflow: hidden;
	text-overflow: ellipsis;
	display: -webkit-box;
	-webkit-line-clamp: 2;
	-webkit-box-orient: vertical;
}

/* Section 3: 成功案例 */
.cases-wrapper {
	position: relative;
	width: 100%;
}

.cases-list {
	display: flex;
	flex-direction: column;
}

.blur-content {
	filter: blur(12px);
	pointer-events: none;
}

.cases-loading {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 40rpx 0;
}

.case-card {
	background-color: #ffffff;
	border-radius: 16rpx;
	padding: 20rpx;
	margin-bottom: 20rpx;
	border: 1rpx solid #eeeeee;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.02);
}

.case-header {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	margin-bottom: 10rpx;
}

.student-name {
	font-size: 30rpx;
	font-weight: bold;
	color: #2d7bff;
	width: 140rpx;
	flex-shrink: 0;
}

.student-target-col {
	flex: 1;
	display: flex;
	flex-direction: column;
}

.target-entname {
	font-size: 30rpx;
	font-weight: bold;
	color: #333333;
	line-height: 1.2;
}

.target-position {
	font-size: 20rpx;
	font-weight: bold;
	color: #333333;
	margin-top: 4rpx;
}

.case-tags-row {
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	align-items: center;
}

.case-tags-left {
	display: flex;
	flex-direction: row;
	flex-wrap: wrap;
	flex: 1;
}

.case-tag-badge {
	border-radius: 8rpx;
	padding: 4rpx 12rpx;
	margin-right: 10rpx;
	margin-bottom: 6rpx;
}

.tag-color-0 {
	background-color: #e8f0fe;
}
.tag-color-0 .case-tag-text {
	color: #2d7bff;
}

.tag-color-1 {
	background-color: #feeddf;
}
.tag-color-1 .case-tag-text {
	color: #692e1f;
}

.tag-color-2 {
	background-color: #f3eeff;
}
.tag-color-2 .case-tag-text {
	color: #6b21a8;
}

.case-tag-text {
	font-size: 22rpx;
}

.case-expand-toggle {
	font-size: 24rpx;
	color: #2d7bff;
	margin-left: 20rpx;
	flex-shrink: 0;
}

/* Expanded Case Details */
.case-expanded-details {
	display: flex;
	flex-direction: column;
}

.case-divider {
	height: 1rpx;
	background-color: #eeeeee;
	margin: 16rpx 0;
}

.detail-section-title {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-bottom: 12rpx;
}

.title-indicator {
	width: 6rpx;
	height: 24rpx;
	background-color: #2d7bff;
	margin-right: 16rpx;
}

.title-text {
	font-size: 26rpx;
	font-weight: bold;
	color: #333333;
}

.detail-table {
	display: flex;
	flex-direction: column;
	margin-bottom: 20rpx;
}

.detail-row {
	display: flex;
	flex-direction: row;
	padding: 6rpx 0;
	font-size: 24rpx;
}

.detail-label {
	width: 160rpx;
	color: #555555;
}

.detail-value {
	flex: 1;
	color: #555555;
}

.list-value {
	display: flex;
	flex-direction: column;
}

.internship-item {
	margin-bottom: 4rpx;
}

.margin-top-sm {
	margin-top: 10rpx;
}

.result-info {
	display: flex;
	flex-direction: column;
}

.result-text {
	font-size: 24rpx;
	color: #555555;
	padding: 4rpx 0;
}

/* Login Overlay */
.login-overlay {
	position: absolute;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	display: flex;
	align-items: center;
	justify-content: center;
	background-color: rgba(0, 0, 0, 0.05);
	z-index: 10;
}

.login-btn {
	background-color: rgba(0, 0, 0, 0.65);
	color: #ffffff;
	font-size: 32rpx;
	font-weight: 600;
	border-radius: 16rpx;
	padding: 24rpx 48rpx;
	line-height: 1;
	border: none;
}

/* Section Empty */
.section-empty {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 40rpx 0;
}

.empty-text {
	font-size: 28rpx;
	color: #888888;
}

/* Bottom Navigation Bar */
.bottom-nav-bar {
	position: fixed;
	bottom: 0;
	left: 0;
	right: 0;
	height: 120rpx;
	background-color: #ffffff;
	border-top: 1rpx solid #eeeeee;
	display: flex;
	flex-direction: row;
	align-items: center;
	padding: 0 20rpx;
	box-sizing: border-box;
	z-index: 200;
}

.nav-item-home,
.nav-item-fav {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	width: 100rpx;
	height: 100%;
}

.nav-item-home {
	margin-right: 10rpx;
}

.nav-icon {
	width: 56rpx;
	height: 56rpx;
	margin-bottom: 4rpx;
}

.nav-text {
	font-size: 20rpx;
	color: #333333;
	line-height: 1;
}

.fav-btn-unlogged {
	background: none;
	border: none;
	padding: 0;
	margin: 0;
	line-height: 1.2;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	width: 100%;
	height: 100%;
}

.fav-btn-unlogged::after {
	border: none;
}

.fav-btn-logged {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	width: 100%;
	height: 100%;
}

.nav-btn-consult,
.nav-btn-phone {
	flex: 1;
	height: 70rpx;
	border-radius: 35rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	margin: 0 10rpx;
}

.nav-btn-consult {
	background-color: #82b2f5;
}

.consult-btn-text {
	color: #ffffff;
	font-size: 28rpx;
	font-weight: bold;
}

.nav-btn-phone {
	background-color: #ffc300;
}

.phone-btn-text {
	color: #ffffff;
	font-size: 28rpx;
	font-weight: bold;
}

/* Copy Success Modal */
.modal-mask {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: rgba(0, 0, 0, 0.5);
	display: flex;
	align-items: center;
	justify-content: center;
	z-index: 1000;
}

.modal-container {
	width: 560rpx;
	background-color: #f3f3f3;
	border-radius: 64rpx;
	padding: 40rpx 30rpx;
	display: flex;
	flex-direction: column;
	align-items: center;
	box-sizing: border-box;
}

.modal-icon-circle {
	width: 136rpx;
	height: 136rpx;
	border-radius: 68rpx;
	background-color: #d5e5d8;
	display: flex;
	align-items: center;
	justify-content: center;
	margin-bottom: 28rpx;
}

.modal-icon-check {
	font-size: 80rpx;
	color: #34be7b;
	line-height: 1;
}

.modal-title {
	font-size: 44rpx;
	font-weight: bold;
	color: #3d3d3d;
	margin-bottom: 12rpx;
}

.modal-desc {
	font-size: 28rpx;
	color: #3d3d3d;
	text-align: center;
	padding: 0 32rpx;
	line-height: 1.4;
	margin-bottom: 20rpx;
}

.modal-image {
	height: 144rpx;
	width: 100%;
	margin-bottom: 40rpx;
}

.modal-buttons {
	display: flex;
	flex-direction: row;
	width: 100%;
}

.modal-btn {
	flex: 1;
	height: 80rpx;
	border-radius: 36rpx;
	font-size: 32rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	border: none;
	line-height: 1;
	box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.12);
}

.modal-btn::after {
	border: none;
}

.btn-later {
	background-color: #f0f0f0;
	color: #333333;
	margin-right: 16rpx;
}

.btn-consult {
	background-color: #2f74f7;
	color: #ffffff;
	margin-left: 16rpx;
}
</style>
