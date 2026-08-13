import { ref } from "vue";
import { Zone, Sector, Level, Field, Enterprise, Case, Article, AccountInfo } from "./class";

export const zonelist = ref<Zone[]>([]);
export const sectorlist = ref<Sector[]>([]);
export const levellist = ref<Level[]>([]);
export const fieldlist = ref<Field[]>([]);
export const myfieldlist = ref<Field[]>([]);
export const enterpriselist = ref<Enterprise[]>([]);
export const myenterpriselist = ref<Enterprise[]>([]);
export const caselist = ref<Case[]>([]);
export const article1 = ref<Article[]>([]);
export const article2 = ref<Article[]>([]);

export const accountinfo = ref<AccountInfo | null>(null);

export const chataiToken = ref<string | null>(null);
export const chataiTokenExpiresAt = ref<number | null>(null);
export const chataiConversationId = ref<string | null>(null);
export const chataiAgent = ref<string>("resume");

export interface EnterpriseFilterState {
	zones: number[];
	levels: number[];
	sectors: number[];
	search: string;
	zoneUnlimited: boolean;
	levelUnlimited: boolean;
	sectorUnlimited: boolean;
}

export const enterpriseFilterState = ref<EnterpriseFilterState>({
	zones: [],
	levels: [],
	sectors: [],
	search: "",
	zoneUnlimited: true,
	levelUnlimited: true,
	sectorUnlimited: true,
});

export function syncEnterpriseFilterState(
	zones: number[],
	levels: number[],
	sectors: number[],
	search: string,
	unlimited?: Pick<EnterpriseFilterState, "zoneUnlimited" | "levelUnlimited" | "sectorUnlimited">,
) {
	enterpriseFilterState.value = {
		zones: [...zones],
		levels: [...levels],
		sectors: [...sectors],
		search,
		zoneUnlimited: unlimited?.zoneUnlimited ?? zones.length === 0,
		levelUnlimited: unlimited?.levelUnlimited ?? levels.length === 0,
		sectorUnlimited: unlimited?.sectorUnlimited ?? sectors.length === 0,
	};
}
