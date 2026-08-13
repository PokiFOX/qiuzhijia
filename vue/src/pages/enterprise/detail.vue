<template>
	<view class="detail-root" v-if="initialized && enterprise">
		<scroll-view
			class="detail-scroll"
			scroll-y
			enhanced
			:show-scrollbar="false"
			:style="detailScrollStyle"
			:scroll-top="pageScrollTop"
			:scroll-with-animation="scrollWithAnimation"
			@scroll="onDetailScroll"
		>
			<view class="detail-page">
		<!-- Top Banner -->
		<view class="banner-wrap" v-if="enterprise.images && enterprise.images.length > 0">
			<swiper class="top-swiper" :style="bannerSwiperStyle" circular autoplay :interval="3000" duration="500" @change="onSwiperChange">
				<swiper-item v-for="(img, index) in enterprise.images" :key="index">
					<image class="banner-image" :src="parseEnterpriseIcon(`大图标/${img}.png`)" mode="widthFix" @load="onBannerImageLoad"/>
				</swiper-item>
			</swiper>
			<view class="swiper-indicator">
				<text class="indicator-text">{{ swiperIndex + 1 }}/{{ enterprise.images.length }}</text>
			</view>
		</view>

		<!-- Main Panel -->
		<view class="main-panel">
			<!-- Scroll-spy Tabs -->
			<view class="sticky-tab-bar">
				<view class="tab-items-row">
					<view class="tab-item" v-for="(tab, index) in entfenyes" :key="index" @tap="scrollToSection(index)">
						<text :class="['tab-text', { 'tab-text-active': fenyeindex === index }]">{{ tab }}</text>
						<view :class="['tab-line', { 'tab-line-active': fenyeindex === index }]"></view>
					</view>
				</view>
			</view>

			<view class="sections-inner">
				<!-- Section 0: 公司简介 -->
				<view id="section-0" class="section-card">
					<view class="name-row">
						<view class="name-marquee-col">
							<text class="enterprise-name-text">{{ enterprise.name || "" }}</text>
						</view>
						<view v-if="enterprise.icon" class="enterprise-icon-wrap">
							<image class="enterprise-icon" :src="parseEnterpriseIcon(`小图标/${enterprise.icon}.png`)" mode="aspectFit"/>
						</view>
					</view>

					<view class="location-row">
						<image class="location-icon" :src="parseimage('企业列表/定位.png')" mode="aspectFit" />
						<text class="location-text">
							{{ enterprise.zone?.value || "" }} {{ enterprise.city || "" }}
						</text>
					</view>

					<scroll-view v-if="enterprise.tags && enterprise.tags.length > 0" class="tags-scroll" scroll-x :show-scrollbar="false" enable-flex>
						<view class="tags-row">
							<view class="tag-badge" v-for="(tag, idx) in enterprise.tags" :key="idx">
								<text class="tag-text">{{ tag }}</text>
							</view>
						</view>
					</scroll-view>

					<view class="brief-box" v-if="enterprise.brief">
						<view :class="['brief-content', { 'brief-content-collapsed': !isBriefExpanded && needBriefToggle }]">
							<text class="brief-desc">
								{{ enterprise.brief }}<text v-if="needBriefToggle && isBriefExpanded" class="brief-toggle-inline" @tap.stop="toggleBrief"> 收起 ▲</text>
							</text>
							<view v-if="needBriefToggle && !isBriefExpanded" class="brief-toggle-overlay" @tap.stop="toggleBrief">
								<text class="brief-toggle-text">展开</text>
								<text class="brief-toggle-arrow">▼</text>
							</view>
						</view>
					</view>

					<view class="info-table">
						<view class="table-row">
							<text class="table-label">全　　称</text>
							<text class="table-value">{{ enterprise.name || "" }}</text>
						</view>
						<view class="table-row" v-if="enterprise.englishname">
							<text class="table-label">英　　文</text>
							<text class="table-value">{{ enterprise.englishname }}</text>
						</view>
						<view class="table-row" v-if="enterprise.shortname">
							<text class="table-label">简　　称</text>
							<text class="table-value">{{ enterprise.shortname }}</text>
						</view>
						<view class="table-row" v-if="enterprise.upper">
							<text class="table-label">上级单位</text>
							<text class="table-value">{{ enterprise.upper }}</text>
						</view>
						<view class="table-row" v-if="enterprise.sector">
							<text class="table-label">行业类别</text>
							<text class="table-value">{{ enterprise.sector.value }}</text>
						</view>
						<view class="table-row" v-if="enterprise.level">
							<text class="table-label">公司层级</text>
							<text class="table-value">{{ enterprise.level.value }}</text>
						</view>
						<view class="table-row" v-if="enterprise.website1">
							<text class="table-label">公司官网</text>
							<text class="table-value table-link" @tap="openWebsite(enterprise.website1)">
								{{ enterprise.website1 }}
							</text>
							<text class="table-copy" @tap.stop="copyWebsite(enterprise.website1)">复制链接</text>
						</view>
						<view class="table-row" v-if="enterprise.website2">
							<text class="table-label">招聘官网</text>
							<text class="table-value table-link" @tap="openWebsite(enterprise.website2)">
								{{ enterprise.website2 }}
							</text>
							<text class="table-copy" @tap.stop="copyWebsite(enterprise.website2)">复制链接</text>
						</view>
					</view>
				</view>

				<view class="section-gap"></view>

				<!-- Section 1: 招聘专业 -->
				<view id="section-1" class="section-card">
					<text class="block-title">招聘专业</text>
					<view class="fields-list" v-if="enterprise.fields && enterprise.fields.length > 0">
						<view class="field-card" v-for="(field, idx) in enterprise.fields" :key="idx" @tap="onFieldTap(field.id)">
							<text class="field-name">{{ field.value }}</text>
							<view class="field-meta-row">
								<view class="field-meta-bar">
									<text class="field-type">{{ field.type }}</text>
									<view class="field-meta-divider"></view>
									<text class="field-stars-label">专业热门度:</text>
									<text class="star-icon" v-for="n in field.star" :key="n">★</text>
								</view>
								<view class="field-detail-link" @tap.stop="onFieldTap(field.id)">
									<text class="field-detail-text">详情</text>
									<text class="field-detail-arrow">›</text>
								</view>
							</view>
						</view>
					</view>
					<view v-else class="section-empty">
						<text class="empty-text">暂无招聘专业信息</text>
					</view>
				</view>

				<view class="section-gap"></view>

				<!-- Section 2: 深度解读 -->
				<view id="section-2" class="section-card">
					<text class="block-title">深度解读</text>
					<view class="articles-list" v-if="enterprise.article1 && enterprise.article1.length > 0">
						<view class="article-card" v-for="(art, idx) in enterprise.article1" :key="idx" @tap="onArticleTap(art.article)">
							<text class="article-title">{{ art.title || "未知标题" }}</text>
							<text v-if="art.description" class="article-desc">{{ art.description }}</text>
							<view class="article-footer">
								<view v-if="art.accountName" class="article-account">
									<image v-if="art.accountIcon" class="account-icon" :src="art.accountIcon" mode="aspectFill"/>
									<text class="account-name">{{ art.accountName }}</text>
								</view>
								<text class="article-time">发布时间: {{ formatArticleDate(art) }}</text>
							</view>
						</view>
					</view>
					<view v-else class="section-empty">
						<text class="empty-text">暂无深度解读文章</text>
					</view>
				</view>

				<view class="section-gap"></view>

				<!-- Section 3: 成功案例 (logic unchanged) -->
				<view id="section-3" class="section-card">
					<text class="block-title">成功案例</text>
					<view class="cases-wrapper">
						<view :class="['cases-list', { 'blur-content': !accountinfo }]">
							<view v-if="isCasesLoading" class="cases-loading">
								<text class="loading-text">加载中...</text>
							</view>
							<view v-else-if="cases.length === 0" class="section-empty">
								<text class="empty-text">暂无成功案例</text>
							</view>
							<view v-else class="case-card" v-for="(c, idx) in cases" :key="idx">
								<view class="case-header">
									<text class="student-name">{{ c.student || "" }}</text>
									<view class="student-target-col">
										<text class="target-entname">{{ c.entname || "" }}</text>
										<text class="target-position">{{ c.name }}</text>
									</view>
								</view>
								<view class="case-tags-row">
									<view class="case-tags-left">
										<view v-for="(tag, tIdx) in c.tags.filter((t) => t.trim() !== '')" :key="tIdx" :class="['case-tag-badge', `tag-color-${tIdx % 3}`]">
											<text class="case-tag-text">{{ tag }}</text>
										</view>
									</view>
									<text class="case-expand-toggle" @tap="toggleCaseExpand(idx)">
										{{ expandedCases[idx] ? "收起" : "展开" }}
									</text>
								</view>
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
											<text :class="['detail-value', { 'text-link': c.field1 }]" @tap="onFieldTapByName(c.field1)">
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
											<text :class="['detail-value', { 'text-link': c.field2 }]" @tap="onFieldTapByName(c.field2)">
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
						<view v-if="!accountinfo" class="login-overlay">
							<button open-type="getPhoneNumber" @getphonenumber="onGetPhoneNumber" class="login-btn">
								请先登录后查看
							</button>
						</view>
					</view>
				</view>
			</view>
		</view>
			</view>
		</scroll-view>

		<!-- Bottom Navigation Bar -->
		<view class="bottom-nav-bar">
			<view class="bottom-nav-inner">
				<view class="nav-item-home" @tap="goHome">
					<image class="nav-icon" :src="parseimage('底部按钮/首页-普通.png')" mode="aspectFit" />
					<text class="nav-item-label">首页</text>
				</view>
				<view class="nav-item-fav">
					<button v-if="!accountinfo" open-type="getPhoneNumber" @getphonenumber="onGetPhoneNumber" class="fav-btn-unlogged">
						<image class="nav-icon" :src="parseimage('底部按钮/收藏-普通.png')" mode="aspectFit" />
						<text class="nav-item-label">收藏</text>
					</button>
					<view v-else class="fav-btn-logged" @tap="toggleFavorite">
						<image
							class="nav-icon"
							:src="parseimage(isFavorited ? '底部按钮/收藏-选中.png' : '底部按钮/收藏-普通.png')"
							mode="aspectFit"
						/>
						<text class="nav-item-label" :class="{ 'nav-item-label-active': isFavorited }">{{ isFavorited ? "已收藏" : "收藏" }}</text>
					</view>
				</view>
				<view class="nav-actions-spacer" />
				<view class="nav-btn-consult" @tap="goConsult">
					<text class="nav-btn-consult-text">在线咨询</text>
				</view>
				<view class="nav-btn-phone" @tap="callPhone">
					<text class="nav-btn-phone-text">电话咨询</text>
				</view>
			</view>
		</view>

		<!-- Copy Success Modal -->
		<view v-if="showCopyModal" class="modal-mask" @tap="showCopyModal = false">
			<view class="modal-container" @tap.stop>
				<image class="modal-check-icon" :src="parseimage('底部按钮/打钩.png')" mode="aspectFit" />
				<text class="modal-title">链接已复制</text>
				<text class="modal-desc">立即咨询顾问老师，获取岗位信息，投递建议和专属资料吧！</text>
				<view class="modal-divider" />
				<view class="modal-buttons">
					<button class="modal-btn btn-later" @tap="showCopyModal = false">稍后查看</button>
					<button class="modal-btn btn-consult" @tap="onConsultTap">立即咨询</button>
				</view>
			</view>
		</view>

		<!-- Phone Call Confirm Modal -->
		<view v-if="showPhoneModal" class="modal-mask" @tap="closePhoneModal">
			<view class="phone-modal-container" @tap.stop>
				<text class="phone-modal-title">电话咨询</text>
				<view class="phone-modal-row">
					<image class="phone-modal-icon" :src="parseimage('底部按钮/电话.png')" mode="aspectFit" />
					<text class="phone-modal-number">{{ PHONE_NUMBER }}</text>
				</view>
				<view class="phone-modal-buttons">
					<button class="phone-modal-btn phone-btn-cancel" @tap="closePhoneModal">取消</button>
					<button class="phone-modal-btn phone-btn-dial" @tap="confirmPhoneCall">拨打</button>
				</view>
			</view>
		</view>
	</view>
