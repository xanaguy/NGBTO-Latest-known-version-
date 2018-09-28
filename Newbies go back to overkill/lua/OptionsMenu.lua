if not _G.NoobJoin then
	_G.NoobJoin = _G.NoobJoin or {}
	NoobJoin._path = ModPath
	NoobJoin._data_path = SavePath .. "newbies_go_back_to_overkill.txt"
	NoobJoin.settings = {
		kickhidden_val = false,
		min_hours_loud_dw_val = 6,
		min_hours_stealth_dw_val = 7,
		min_hours_loud_ovk_val = 4,
		min_hours_stealth_ovk_val = 6,
		min_hours_loud_sm_wish_val = 10,
		min_hours_stealth_sm_wish_val = 10,
		min_hours_loud_easy_wish_val = 7,
		min_hours_stealth_ovk_val = 8,
		Toggle = 1,
		localised_message = false,
		broadcastinfo_val = true,
		perkdeck0_val = false,
		perkdeck_1_val = false,
		perkdeck_2_val = false,
		perkdeck_3_val = false,
		perkdeck_4_val = false,
		perkdeck_5_val = false,
		perkdeck_6_val = false,
		perkdeck_7_val = false,
		perkdeck_8_val = false,
		perkdeck_9_val = false,
		perkdeck_10_val = false,
		perkdeck_11_val = false,
		perkdeck_12_val = false,
		perkdeck_13_val = false,
		perkdeck_14_val = false,
		perkdeck_15_val = false,
		perkdeck_16_val = false,
		perkdeck_17_val = false,
		perkdeck_18_val = false,
		perkdeck_19_val = false,
		perkdeck_20_val = false,
		show_perks_info_val = true,
		hiddeninfamycheck = false,
		hiddeninfamy = 2,
		hiddeninfamymax = 26,
		noequipment = false,
		singleturret = false,
		bodybags = false,
		armorkit = false,
		singleecm = false,
		fourfaks = false,
		armor1 = false,
		armor2 = false,
		armor3 = false,
		armor4 = false,
		armor5 = false,
		armor6 = false,
		armor7 = false,
		incompletedeck = false,
		hiddenxxv = false,
		hiddenv = false,
		usepd2statsanticheat = true,
		tag_not_enough_heists_completed = false,
		deathwish_count_enable = false,
		deathwish_count = 1,
		total_count_enable = false,
		total_count = 1,
		Noob_language = 1,
		Stats_Print = true,
		ingame_anticheat = true,
		skills_detailed = false,
		skill_cheats = true,
		message = 1,
		kick_type = true,
		Infamy_check = false,
		remove_type = 1,
		Infamy_check_10 = 1,
		Infamy_check_15 = 1,
		Infamy_check_20 = 1,
		Infamy_check_24 = 1,
		Infamy_check_25 = 1,
		achievements_check = false,
		detection_loud = false,
		detection_loud_value = 15,
		detection_stealth = false,
		detection_stealth_value = 1,
		ammo_bag = false,
		doctor_bag = false,
		trip_mine = false,
		first_aid_kit = false,
		}
	NoobJoin.Name = "NGBTO"
	NoobJoin.Prefix = "[" .. NoobJoin.Name .. "]"
	NoobJoin.Update_message = {
		"Changelog:",
		"Updated at 01-09-2017",
		"BLT 2 SupportBLT 2 Support",
		"Fixed error print due to json files",
	}
	NoobJoin.Needed_message = 76
	NoobJoin.Players = {}
	local num_player_slots = BigLobbyGlobals and BigLobbyGlobals:num_player_slots() or 4
	for i=1,num_player_slots do -- peer info
		NoobJoin.Players[i] = {}
		for j=1,9 do -- Skills printed, pd2stats, skills overlay, join time, playtime, achievements, detection, cheater,
			NoobJoin.Players[i][j] = 0
		end
	end
	NoobJoin.Colors = {"ff0000", "00ff04", "1a64f6"} -- RGB
	NoobJoin.blacklist = {}
	NoobJoin.synced = {}
	 NoobJoin.Kick_on_join = {}
	NoobJoin.Blacklist_name = "blacklist.ini"
	-- Populate blacklist with steam ids
	-- old blacklist
	local file, err = io.open(NoobJoin._path .. NoobJoin.Blacklist_name, "r")
	if file then
		for line in file:lines() do
			if string.sub(line, 1,1) ~= ";" then
				table.insert(NoobJoin.blacklist, line)
			end
		end
	file:close()
	end
	-- new blacklist
	local file, err = io.open(NoobJoin.Blacklist_name, "r")
	if file then
		for line in file:lines() do
			if string.sub(line, 1,1) ~= ";" then
				table.insert(NoobJoin.blacklist, line)
			end
		end
	end
	if not file then
		file = io.open(NoobJoin.Blacklist_name, "w")
	end
	file:close()
	-- dr_newbie's blacklist
	local file1, err = io.open("kicklist.ini", "r")
	if file1 then
		for line in file1:lines() do
			table.insert(NoobJoin.blacklist, line)
		end
		file1:close()
	end
