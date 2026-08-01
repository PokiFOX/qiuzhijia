export const imageurls: string[] = [
	"轮播1.png",
	"轮播2.png",
	"轮播3.png",
];

export const topimageduration = 3;

export class LanMuInfo {
	title: string;
	image: string;
	constructor({ title, image }: { title: string; image: string }) {
		this.title = title;
		this.image = image;
	}
}

export const lanmus: LanMuInfo[] = [
	new LanMuInfo({ title: "招聘企业", image: "HOME栏目/招聘企业.png" }),
	new LanMuInfo({ title: "招聘专业", image: "HOME栏目/招聘专业.png" }),
	new LanMuInfo({ title: "求职课程", image: "HOME栏目/简历匹配.png" }),
	new LanMuInfo({ title: "过往案例", image: "HOME栏目/过往案例.png" }),
	new LanMuInfo({ title: "AI助手", image: "HOME栏目/AI助手.png" }),
	new LanMuInfo({ title: "求职资料", image: "HOME栏目/求职资料.png" }),
	new LanMuInfo({ title: "实习内推", image: "HOME栏目/实习内推.png" }),
	new LanMuInfo({ title: "岗位内推", image: "HOME栏目/岗位内推.png" }),
	new LanMuInfo({ title: "咨询顾问", image: "HOME栏目/咨询顾问.png" }),
	new LanMuInfo({ title: "笔试题库", image: "HOME栏目/笔试题库.png" }),
	new LanMuInfo({ title: "面试经验", image: "HOME栏目/面试经验.png" }),
	new LanMuInfo({ title: "求职服务", image: "HOME栏目/求职服务.png" }),
];

export class FenYeInfo {
	title: string;
	constructor({ title }: { title: string }) {
		this.title = title;
	}
}

export const fenyes: FenYeInfo[] = [
	new FenYeInfo({ title: "推荐" }),
	new FenYeInfo({ title: "求职解析" }),
	new FenYeInfo({ title: "求职家服务" }),
];

export const entfenyes: string[] = ["公司简介", "招聘专业", "深度解读", "成功案例"];