</template>

<script setup lang="ts">
import { ref, computed, nextTick, watch } from "vue";
import { onLoad } from "@dcloudio/uni-app";

import { enterpriselist, accountinfo, caselist, fieldlist } from "../../tapah/data";
import { entfenyes } from "../../tapah/option";
import { RequestEnterpriseDetail, RequestCaseList, RequestWxCode, RequestUserInfo } from "../../tapah/request";
import { parseimage, parseEnterpriseIcon, navigator, stagStr, openOfficialAccountArticle, openExternalUrl, } from "../../tapah/function";
import type { Enterprise, Case, Article } from "../../tapah/class";

const SECTION_COUNT = 4;
const TAB_SCROLL_OFFSET = 96;

const initialized = ref(false);
const enterprise = ref<Enterprise | null>(null);
const swiperIndex = ref(0);
const fenyeindex = ref(0);
const isBriefExpanded = ref(false);
const expandedCases = ref<Record<number, boolean>>({});

const cases = ref<Case[]>([]);
const isCasesLoading = ref(true);

const sectionTops = ref<number[]>([]);
const isScrollingToSection = ref(false);
const showCopyModal = ref(false);
const showPhoneModal = ref(false);
const PHONE_NUMBER = "051281660895";
const pageScrollTop = ref(0);
const scrollTopCache = ref(0);
const scrollWithAnimation = ref(false);
const pageHeightPx = ref(667);

