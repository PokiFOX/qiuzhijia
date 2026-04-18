final List<String> imageurls = [
	'儿童底图.png',
	'成人底图.png',
	'老年底图.png',
];
final topimageduration = 3;

class LanMuInfo {
	final String title;
	final String image;
	LanMuInfo({required this.title, required this.image});
}
final List<LanMuInfo> lanmus = [
	LanMuInfo(title: '招聘企业', image: 'HOME栏目/招聘企业.png'),
	LanMuInfo(title: '招聘专业', image: 'HOME栏目/招聘专业.png'),
	LanMuInfo(title: '简历匹配', image: 'HOME栏目/简历匹配.png'),
	LanMuInfo(title: '过往案例', image: 'HOME栏目/过往案例.png'),
	LanMuInfo(title: '讲座直播', image: 'HOME栏目/讲座直播.png'),
	LanMuInfo(title: '咨询顾问', image: 'HOME栏目/咨询顾问.png'),
	LanMuInfo(title: '求职资料', image: 'HOME栏目/求职资料.png'),
	LanMuInfo(title: '实习内推', image: 'HOME栏目/实习内推.png'),
	LanMuInfo(title: '岗位内推', image: 'HOME栏目/岗位内推.png'),
	LanMuInfo(title: '笔试题库', image: 'HOME栏目/笔试题库.png'),
	LanMuInfo(title: '面试经验', image: 'HOME栏目/面试经验.png'),
	LanMuInfo(title: '求职服务', image: 'HOME栏目/求职服务.png'),
];

class FenYeInfo {
	final String title;
	FenYeInfo({required this.title,});
}

List<FenYeInfo> fenyes = [
	FenYeInfo(title: "推荐"),
	FenYeInfo(title: "招聘动态"),
	FenYeInfo(title: "笔面试经验"),
	FenYeInfo(title: "求职解析"),
	FenYeInfo(title: "求职家服务"),
];

List<String> entfenyes = ["公司简介", "招聘专业", "深度解读", "成功案例"];