end

function NoobJoin:Load()
	local file = io.open(NoobJoin._data_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all")) or {}) do
			NoobJoin.settings[k] = v
		end
		file:close()
	end
end

function NoobJoin:Save()
	local file = io.open(NoobJoin._data_path, "w+")
	if file then
		file:write(json.encode(NoobJoin.settings))
		file:close()
	end
end

-- Load selected localization
local mpath=ModPath .. "loc/"
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_NoobJoinInitial", function(loc)
	loc:load_localization_file(mpath.."initial.json")
	loc:load_localization_file(mpath.."english.json")
end)
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_NoobJoin", function(loc)
	NoobJoin:Load()
	local path
	if NoobJoin.settings.Noob_language == 1 then
		path="english"
	elseif NoobJoin.settings.Noob_language == 2 then
		path="french"
	elseif NoobJoin.settings.Noob_language == 3 then
		path="russian"
	elseif NoobJoin.settings.Noob_language == 4 then
		path="german"
	elseif NoobJoin.settings.Noob_language == 5 then
		path="italian"
	elseif NoobJoin.settings.Noob_language == 6 then
		path="dutch"
	elseif NoobJoin.settings.Noob_language == 7 then
		path="spanish"
	elseif NoobJoin.settings.Noob_language == 8 then
		path="turkish"
	elseif NoobJoin.settings.Noob_language == 9 then
		path="chinese"
	elseif NoobJoin.settings.Noob_language == 10 then
		path="czech"
	elseif NoobJoin.settings.Noob_language == 11 then
		path="thai"
	end
	loc:load_localization_file(mpath..path .. ".json")
end)