const detailScrollStyle = computed(() => ({
	height: `${pageHeightPx.value}px`,
}));

const refreshPageHeight = () => {
	try {
		pageHeightPx.value = uni.getSystemInfoSync().windowHeight;
	} catch {
		pageHeightPx.value = 667;
	}
};

const isFavorited = computed(() => {
	if (!accountinfo.value || !enterprise.value) return false;
	return accountinfo.value.enterprise.has(enterprise.value.id);
});

const needBriefToggle = computed(() => (enterprise.value?.brief?.length || 0) > 40);

watch(
	() => enterprise.value?.images,
	() => {
		bannerHeightPx.value = 0;
	},
);

const bannerHeightPx = ref(0);

const bannerSwiperStyle = computed(() => ({
	height: bannerHeightPx.value > 0 ? `${bannerHeightPx.value}px` : "1px",
}));

const onBannerImageLoad = (e: any) => {
	const { width, height } = e.detail || {};
	if (!width || !height) return;
	try {
		const sys = uni.getSystemInfoSync();
		const h = (sys.windowWidth * height) / width;
		if (h > bannerHeightPx.value) bannerHeightPx.value = h;
	} catch {
		const h = (750 * height) / width;
		if (h > bannerHeightPx.value) bannerHeightPx.value = h;
	}
};

