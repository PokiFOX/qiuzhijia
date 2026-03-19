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
	LanMuInfo(title: '招聘企业', image: '招聘企业.png'),
	LanMuInfo(title: '招聘专业', image: '招聘专业.png'),
	LanMuInfo(title: '简历匹配', image: '简历匹配.png'),
	LanMuInfo(title: '过往案例', image: '过往案例.png'),
	LanMuInfo(title: '讲座直播', image: '讲座直播.png'),
	LanMuInfo(title: '咨询顾问', image: '咨询顾问.png'),
	LanMuInfo(title: '求职资料', image: '求职资料.png'),
	LanMuInfo(title: '实习内推', image: '实习内推.png'),
	LanMuInfo(title: '岗位内推', image: '岗位内推.png'),
	LanMuInfo(title: '笔试题库', image: '笔试题库.png'),
	LanMuInfo(title: '面试经验', image: '面试经验.png'),
	LanMuInfo(title: '求职服务', image: '求职服务.png'),
];

class FenYeInfo {
	final String title;
	final String normal;
	final String selected;
	FenYeInfo({required this.title, required this.normal, required this.selected});
}

List<FenYeInfo> fenyes = [
	FenYeInfo(title: "推荐", normal: "推荐-普通.png", selected: "推荐-选中.png"),
	FenYeInfo(title: "招聘动态", normal: "招聘动态-普通.png", selected: "招聘动态-选中.png"),
	FenYeInfo(title: "笔面试经验", normal: "笔面试经验-普通.png", selected: "笔面试经验-选中.png"),
	FenYeInfo(title: "求职解析", normal: "求职解析-普通.png", selected: "求职解析-选中.png"),
	FenYeInfo(title: "求职家服务", normal: "求职家服务-普通.png", selected: "求职家服务-选中.png"),
];

List<String> entfenyes = ["企业简介", "招聘专业", "深度解读", "招聘资讯", "成功案例"];