-- Menu create
Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_NoobJoin", function(menu_manager)
	MenuCallbackHandler.Toggle = function(self)
		MenuCallbackHandler:Self_Inspect()
	end

	MenuCallbackHandler.SkillInfo = function(self)
		MenuCallbackHandler:Skill_Show()
	end

	MenuCallbackHandler.ManualBan = function(self)
		MenuCallbackHandler:Manual_banning()
	end

	MenuCallbackHandler.PlayerInspect = function(self)
		MenuCallbackHandler:Player_inspection_menu()
	end

	--Main menu
	MenuCallbackHandler.ngbto_language_callback = function(this, item)
		NoobJoin.settings.Noob_language = item:value()
	end

	--Information
	MenuCallbackHandler.ngbto_broadcast_callback = function(this, item)
		NoobJoin.settings.broadcastinfo_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_show_skills_callback = function(this, item)
		NoobJoin.settings.show_perks_info_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_detailed_skills_callback = function(this, item)
		NoobJoin.settings.skills_detailed = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_statistics_callback = function(this, item)
		NoobJoin.settings.Stats_Print = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_remove_type_callback = function(this, item)
		NoobJoin.settings.remove_type = item:value()
	end
	MenuCallbackHandler.ngbto_kick_type_callback = function(this, item)
		NoobJoin.settings.kick_type = Utils:ToggleItemToBoolean(item)
	end

	-- Anti-cheat
	MenuCallbackHandler.ngbto_pd2stats_callback = function(this, item)
		NoobJoin.settings.usepd2statsanticheat = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_pd2stats_extra_callback = function(this, item)
		NoobJoin.settings.tag_not_enough_heists_completed = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_skill_cheats_callback = function(this, item)
		NoobJoin.settings.skill_cheats = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_ingame_anticheat_callback = function(this, item)
		NoobJoin.settings.ingame_anticheat = Utils:ToggleItemToBoolean(item)
	end

	--Hour Filters
	
	MenuCallbackHandler.ngbto_one_down_loud_callback = function(this, item)
		NoobJoin.settings.min_hours_loud_sm_wish_val = item:value()
	end
	MenuCallbackHandler.ngbto_one_down_stealth_callback = function(this, item)
		NoobJoin.settings.min_hours_stealth_sm_wish_val = item:value()
	end
	MenuCallbackHandler.ngbto_mayhem_loud_callback = function(this, item)
		NoobJoin.settings.min_hours_loud_easy_wish_val = item:value()
	end
	MenuCallbackHandler.ngbto_mayhem_stealth_callback = function(this, item)
		NoobJoin.settings.min_hours_stealth_easy_wish_val = item:value()
	end
	
	MenuCallbackHandler.ngbto_deathwish_loud_callback = function(this, item)
		NoobJoin.settings.min_hours_loud_dw_val = item:value()
	end
	MenuCallbackHandler.ngbto_deathwish_stealth_callback = function(this, item)
		NoobJoin.settings.min_hours_stealth_dw_val = item:value()
	end
	MenuCallbackHandler.ngbto_overkill_loud_callback = function(this, item)
		NoobJoin.settings.min_hours_loud_ovk_val = item:value()
	end
	MenuCallbackHandler.ngbto_overkill_stealth_callback = function(this, item)
		NoobJoin.settings.min_hours_stealth_ovk_val = item:value()
	end
	MenuCallbackHandler.ngbto_total_heists_callback = function(this, item)
		NoobJoin.settings.total_count_enable = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_deathwish_heists_callback = function(this, item)
		NoobJoin.settings.deathwish_count_enable = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_total_heists_number_callback = function(this, item)
		NoobJoin.settings.total_count = item:value()
	end
	MenuCallbackHandler.ngbto_deathwish_heists_number_callback = function(this, item)
		NoobJoin.settings.deathwish_count = item:value()
	end

	--Hidden filters
	MenuCallbackHandler.ngbto_hidden_master_callback = function(this, item)
		NoobJoin.settings.kickhidden_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_hidden_infamy_callback = function(this, item)
		NoobJoin.settings.hiddeninfamycheck = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_hidden_infamy_minimum_callback = function(this, item)
		NoobJoin.settings.hiddeninfamy = item:value()
	end
	MenuCallbackHandler.ngbto_hidden_infamy_maximum_callback = function(this, item)
		NoobJoin.settings.hiddeninfamymax = item:value()
	end
	MenuCallbackHandler.ngbto_hidden_infamy_v_callback = function(this, item)
		NoobJoin.settings.hiddenv = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_hidden_infamy_xxv_callback = function(this, item)
		NoobJoin.settings.hiddenxxv = Utils:ToggleItemToBoolean(item)
	end

	--Perk decks
	MenuCallbackHandler.ngbto_incomplete_perk_deck_callback = function(this, item)
		NoobJoin.settings.incompletedeck = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_empty_perk_deck_callback = function(this, item)
		NoobJoin.settings.perkdeck0_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_1_callback = function(this, item)
		NoobJoin.settings.perkdeck_1_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_2_callback = function(this, item)
		NoobJoin.settings.perkdeck_2_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_3_callback = function(this, item)
		NoobJoin.settings.perkdeck_3_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_4_callback = function(this, item)
		NoobJoin.settings.perkdeck_4_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_5_callback = function(this, item)
		NoobJoin.settings.perkdeck_5_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_6_callback = function(this, item)
		NoobJoin.settings.perkdeck_6_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_7_callback = function(this, item)
		NoobJoin.settings.perkdeck_7_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_8_callback = function(this, item)
		NoobJoin.settings.perkdeck_8_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_9_callback = function(this, item)
		NoobJoin.settings.perkdeck_9_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_10_callback = function(this, item)
		NoobJoin.settings.perkdeck_10_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_11_callback = function(this, item)
		NoobJoin.settings.perkdeck_11_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_12_callback = function(this, item)
		NoobJoin.settings.perkdeck_12_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_13_callback = function(this, item)
		NoobJoin.settings.perkdeck_13_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_14_callback = function(this, item)
		NoobJoin.settings.perkdeck_14_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_15_callback = function(this, item)
		NoobJoin.settings.perkdeck_15_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_16_callback = function(this, item)
		NoobJoin.settings.perkdeck_16_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_17_callback = function(this, item)
		NoobJoin.settings.perkdeck_17_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_18_callback = function(this, item)
		NoobJoin.settings.perkdeck_18_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_19_callback = function(this, item)
		NoobJoin.settings.perkdeck_19_val = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_perk_deck_20_callback = function(this, item)
		NoobJoin.settings.perkdeck_20_val = Utils:ToggleItemToBoolean(item)
	end
	
	--Deployables filters
	MenuCallbackHandler.ngbto_no_deployable_callback = function(this, item)
		NoobJoin.settings.noequipment = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_four_first_aid_kits_callback = function(this, item)
		NoobJoin.settings.fourfaks = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_single_turret_callback = function(this, item)
		NoobJoin.settings.singleturret = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_body_bags_callback = function(this, item)
		NoobJoin.settings.bodybags = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_armor_kit_callback = function(this, item)
		NoobJoin.settings.armorkit = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_single_ecm_callback = function(this, item)
		NoobJoin.settings.singleecm = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_ammo_bag_callback = function(this, item)
		NoobJoin.settings.ammo_bag = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_doctor_bag_callback = function(this, item)
		NoobJoin.settings.doctor_bag = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_trip_mine_callback = function(this, item)
		NoobJoin.settings.trip_mine = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_first_aid_kit_callback = function(this, item)
		NoobJoin.settings.first_aid_kit = Utils:ToggleItemToBoolean(item)
	end

	--Armor
	MenuCallbackHandler.ngbto_armor_1_callback = function(this, item)
		NoobJoin.settings.armor1 = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_armor_2_callback = function(this, item)
		NoobJoin.settings.armor2 = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_armor_3_callback = function(this, item)
		NoobJoin.settings.armor3 = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_armor_4_callback = function(this, item)
		NoobJoin.settings.armor4 = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_armor_5_callback = function(this, item)
		NoobJoin.settings.armor5 = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_armor_6_callback = function(this, item)
		NoobJoin.settings.armor6 = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_armor_7_callback = function(this, item)
		NoobJoin.settings.armor7 = Utils:ToggleItemToBoolean(item)
	end

	--Misc
	MenuCallbackHandler.ngbto_detection_loud_callback = function(this, item)
		NoobJoin.settings.detection_loud = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_detection_loud_value_callback = function(this, item)
		NoobJoin.settings.detection_loud_value = item:value()
	end
	MenuCallbackHandler.ngbto_detection_stealth_callback = function(this, item)
		NoobJoin.settings.detection_stealth = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.ngbto_detection_stealth_value_callback = function(this, item)
		NoobJoin.settings.detection_stealth_value = item:value()
	end
	MenuCallbackHandler.achievements_check_callback = function(this, item)
		NoobJoin.settings.achievements_check = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.Infamy_check_callback = function(this, item)
		NoobJoin.settings.Infamy_check = Utils:ToggleItemToBoolean(item)
	end
	MenuCallbackHandler.Infamy_check_10_callback = function(this, item)
		NoobJoin.settings.Infamy_check_10 = item:value()
	end
	MenuCallbackHandler.Infamy_check_15_callback = function(this, item)
		NoobJoin.settings.Infamy_check_15 = item:value()
	end
	MenuCallbackHandler.Infamy_check_20_callback = function(this, item)
		NoobJoin.settings.Infamy_check_20 = item:value()
	end
	MenuCallbackHandler.Infamy_check_24_callback = function(this, item)
		NoobJoin.settings.Infamy_check_24 = item:value()
	end
	MenuCallbackHandler.Infamy_check_25_callback = function(this, item)
		NoobJoin.settings.Infamy_check_25 = item:value()
	end
	MenuCallbackHandler.ngbto_menu = function(this, item)
		NoobJoin:Save()
	end
	NoobJoin:Load()
	--Submenus
	MenuHelper:LoadFromJsonFile(NoobJoin._path .. "menu/main.json", NoobJoin, NoobJoin.settings)
	MenuHelper:LoadFromJsonFile(NoobJoin._path .. "menu/extras.json", NoobJoin, NoobJoin.settings)
	MenuHelper:LoadFromJsonFile(NoobJoin._path .. "menu/anti_cheat.json", NoobJoin, NoobJoin.settings)
	MenuHelper:LoadFromJsonFile(NoobJoin._path .. "menu/data_filters.json", NoobJoin, NoobJoin.settings)
	MenuHelper:LoadFromJsonFile(NoobJoin._path .. "menu/hidden.json", NoobJoin, NoobJoin.settings)
	MenuHelper:LoadFromJsonFile(NoobJoin._path .. "menu/perk_decks.json", NoobJoin, NoobJoin.settings)
	MenuHelper:LoadFromJsonFile(NoobJoin._path .. "menu/deployables.json", NoobJoin, NoobJoin.settings)
	MenuHelper:LoadFromJsonFile(NoobJoin._path .. "menu/armor.json", NoobJoin, NoobJoin.settings)
	MenuHelper:LoadFromJsonFile(NoobJoin._path .. "menu/misc.json", NoobJoin, NoobJoin.settings)
end)