const onSwiperChange = (e: any) => {
	swiperIndex.value = e.detail.current;
};

const toggleBrief = () => {
	isBriefExpanded.value = !isBriefExpanded.value;
	nextTick(() => setTimeout(calculateSectionTops, 100));
};

const toggleCaseExpand = (idx: number) => {
	expandedCases.value[idx] = !expandedCases.value[idx];
	nextTick(() => setTimeout(calculateSectionTops, 100));
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

const openWebsite = (url?: string) => {
	if (!url) return;
	openExternalUrl(url);
};

const copyWebsite = (url?: string) => {
	if (!url) return;
	uni.setClipboardData({
		data: url,
		success: () => {
			showCopyModal.value = true;
		},
	});
};

const onConsultTap = () => {
	showCopyModal.value = false;
	navigator("/kefu");
};

const formatArticleDate = (art: Article) => {
	const ts = art.publishTime || art.update;
	if (!ts) return "--";
	const d = new Date(ts * 1000);
	const y = d.getFullYear();
	const m = String(d.getMonth() + 1).padStart(2, "0");
	const day = String(d.getDate()).padStart(2, "0");
	return `${y}-${m}-${day}`;
};

const goHome = () => {
	navigator("/mainpage");
};

const goConsult = () => {
	navigator("/kefu");
};

const callPhone = () => {
	showPhoneModal.value = true;
};

const closePhoneModal = () => {
	showPhoneModal.value = false;
};

const confirmPhoneCall = () => {
	showPhoneModal.value = false;
	uni.makePhoneCall({ phoneNumber: PHONE_NUMBER });
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
			if (enterprise.value) loadCases();
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
		nextTick(() => setTimeout(calculateSectionTops, 300));
	}
};

const calculateSectionTops = () => {
	const query = uni.createSelectorQuery();
	query.select(".detail-scroll").boundingClientRect();
	for (let i = 0; i < SECTION_COUNT; i++) {
		query.select(`#section-${i}`).boundingClientRect();
	}
	query.exec((res) => {
		if (!res || res.length < SECTION_COUNT + 1) return;
		const scrollViewRect = res[0];
		if (!scrollViewRect) return;
		const tops: number[] = [];
		for (let i = 0; i < SECTION_COUNT; i++) {
			const rect = res[i + 1];
			tops.push(rect ? scrollTopCache.value + rect.top - scrollViewRect.top : 0);
		}
		sectionTops.value = tops;
	});
};

const scrollToSection = (index: number) => {
	isScrollingToSection.value = true;
	fenyeindex.value = index;
	const query = uni.createSelectorQuery();
	query.select(`#section-${index}`).boundingClientRect();
	query.select(".detail-scroll").boundingClientRect();
	query.exec((res) => {
		if (res && res[0] && res[1]) {
			const targetScrollTop = scrollTopCache.value + res[0].top - res[1].top - TAB_SCROLL_OFFSET;
			scrollWithAnimation.value = true;
			pageScrollTop.value = scrollTopCache.value;
			nextTick(() => {
				pageScrollTop.value = Math.max(0, targetScrollTop);
				setTimeout(() => {
					isScrollingToSection.value = false;
					scrollWithAnimation.value = false;
				}, 350);
			});
		} else {
			isScrollingToSection.value = false;
		}
	});
};

const onDetailScroll = (e: { detail: { scrollTop: number } }) => {
	scrollTopCache.value = e.detail.scrollTop;
	if (isScrollingToSection.value || sectionTops.value.length === 0) return;
	const scrollTop = e.detail.scrollTop;
	let activeIndex = 0;
	for (let i = 0; i < sectionTops.value.length; i++) {
		if (scrollTop >= sectionTops.value[i] - TAB_SCROLL_OFFSET) {
			activeIndex = i;
		}
	}
	fenyeindex.value = activeIndex;
};

watch(
	() => enterprise.value?.id,
	() => {
		nextTick(() => setTimeout(calculateSectionTops, 300));
	}
);

onLoad(async (options) => {
	refreshPageHeight();
	let enterpriseId = 0;
	if (options && options.enterprise) {
		enterpriseId = parseInt(options.enterprise, 10) || 0;
	}

	if (enterpriseId > 0) {
		const found = enterpriselist.value.find((e) => e.id === enterpriseId);
		if (found) {
			enterprise.value = found;
			initialized.value = true;
			loadCases();
		} else {
			try {
				enterprise.value = await RequestEnterpriseDetail(enterpriseId);
				initialized.value = true;
				loadCases();
			} catch (err) {
				console.error("Failed to load enterprise detail:", err);
				uni.showToast({ title: "加载失败", icon: "none" });
			}
		}
	}

	if (enterprise.value?.name) {
		uni.setNavigationBarTitle({ title: enterprise.value.name });
	}

	nextTick(() => setTimeout(calculateSectionTops, 400));
});
</script>

<style scoped>
.detail-root {
	width: 100%;
	height: 100vh;
	overflow: hidden;
	background-color: #f8f8f8;
}

.detail-scroll {
	width: 100%;
}

.detail-page {
	display: flex;
	flex-direction: column;
	width: 100%;
	background-color: #f8f8f8;
	padding-bottom: 132rpx;
	box-sizing: border-box;
}

.banner-wrap {
	position: relative;
	width: 100%;
}

.top-swiper {
	width: 100%;
}

.top-swiper swiper-item {
	height: 100%;
}

.banner-image {
	display: block;
	width: 100%;
}

.swiper-indicator {
	position: absolute;
	right: 64rpx;
	bottom: 20rpx;
	background-color: rgba(0, 0, 0, 0.5);
	padding: 8rpx 32rpx;
	border-radius: 40rpx;
}

.indicator-text {
	color: #ffffff;
	font-size: 40rpx;
}

.main-panel {
	margin-top: 0;
	background-color: #ffffff;
	border-radius: 20rpx 20rpx 0 0;
	overflow: hidden;
	position: relative;
	z-index: 1;
}

.sticky-tab-bar {
	position: sticky;
	top: 0;
	z-index: 100;
	background-color: #ffffff;
}

.tab-items-row {
	display: flex;
	flex-direction: row;
	align-items: flex-start;
	padding: 22rpx 64rpx 20rpx 64rpx;
	box-sizing: border-box;
}

.tab-item {
	display: flex;
	flex-direction: column;
	align-items: center;
	flex: 1;
}

.tab-text {
	font-size: 30rpx;
	line-height: 44rpx;
	font-weight: 350;
	color: #000000;
}

.tab-text-active {
	color: #5e80f7;
}

.tab-line {
	width: 100%;
	height: 6rpx;
	margin-top: 12rpx;
	background-color: transparent;
	border-radius: 4rpx;
}

.tab-line-active {
	background-color: #5e80f7;
}

.sections-inner {
	background-color: #f8f8f8;
	padding-bottom: 40rpx;
}

.section-card {
	background-color: #ffffff;
	border-radius: 20rpx;
	padding-bottom: 40rpx;
	box-sizing: border-box;
}

.section-gap {
	height: 30rpx;
	background-color: #f8f8f8;
}

.name-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	height: 128rpx;
	padding: 0 64rpx;
	box-sizing: border-box;
}

.name-marquee-col {
	flex: 1;
	min-width: 0;
	margin-right: 20rpx;
}

.enterprise-name-text {
	font-size: 44rpx;
	font-weight: 500;
	color: #000000;
	line-height: 64rpx;
	display: -webkit-box;
	-webkit-box-orient: vertical;
	-webkit-line-clamp: 2;
	overflow: hidden;
	word-break: break-all;
}

.enterprise-icon-wrap {
	width: 128rpx;
	height: 128rpx;
	flex-shrink: 0;
	background-color: #ffffff;
	border-radius: 10rpx;
	box-shadow:
		0 -2rpx 6rpx 0 rgba(0, 0, 0, 0.05),
		0 8rpx 8rpx 0 rgba(0, 0, 0, 0.1);
	overflow: hidden;
	display: flex;
	align-items: center;
	justify-content: center;
}

.enterprise-icon {
	width: 128rpx;
	height: 128rpx;
	flex-shrink: 0;
}

.location-row {
	display: inline-flex;
	flex-direction: row;
	align-items: center;
	margin-top: 10rpx;
	margin-left: 64rpx;
	padding: 6rpx 10rpx 6rpx 6rpx;
	background-color: #edf2f8;
	box-sizing: border-box;
}

.location-icon {
	width: 24rpx;
	height: 24rpx;
	flex-shrink: 0;
	margin-right: 6rpx;
}

.location-text {
	font-size: 20rpx;
	color: #666666;
}

.tags-scroll {
	width: 100%;
	margin-top: 10rpx;
	padding: 0 64rpx;
	box-sizing: border-box;
}

.tags-row {
	display: inline-flex;
	flex-direction: row;
	flex-wrap: nowrap;
	align-items: center;
	gap: 3rpx;
}

.tag-badge {
	display: inline-flex;
	align-items: center;
	justify-content: center;
	padding: 1rpx 3rpx;
	background-color: #fef5e6;
	border-radius: 6rpx;
	flex-shrink: 0;
}

.tag-text {
	font-size: 20rpx;
	line-height: 28rpx;
	font-weight: 400;
	color: #80500a;
	white-space: nowrap;
}

.brief-box {
	margin-top: 20rpx;
	padding: 0 64rpx;
}

.brief-content {
	position: relative;
}

.brief-desc {
	font-size: 28rpx;
	line-height: 48rpx;
	font-weight: 350;
	color: #000000;
	letter-spacing: 0.05em;
	word-break: break-word;
}

.brief-content-collapsed {
	max-height: 192rpx;
	overflow: hidden;
}

.brief-toggle-inline,
.brief-toggle-text {
	font-size: 28rpx;
	line-height: 48rpx;
	color: #5e80f7;
	font-weight: 350;
}

.brief-toggle-overlay {
	position: absolute;
	right: 0;
	bottom: 0;
	height: 48rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	padding-left: 72rpx;
	background: linear-gradient(90deg, rgba(255, 255, 255, 0) 0%, #ffffff 40%);
}

.brief-toggle-arrow {
	font-size: 28rpx;
	line-height: 48rpx;
	color: #5e80f7;
	margin-left: 4rpx;
}

.info-table {
	display: flex;
	flex-direction: column;
	margin-top: 20rpx;
	padding: 0 64rpx;
}

.table-row {
	display: flex;
	flex-direction: row;
	padding: 12rpx 0;
	align-items: flex-start;
}

.table-label {
	width: 140rpx;
	flex-shrink: 0;
	font-size: 30rpx;
	line-height: 44rpx;
	font-weight: 350;
	color: #6a727d;
}

.table-value {
	flex: 1;
	min-width: 0;
	font-size: 30rpx;
	line-height: 44rpx;
	font-weight: 350;
	color: #000000;
	word-break: break-all;
}

.table-link {
	color: #5e80f7;
	text-decoration: underline;
}

.table-copy {
	flex-shrink: 0;
	margin-left: 16rpx;
	font-size: 30rpx;
	line-height: 44rpx;
	font-weight: 350;
	color: #5e80f7;
}

.block-title {
	display: block;
	font-size: 40rpx;
	line-height: 58rpx;
	font-weight: 700;
	color: #000000;
	padding: 40rpx 64rpx 16rpx 64rpx;
}

.fields-list {
	display: flex;
	flex-direction: column;
	padding: 0 64rpx;
	gap: 4rpx;
}

.field-card {
	min-height: 134rpx;
	border: 1rpx solid #e7e7e7;
	border-radius: 10rpx;
	padding: 16rpx 0;
	box-sizing: border-box;
	display: flex;
	flex-direction: column;
	justify-content: center;
}

.field-name {
	font-size: 34rpx;
	line-height: 50rpx;
	font-weight: 350;
	color: #000000;
	padding-left: 30rpx;
}

.field-meta-row {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-top: 10rpx;
	margin-left: 30rpx;
	margin-right: 30rpx;
}

.field-meta-bar {
	display: inline-flex;
	flex-direction: row;
	align-items: center;
	padding: 4rpx 20rpx;
	background-color: #f6f6fa;
	border-radius: 8rpx;
	box-sizing: border-box;
	flex-shrink: 0;
}

.field-type {
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 400;
	color: #394156;
	flex-shrink: 0;
}

.field-meta-divider {
	width: 1rpx;
	height: 24rpx;
	background-color: #d9d9d9;
	margin: 0 20rpx;
	flex-shrink: 0;
}

.field-stars-label {
	font-size: 24rpx;
	line-height: 28rpx;
	font-weight: 400;
	color: #000000;
	flex-shrink: 0;
}

.star-icon {
	color: #ff9800;
	font-size: 24rpx;
	line-height: 28rpx;
	margin-right: 4rpx;
}

.field-detail-link {
	display: flex;
	flex-direction: row;
	align-items: center;
	margin-left: auto;
	flex-shrink: 0;
}

.field-detail-text {
	font-size: 26rpx;
	line-height: 38rpx;
	font-weight: 350;
	color: #5e80f7;
}

.field-detail-arrow {
	font-size: 26rpx;
	line-height: 38rpx;
	color: #5e80f7;
	margin-left: 4rpx;
}

.articles-list {
	display: flex;
	flex-direction: column;
	padding: 0 64rpx;
	gap: 24rpx;
}

.article-card {
	background-color: #ffffff;
	border-radius: 20rpx;
	padding: 32rpx;
	border: 1rpx solid #eeeeee;
	box-sizing: border-box;
}

.article-title {
	font-size: 28rpx;
	font-weight: 700;
	color: #333333;
	line-height: 1.4;
	margin-bottom: 8rpx;
	display: -webkit-box;
	-webkit-box-orient: vertical;
	-webkit-line-clamp: 2;
	overflow: hidden;
}

.article-desc {
	font-size: 24rpx;
	color: #666666;
	line-height: 1.4;
	display: -webkit-box;
	-webkit-box-orient: vertical;
	-webkit-line-clamp: 2;
	overflow: hidden;
}

.article-footer {
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: space-between;
	margin-top: 24rpx;
}

.article-account {
	display: flex;
	flex-direction: row;
	align-items: center;
	flex: 1;
	min-width: 0;
}

.account-icon {
	width: 40rpx;
	height: 40rpx;
	border-radius: 50%;
	flex-shrink: 0;
	margin-right: 12rpx;
}

.account-name {
	font-size: 20rpx;
	line-height: 30rpx;
	font-weight: 400;
	color: #000000;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}

.article-time {
	font-size: 20rpx;
	line-height: 30rpx;
	font-weight: 350;
	color: #818181;
	flex-shrink: 0;
	margin-left: auto;
}

.cases-wrapper {
	position: relative;
	width: 100%;
	padding: 0 64rpx;
	box-sizing: border-box;
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
	border-radius: 10rpx;
	padding: 20rpx;
	margin-bottom: 20rpx;
	border: 1rpx solid #eeeeee;
	box-sizing: border-box;
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
	color: #5e80f7;
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

.tag-color-0 { background-color: #e8f0fe; }
.tag-color-0 .case-tag-text { color: #5e80f7; }
.tag-color-1 { background-color: #feeddf; }
.tag-color-1 .case-tag-text { color: #692e1f; }
.tag-color-2 { background-color: #f3eeff; }
.tag-color-2 .case-tag-text { color: #6b21a8; }

.case-tag-text {
	font-size: 22rpx;
}

.case-expand-toggle {
	font-size: 24rpx;
	color: #5e80f7;
	margin-left: 20rpx;
	flex-shrink: 0;
}

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
	background-color: #5e80f7;
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

.text-link {
	color: #5e80f7;
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

.section-empty {
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 40rpx 0;
}

.empty-text,
.loading-text {
	font-size: 28rpx;
	color: #888888;
}

.bottom-nav-bar {
	position: fixed;
	left: 0;
	right: 0;
	bottom: 0;
	background-color: #ffffff;
	border-radius: 30rpx 30rpx 0 0;
	box-shadow: 0 8rpx 32rpx 0 rgba(0, 0, 0, 0.16);
	box-sizing: border-box;
	z-index: 200;
}

.bottom-nav-inner {
	height: 132rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	padding-left: 64rpx;
	padding-right: 32rpx;
	box-sizing: border-box;
}

.nav-item-home,
.nav-item-fav {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
}

.nav-item-home {
	margin-right: 64rpx;
}

.nav-icon {
	width: 52rpx;
	height: 52rpx;
}

.nav-item-label {
	margin-top: 4rpx;
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 400;
	color: #3d3d3d;
}

.nav-item-label-active {
	color: #4f79fe;
}

.nav-actions-spacer {
	flex: 1;
	min-width: 16rpx;
}

.fav-btn-unlogged {
	background: none;
	border: none;
	padding: 0;
	margin: 0;
	line-height: 1;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.fav-btn-unlogged::after {
	border: none;
}

.fav-btn-logged {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.nav-btn-consult,
.nav-btn-phone {
	width: 200rpx;
	height: 86rpx;
	border-radius: 10rpx;
	display: flex;
	align-items: center;
	justify-content: center;
	flex-shrink: 0;
}

.nav-btn-consult {
	background-color: #5e80f7;
	margin-right: 36rpx;
}

.nav-btn-consult-text {
	color: #ffffff;
	font-size: 34rpx;
	line-height: 50rpx;
	font-weight: 500;
}

.nav-btn-phone {
	background-color: #f3ad2b;
}

.nav-btn-phone-text {
	color: #ffffff;
	font-size: 34rpx;
	line-height: 50rpx;
	font-weight: 500;
}

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
	height: 770rpx;
	background-color: #ffffff;
	border-radius: 20rpx;
	box-shadow:
		0 4rpx 8rpx 0 rgba(0, 0, 0, 0.02),
		0 2rpx 4rpx 0 rgba(0, 0, 0, 0.03);
	display: flex;
	flex-direction: column;
	align-items: center;
	box-sizing: border-box;
}

.modal-check-icon {
	width: 156rpx;
	height: 156rpx;
	margin-top: 98rpx;
	flex-shrink: 0;
}

.modal-title {
	margin-top: 56rpx;
	font-size: 44rpx;
	line-height: 64rpx;
	font-weight: 700;
	color: #000000;
}

.modal-desc {
	margin-top: 40rpx;
	width: 438rpx;
	font-size: 28rpx;
	line-height: 40rpx;
	font-weight: 300;
	color: #3d3d3d;
	text-align: center;
}

.modal-divider {
	margin-top: 54rpx;
	width: 486rpx;
	height: 2rpx;
	background-color: #e6e6e6;
	flex-shrink: 0;
}

.modal-buttons {
	margin-top: 60rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	gap: 50rpx;
}

.modal-btn {
	width: 220rpx;
	height: 80rpx;
	border-radius: 10rpx;
	font-size: 24rpx;
	line-height: 34rpx;
	font-weight: 500;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 0;
	margin: 0;
	box-sizing: border-box;
}

.modal-btn::after {
	border: none;
}

.btn-later {
	background-color: #ffffff;
	color: #333333;
	border: 2rpx solid #b2b5bc;
}

.btn-consult {
	background-color: #2d7bff;
	color: #ffffff;
	border: none;
}

.phone-modal-container {
	width: 560rpx;
	height: 314rpx;
	background-color: #ffffff;
	box-shadow:
		0 4rpx 8rpx 0 rgba(0, 0, 0, 0.02),
		0 2rpx 4rpx 0 rgba(0, 0, 0, 0.03);
	display: flex;
	flex-direction: column;
	align-items: center;
	box-sizing: border-box;
	padding-top: 32rpx;
}

.phone-modal-title {
	font-size: 44rpx;
	line-height: 64rpx;
	font-weight: 500;
	color: #000000;
}

.phone-modal-row {
	margin-top: 26rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	gap: 16rpx;
}

.phone-modal-icon {
	width: 52rpx;
	height: 52rpx;
	flex-shrink: 0;
}

.phone-modal-number {
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 500;
	color: #000000;
}

.phone-modal-buttons {
	margin-top: 38rpx;
	display: flex;
	flex-direction: row;
	align-items: center;
	justify-content: center;
	gap: 48rpx;
}

.phone-modal-btn {
	width: 224rpx;
	height: 64rpx;
	border-radius: 10rpx;
	font-size: 32rpx;
	line-height: 46rpx;
	font-weight: 500;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: 0;
	margin: 0;
	box-sizing: border-box;
}

.phone-modal-btn::after {
	border: none;
}

.phone-btn-cancel {
	background-color: #ffffff;
	color: #333333;
	border: 2rpx solid #b3b3b3;
}

.phone-btn-dial {
	background-color: #2d7bff;
	color: #ffffff;
	border: none;
}
</style>
