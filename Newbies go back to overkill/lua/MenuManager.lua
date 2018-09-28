Hooks:PostHook(MenuCallbackHandler, "start_job", "NoobJoin:ContractBuy", function(self, job_data)
	if not Global.game_settings.job_plan then
		Global.game_settings.job_plan = -1
	end
	DelayedCalls:Add("NoobJoin:Delayed_Contract_Buy", 2, function()
		MenuCallbackHandler:Self_Inspect(true)
	end)
end)

function NoobJoin:Show_Update_message()
	DelayedCalls:Add("NoobJoin:Show_Update_message_delay", 1, function()
		if NoobJoin.settings.message < NoobJoin.Needed_message then
			local menu_options = {}
			local message = ""
			menu_options[#menu_options+1] = {text = managers.localization:text("dialog_cancel"), is_cancel_button = true}
			menu_options[#menu_options+1] ={text = "Steam Group", data = nil, callback = JoinSteamGroup}
			for i=1, #NoobJoin.Update_message do
				if i ~= #NoobJoin.Update_message then
					message = message .. NoobJoin.Update_message[i] .. "\n"
				else
					message = message .. NoobJoin.Update_message[i]
				end
			end
			local menu = QuickMenu:new(NoobJoin.Name, message, menu_options)
			menu:Show()
			NoobJoin.settings.message = NoobJoin.Needed_message
			NoobJoin:Save()
		end
	end)
end

function NoobJoin:Prefixs()
	if Network:is_server() then
		if Global.game_settings.difficulty == "sm_wish" then
			return "[NGBTDW]" -- If they keep on crying after this, I don't know what could make them stop...
		elseif Global.game_settings.difficulty == "overkill_290" then
			return "[NGBTM]"
		elseif Global.game_settings.difficulty == "easy_wish" then
			return "[NGBTO]"
		elseif Global.game_settings.difficulty == "overkill_145" then
			return "[NGBTVH]"
		else
			return "[NGBTO]"
		end
	else
		return "[NGBTO]"
	end
end

function MenuCallbackHandler:Manual_banning()
	if managers.network._session and #managers.network:session():peers() > 0 then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Manual_Add_To_Blacklist}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Manual_Add_To_Blacklist}
			end
		end
		menu_options[#menu_options+1] = {text = managers.localization:text("dialog_cancel"), is_cancel_button = true}
		local menu = QuickMenu:new(NoobJoin.Name, managers.localization:text("Manual_ban_select"), menu_options)
		menu:Show()
	end
end

function MenuCallbackHandler:Skill_Show()
	log("skill_show")
	if managers.network:session() then
		NoobJoin:Information_To_HUD(managers.network:session():peer(_G.LuaNetworking:LocalPeerID()))
		for _, peer in pairs(managers.network:session():peers()) do
			NoobJoin:Information_To_HUD(peer)
		end
		NoobJoin:Debug_Message()
	end
end

function MenuCallbackHandler:Player_inspection_menu()
	if managers.network._session then
		local menu_options = {}
		local peer = managers.network._session:peer(_G.LuaNetworking:LocalPeerID())
		menu_options[1] ={text = peer:name(), data = peer:id(), callback = NGBTO_player_inspect}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = NGBTO_player_inspect}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = NGBTO_player_inspect}
			end
		end
		menu_options[#menu_options+1] = {text = managers.localization:text("dialog_cancel"), is_cancel_button = true}
		local menu = QuickMenu:new(NoobJoin.Name, managers.localization:text("player_inspection"), menu_options)
		menu:Show()
	end
end

function JoinSteamGroup()
	Steam:overlay_activate("url", "http://steamcommunity.com/groups/ngbtomod")
end

function MenuCallbackHandler:Self_Inspect(buy)
	if Network:is_server() and NoobJoin:inChat() == false and managers.network:session() then
		if NoobJoin.settings.Toggle == 1 and not buy then
			NoobJoin.settings.Toggle = 0
			NoobJoin:Save()
			NoobJoin:Debug_Message(managers.localization:text("kick_option_off"), NoobJoin.Colors[1])
		else
			local message = ""
			local hidden = ""
			local peer = managers.network:session():peer(1)
			dohttpreq("http://api.pd2stats.com/cheater/v3/?type=saf&id=".. Steam:userid()  .. "&force=1",
			function(page)
				local cheater = false
				local cheater1 = false
				cheater = NoobJoin:Pd2stats_cheater(page, false)
				message = cheater[2]
				cheater = cheater[1]
				if cheater == true then
					NoobJoin:Debug_Message(message, NoobJoin.Colors[1])
				end
				local skills_perk_deck_info = string.split(peer:skills(), "-") or {}
				if #skills_perk_deck_info == 2 then
					local skills = string.split(skills_perk_deck_info[1], "_")
					cheater1 = NoobJoin:Skill_cheater(skills, peer, true)
				end
				if cheater == true or cheater1 == true then
					if cheater1 == true then
						message = "Cheated, too many skill points"
					end
					NoobJoin.settings.Toggle = 0
					NoobJoin:Debug_Message(message, NoobJoin.Colors[1])
					NoobJoin:Save()
				else
					if not buy then
						NoobJoin.settings.Toggle = 1
						NoobJoin:Save()
					end
					if NoobJoin.settings.Toggle == 0 then
						NoobJoin:Debug_Message(managers.localization:text("kick_option_off"), NoobJoin.Colors[1])
					else
						local hours = NoobJoin:Return_Minimum_Hours()
						local perk_decks = NoobJoin:Restricted_perk_decks()
						local deployables = NoobJoin:Restricted_deployables()
						local armor = NoobJoin:Restricted_armor()
						if hours == 0 then
							message = managers.localization:text("lobby_not_supported") .. ". "
							if NoobJoin.settings.kickhidden_val == true then
								message = string.format("%s%s.",  message, managers.localization:text("hidden_kick_on"))
							end
							NoobJoin:Debug_Message(message, NoobJoin.Colors[3], perk_decks, deployables, armor)
						elseif hours ~= -1 then
							if NoobJoin.settings.kickhidden_val == true then
								hidden = " " .. managers.localization:text("lobby_create_message_2")
							end
							message = string.format("%s%s %s %s %s",  managers.localization:text("lobby_create_message_1"), hidden, managers.localization:text("lobby_create_message_3"), hours, managers.localization:text("lobby_create_message_4"))
							NoobJoin:Debug_Message(message, NoobJoin.Colors[3], perk_decks, deployables, armor)
						else
							NoobJoin:Debug_Message(managers.localization:text("lobby_not_supported"), NoobJoin.Colors[3])
						end
					end
				end
			end)
		end
	end
end

function NoobJoin:Pd2stats_cheater(page, extra)
	local extra_protection = false
	for param, val in string.gmatch(page, "([%w_]+)=([%w_]+)") do
		if param == "reason_1" or param == "reason_2" or param == "reason_3" then
			val = string.gsub(val, "_", " ")
			extra_protection = string.find(val, "Not enough heists completed") and true or false
			if NoobJoin.settings.tag_not_enough_heists_completed == true and extra then
				extra_protection = false
			end
			if extra_protection == false then
				return {true, val}
			end
		end
	end
	return {false, ""}
end

function NoobJoin:Is_Friend(user_id)
	if Steam:logged_on() then
		for _, friend in ipairs(Steam:friends() or {}) do
			if friend:id() == user_id then
				return true
			end
		end
	end
	return false
end

function NoobJoin:Player_Announce(peer)
	if NoobJoin:Is_From_Blacklist(peer:user_id()) == true then
		NoobJoin:Message_Receive(peer:name() .. " " .. managers.localization:text("player_blacklist"), 1)
	elseif NoobJoin:Is_Friend(peer:user_id()) == true then
		NoobJoin:Message_Receive(peer:name() .. " " .. managers.localization:text("player_whitelist"), 3, true)
	else
		NoobJoin:PD2Stats_API_Check(peer:user_id(), peer:id())
	end
end

function Manual_Add_To_Blacklist(id)
	local peer = managers.network:session():peer(id)
	if peer then
		NoobJoin:Message_Receive(peer:name() .. " " .. managers.localization:text("manually_added_to_blacklist") , 1)
		NoobJoin:Add_Cheater(peer:user_id(), peer:name(), "Manual ban")
		NoobJoin:Kick_Selected_Peer(id, "You were suspected as a cheater", peer:user_id(), true)
	end
end

function NGBTO_player_inspect(id)
	local peer = managers.network:session():peer(id)
	if peer then
		local hours = ""
		local cheater = false
		local achievements = ""
		local vac = managers.localization:text("clean")
		local outfit = ""
		local skill = ""
		local perk_deck_completion = ""
		local p = ""
		dohttpreq("http://steamcommunity.com/profiles/".. peer:user_id() .. "/?l=english",
		function(page)
			local _, hours_start = string.find(page, '<div class="game_info_details">')
			if hours_start then
				local hours_ends = string.find(page, '<div class="game_name"><a', hours_start)
				if hours_ends then
					hours = (string.sub(page, hours_start, hours_ends))
					hours = string.gsub(hours, "	", "")
					hours = string.gsub(hours, "hrs on record<br>", "")
					hours = string.gsub(hours, "<", "")
					hours = string.gsub(hours, ">", "")
					hours = string.split(hours, "\n")
					hours = hours[2]
					hours = string.gsub(hours, ",", "")
					hours = (math.floor((hours + 1/2)/1) * 1)
					hours = tonumber(hours)
					if hours ~= nil then
						hours = (math.floor((hours + 1/2)/1) * 1)
					end
				end
			end
			local _, start = string.find(page, '<div class="profile_ban_status">')
			if start then
				vac = "banned"
			end
			local _, ach_start = string.find(page, '<h2>Recent Activity</h2>')
			if ach_start then
				local ach_ends = string.find(page, '<span>View mobile website</span>', ach_start)
				if ach_ends then
					local page1 = (string.sub(page, ach_start, ach_ends))
					if page1 then
						local _, ach1_start = string.find(page1, '<span class="ellipsis">')
						if ach1_start then
							local ach1_ends = string.find(page1, '<div class="achievement_progress_bar_ctn">', ach1_start)
							if ach1_ends then
								achievements = (string.sub(page1, ach1_start, ach1_ends))
								achievements = string.split(achievements, " of")
								local achievements2 = string.sub(achievements[2], 2, 4)
								achievements = achievements[1]
								achievements = string.gsub(achievements, ">", "")
								achievements = achievements .. " / " .. achievements2
							end
						end
					end
				end
			end
			dohttpreq("http://api.pd2stats.com/cheater/v3/?type=saf&id=".. peer:user_id() .. "&force=1",
			function(page)
				cheater = NoobJoin:Pd2stats_cheater(page, true)[1]
				if peer:skills() then
					if peer:skills() ~= nil then
						local skills_perk_deck_info = string.split(peer:skills(), "-") or {}
						local skills = string.split(skills_perk_deck_info[1], "_")
						local perk_deck = string.split(skills_perk_deck_info[2], "_")
						p = managers.localization:text("menu_st_spec_" .. perk_deck[1])
						skill = NoobJoin:Text_Formatting(skills)
						perk_deck_completion = " " .. perk_deck[2] .. "/" .. "9"
						outfit = string.split(peer:profile().outfit_string, " ") or {}
						outfit[7] = string.gsub(outfit[7], "wpn_fps_", "")
						outfit[9] = string.gsub(outfit[9], "wpn_fps_", "")
						outfit[15] = string.gsub(outfit[15], "wpn_prj_", "")
						for i=1,#outfit do
							outfit[i] = string.gsub(outfit[i], "_", " ")
						end
						if outfit[12] == "1" then
							outfit[12] = ""
						else
							outfit[12] = " x" .. outfit[12]
						end
						outfit = "\n" .. managers.localization:text("bm_menu_primaries") ..  ": " .. outfit[7] .. "\n" .. managers.localization:text("bm_menu_secondaries") .. ": " .. outfit[9] .. "\n" .. managers.localization:text("bm_menu_deployables") .. ": " .. outfit[11] .. outfit[12] .. "\n" .. managers.localization:text("bm_menu_grenades") .. ": " .. outfit[15]
					end
				end
				NoobJoin:NGBTO_player_data(id, hours, vac, achievements, cheater, skill, p, perk_deck_completion, outfit)
			end)
		end)
	end
end

function NGBTO_player_http(data)
	local peer = managers.network:session():peer(data[2])
	if peer then
		local link
		if data[1] == "steam" then
			link = "http://steamcommunity.com/profiles/" .. peer:user_id()
		elseif data[1] == "pd2stats" then
			link = "http://pd2stats.com/profiles/" .. peer:user_id()
		elseif data[1] == "pd2statsanticheat" then
			link = "http://api.pd2stats.com/cheater/v3/?type=saf&id=" .. peer:user_id() .. "&force=1"
		elseif data[1] == "steamrep" then
			link = "http://steamrep.com/profiles/" .. peer:user_id()
		elseif data[1] == "steamdb" then
			link = "https://steamdb.info/calculator/" .. peer:user_id()
		end
		Steam:overlay_activate("url", link)
		NoobJoin:NGBTO_player_inspection(data[2], data[3])
	end
end

function NoobJoin:Check_both_active(id)
	local peer = managers.network:session():peer(id)
	if peer then
		if NoobJoin.Players[id][5] ~= 0 and NoobJoin.Players[id][6] ~= 0 then -- Achievements
			if NoobJoin.Players[id][6] ~= true then
				NoobJoin:Achievements(id)
			end
		end
		if NoobJoin.Players[id][5] ~= 0 and NoobJoin.Players[id][9] ~= 0 then  -- Infamy
			if NoobJoin.Players[id][9] ~= true then
				NoobJoin:Infamy_check(id)
			end
		end
	end
end

function NoobJoin:NGBTO_player_data(id, hours, vac, achievements, pd2cheat, skill, p, perk_deck_completion, outfit)
	local peer = managers.network:session():peer(id)
	if peer then
		if pd2cheat == true then
			pd2cheat = managers.localization:text("warning")
		else
			pd2cheat = managers.localization:text("clean")
		end
		local rank = ""
		if peer:rank() and peer:level() then
			rank = "\n" .. managers.localization:text("menu_infamytree") .. ": " .. peer:rank() .. "\n" .. managers.localization:text("Level") .. ": " .. peer:level()
		end
		local skills = ""
		if skill ~= "" and p ~= "" and perk_deck_completion ~= "" then
			skills = "\n" .. managers.localization:text("menu_st_skilltree") .. ": " .. skill .. "\n" .. managers.localization:text("menu_specialization") .. ": " .. p .. perk_deck_completion
		end
		if hours == "" then
			hours = "\n" .. managers.localization:text("Playtime") .. ": " .. managers.localization:text("hidden")
		else
			hours = "\n" .. managers.localization:text("Playtime") .. ": " .. tostring(hours) ..  " " .. managers.localization:text("hours_joined_2")
		end
		if achievements == "" then
			achievements = ""
		else
			achievements = "\n" .. managers.localization:text("Achievements") .. ": " .. achievements
		end
		local message = managers.localization:text("Player") .. ": " .. peer:name() .. rank .. hours .. skills .. achievements ..  " \n" .. managers.localization:text("VAC_status") .. ": " .. vac .. "\n" .. managers.localization:text("Pd2Stats_check") .. ": " .. pd2cheat .. outfit
		NoobJoin:NGBTO_player_inspection(id, message)
	end
end

function NoobJoin:NGBTO_player_inspection(id, message)
	local peer = managers.network:session():peer(id)
	if peer then
		local menu_options = {}
		menu_options[#menu_options+1] ={text = managers.localization:text("refresh"), data = id, callback = NGBTO_player_inspect}
		if peer:user_id() ~= Steam:userid() then
			if NoobJoin:Is_Friend(peer:user_id()) == false then
				menu_options[#menu_options+1] ={text = managers.localization:text("Manual_ban_button"), data = peer:id(), callback = Manual_Add_To_Blacklist}
			end
		end
		menu_options[#menu_options+1] ={text = "Steam profile", data = {"steam", id, message}, callback = NGBTO_player_http}
		menu_options[#menu_options+1] ={text = "Pd2Stats", data = {"pd2stats", id, message}, callback = NGBTO_player_http}
		menu_options[#menu_options+1] ={text = "Steamrep", data = {"steamrep", id, message}, callback = NGBTO_player_http}
		menu_options[#menu_options+1] ={text = "Steamdb", data = {"steamdb", id, message}, callback = NGBTO_player_http}
		menu_options[#menu_options+1] ={text = managers.localization:text("Back"), data = "", callback = NoobJoin.PlayerInspect}
		menu_options[#menu_options+1] = {text = managers.localization:text("dialog_cancel"), is_cancel_button = true}
		local menu = QuickMenu:new(NoobJoin.Name, message, menu_options)
		menu:Show()
	end
end

function NoobJoin:inChat()
	if managers.hud ~= nil and managers.hud._chat_focus == true then
		return true
	end
	if managers.menu_component ~= nil and managers.menu_component._game_chat_gui ~= nil and managers.menu_component._game_chat_gui:input_focus() == true then
		return true
	end
	return false
end

function NoobJoin:Delayed_Message(message)
	if Network:is_server() and NoobJoin.settings.broadcastinfo_val == true then
		local num_player_slots = BigLobbyGlobals and BigLobbyGlobals:num_player_slots() or 4
		for i=2,num_player_slots do
			local peer = managers.network:session():peer(i)
			if peer then
				peer:send("send_chat_message", ChatManager.GAME, NoobJoin:Prefixs() .. ": " .. message)
			end
		end
	end
end

function NoobJoin:Deployables(peer_id, deployable, amount)
	local peer = managers.network:session():peer(peer_id)
	if peer then
		if NoobJoin:Is_Friend(peer:user_id()) == false then
			if Global.game_settings.difficulty == "overkill_145" or Global.game_settings.difficulty == "overkill_290" or Global.game_settings.difficulty == "easy_wish" or Global.game_settings.difficulty == "sm_wish" then
				local message = string.format("%s %s ",  peer:name(), managers.localization:text("perk_deck_kick_1"))
				local deployable_check = NoobJoin:Deployable_list(deployable, amount, message)
				local kick = deployable_check[1]
				message = deployable_check[2]
				if kick == true then
					if NoobJoin.Players[peer_id][8] ~= true then
						NoobJoin:Message_Receive(message, 1)
						NoobJoin.Players[peer_id][8] = true
						NoobJoin:Kick_Selected_Peer(peer_id, message, peer:user_id())
					end
				end
			end
		end
	end
end

function NoobJoin:Deployable_list(deployable, amount, message, on_ready)
	local kick = false
	local kickmessage = ""
	if NoobJoin.settings.noequipment == true or NoobJoin.settings.fourfaks == true or NoobJoin.settings.first_aid_kit == true or NoobJoin.settings.trip_mine == true or NoobJoin.settings.ammo_bag == true or NoobJoin.settings.doctor_bag == true or NoobJoin.settings.singleturret == true or NoobJoin.settings.bodybags == true or NoobJoin.settings.armorkit == true or NoobJoin.settings.singleecm == true then
		if NoobJoin.settings.noequipment == true and on_ready and amount == 0 then
			kickmessage = "ngbto_no_deployable_title"
			kick = true
		elseif NoobJoin.settings.bodybags == true and deployable == "bodybags_bag" then
			kickmessage = "bm_equipment_bodybags_bag"
			kick = true
		elseif NoobJoin.settings.armorkit == true and deployable == "armor_kit" then
			kickmessage = "bm_equipment_armor_kit"
			kick = true
		elseif NoobJoin.settings.singleecm == true and deployable == "ecm_jammer" then
			kickmessage = "bm_equipment_ecm_jammer"
			kick = true
		elseif NoobJoin.settings.trip_mine == true and deployable == "trip_mine" then
			kickmessage = "bm_equipment_trip_mine"
			kick = true
		elseif NoobJoin.settings.doctor_bag == true and deployable == "doctor_bag" then
			kickmessage = "bm_equipment_doctor_bag"
			kick = true
		elseif NoobJoin.settings.ammo_bag == true and deployable == "ammo_bag" then
			kickmessage = "bm_equipment_ammo_bag"
			kick = true
		elseif NoobJoin.settings.first_aid_kit == true and deployable == "first_aid_kit" then
			kickmessage = "bm_equipment_first_aid_kit"
			kick = true
		end
		if NoobJoin.settings.singleturret == true then
			if deployable == "sentry_gun" or deployable == "sentry_gun_silent" then
				kickmessage = "bm_equipment_sentry_gun"
				kick = true
			end
		end
		if kickmessage ~= "" then
			message = message .. string.lower(managers.localization:text(kickmessage))
		end
		if NoobJoin.settings.fourfaks == true and on_ready and deployable == "first_aid_kit" and amount == 4 and kick == false then
			message = message .. "4 " .. string.lower(managers.localization:text(bm_equipment_first_aid_kit))
			kick = true
		end
	end
	return {kick, message}
end

function NoobJoin:Deployables_Lookup(peer_id)
	if Utils:IsInGameState() and NoobJoin.settings.Toggle == 1 and tonumber(peer_id) ~= 1 and Network:is_server() then
		if Global.game_settings.difficulty == "overkill_145" or Global.game_settings.difficulty == "overkill_290" or Global.game_settings.difficulty == "easy_wish" or Global.game_settings.difficulty == "sm_wish" then
			local peer = managers.network:session():peer(peer_id)
			if peer then
				if peer:waiting_for_player_ready() == true and NoobJoin:Is_Friend(peer:user_id()) == false then
					local concealment = NoobJoin:Concealment(peer_id)
					local split = string.split(peer:profile().outfit_string, " ")
					if split then
						local message = string.format("%s %s ",  peer:name(), managers.localization:text("perk_deck_kick_1"))
						local deployable_check = NoobJoin:Deployable_list(split[11], tonumber(split[12]), message, true)
						local kick = deployable_check[1]
						message = deployable_check[2]
						if split[5] ~= nil then
							local armor = string.sub(split[5], 1, 7)
							if armor == "level_1" and NoobJoin.settings.armor1 == true then
								message = message .. managers.localization:text("bm_armor_level_1")
								kick = true
							elseif armor == "level_2" and NoobJoin.settings.armor2 == true then
								message = message .. managers.localization:text("bm_armor_level_2")
								kick = true
							elseif armor == "level_3" and NoobJoin.settings.armor3 == true then
								message = message .. managers.localization:text("bm_armor_level_3")
								kick = true
							elseif armor == "level_4" and NoobJoin.settings.armor4 == true then
								message = message .. managers.localization:text("bm_armor_level_4")
								kick = true
							elseif armor == "level_5" and NoobJoin.settings.armor5 == true then
								message = message .. managers.localization:text("bm_armor_level_5")
								kick = true
							elseif armor == "level_6" and NoobJoin.settings.armor6 == true then
								message = message .. managers.localization:text("bm_armor_level_6")
								kick = true
							elseif armor == "level_7" and NoobJoin.settings.armor7 == true then
								message = message .. managers.localization:text("bm_armor_level_7")
								kick = true
							end
						end
						if kick == false then
							kick = concealment[1]
							message = peer:name() .. " " ..  concealment[2]
						end
						if kick == true then
							if NoobJoin.Players[peer_id][8] ~= true then
								NoobJoin:Message_Receive(message, 1)
								NoobJoin.Players[peer_id][8] = true
								NoobJoin:Kick_Selected_Peer(peer_id, message, peer:user_id())
							end
						end
						NoobJoin.Players[peer_id][9] = tonumber(peer:rank())
						NoobJoin:Check_both_active(peer_id)
					end
				end
			end
		end
	end
end

function NoobJoin:Concealment(peer_id)
	if NoobJoin.Players[peer_id][7] ~= 0 then
		if NoobJoin.settings.detection_loud == true and Global.game_settings.job_plan == 1 then
			if NoobJoin.Players[peer_id][7] < NoobJoin.settings.detection_loud_value * 5 then
				return {true, managers.localization:text("ngbto_detection_too_low")}
			end
		elseif NoobJoin.settings.detection_stealth == true and Global.game_settings.job_plan == 2 then
			if NoobJoin.Players[peer_id][7] > NoobJoin.settings.detection_stealth_value * 5 then
				return {true, managers.localization:text("ngbto_detection_too_high")}
			end
		end
	end
	return {false,""}
end

function NoobJoin:Message_Receive(message, color, only)
	if Global.game_settings.single_player == false then
		managers.chat:_receive_message(1, NoobJoin:Prefixs(), message, Color(NoobJoin.Colors[color]))
		if not only then
			NoobJoin:Delayed_Message(message)
		end
	end
end

function NoobJoin:PlayerJoin(peer_id)
	local peer = managers.network:session():peer(peer_id)
	if peer then
		if Network:is_server() then
			if NoobJoin:Is_Friend(peer:user_id()) == false then
				NoobJoin:Return_Playtime(peer_id, peer:user_id())
				if peer:user_id() == "76561198043661340" then
					NoobJoin:Message_Receive("Hello there, could you tell me if there are any bugs with the current build of NGBTO? -FishTaco", 3, true)
				end
				NoobJoin:PD2Stats_API_Check(peer:user_id(), peer_id)
				NoobJoin:Heists_Completed(peer:user_id(), peer_id)
			else
				NoobJoin:Message_Receive(peer:name() .. " " .. managers.localization:text("player_whitelist"), 3)
			end
			if not Utils:IsInGameState() then
				NoobJoin:Join_Message(peer_id)
			end
			if Utils:IsInHeist() then
				NoobJoin.Players[peer_id][4] = managers.game_play_central and managers.game_play_central:get_heist_timer()
			end
		else
			NoobJoin:Player_Announce(peer)
		end
	end
end

function NoobJoin:Hours_Compare(peer_id, user_id)
	local peer = managers.network:session():peer(peer_id)
	local message = ""
	local kick = false
	local hours = NoobJoin:Return_Minimum_Hours()
	if peer then
		message = peer:name()
		if NoobJoin:Is_From_Blacklist(user_id) == true then
			message = string.format("%s %s",  message, managers.localization:text("player_blacklist"))
			kick = true
		elseif NoobJoin.settings.Toggle == 1 then
			if hours ~= -1 then
				if NoobJoin.Players[peer_id][5] == nil and NoobJoin.settings.kickhidden_val == true then
					if NoobJoin.settings.hiddeninfamycheck == false then
						message = string.format("%s %s",  message, managers.localization:text("player_was_hidden"))
						kick = true
					else
						message = string.format("%s %s",  message, managers.localization:text("player_is_hidden"))
					end
				elseif NoobJoin.Players[peer_id][5] == nil and NoobJoin.settings.kickhidden_val == false then
					message = string.format("%s %s",  message, managers.localization:text("player_is_hidden"))
				elseif NoobJoin.Players[peer_id][5] < hours then
					message = string.format("%s %s %s/%s %s",  message, managers.localization:text("hours_kicked_1"), tostring(NoobJoin.Players[peer_id][5]), tostring(hours), managers.localization:text("hours_kicked_2"))
					kick = true
				elseif NoobJoin.Players[peer_id][5] >= hours then
					message = string.format("%s %s %s %s",  message, managers.localization:text("hours_joined_1"), tostring(NoobJoin.Players[peer_id][5]), managers.localization:text("hours_joined_2"))
				end
			else
				if NoobJoin.Players[peer_id][5] == nil then
					message = string.format("%s %s",  message, managers.localization:text("player_is_hidden"))
				else
					message = string.format("%s %s %s %s",  message, managers.localization:text("hours_joined_1"), tostring(NoobJoin.Players[peer_id][5]), managers.localization:text("hours_joined_2"))
				end
			end
		elseif NoobJoin.settings.Toggle == 0 then
			if NoobJoin.Players[peer_id][5] == nil then
				message = string.format("%s %s",  message, managers.localization:text("player_is_hidden"))
			else
				message = string.format("%s %s %s %s",  message, managers.localization:text("hours_joined_1"), tostring(NoobJoin.Players[peer_id][5]), managers.localization:text("hours_joined_2"))
			end
		end
		if kick == true then
			if NoobJoin.Players[peer_id][8] ~= true then
				NoobJoin:Message_Receive(message, 1)
				NoobJoin.Players[peer_id][8] = true
				NoobJoin:Kick_Selected_Peer(peer_id, message, peer:user_id())
			end
		else
			NoobJoin:Message_Receive(message, 2)
			NoobJoin:Check_both_active(peer_id)
		end
	end
end

function NoobJoin:Join_Message(peer_id)
	local hours = NoobJoin:Return_Minimum_Hours()
	if NoobJoin.settings.broadcastinfo_val == true and NoobJoin.settings.Toggle == 1 and Network:is_server() then
		DelayedCalls:Add("NoobJoin:Delayed_Message" .. tostring(peer_id), 2, function()
			local hidden = ""
			local message = NoobJoin:Prefixs() .. ": "
			local perk_decks = NoobJoin:Restricted_perk_decks()
			local deployables = NoobJoin:Restricted_deployables()
			local armor = NoobJoin:Restricted_armor()
			if hours == 0 then
				message = string.format("%s%s",  message, "This lobby will print information about joining people and ban cheaters automatically.")
				if NoobJoin.settings.kickhidden_val == true then
					message = string.format("%s %s",  message, "Hidden profiles will be kicked.")
				end
			elseif hours ~= -1 then
				if NoobJoin.settings.kickhidden_val == true then
					hidden = "hidden profiles and "
				end
				message = string.format("%s%s %s%s %s %s",  message, "This lobby will auto kick", hidden, "players with under", hours, "hours total playtime from the game.")
			else
				message = string.format("%s%s",  message, "This lobby will print information about joining people and ban cheaters automatically.")
			end
			if managers.network:session() and managers.network:session():peers() then
				local peer = managers.network:session():peer(peer_id)
				if peer then
					peer:send("send_chat_message", ChatManager.GAME, message)
					if hours ~= -1 then
						if perk_decks then
							peer:send("send_chat_message", ChatManager.GAME, NoobJoin:Prefixs() .. ": " .. perk_decks)
						end
						if deployables then
							peer:send("send_chat_message", ChatManager.GAME, NoobJoin:Prefixs() .. ": " .. deployables)
						end
						if armor then
							peer:send("send_chat_message", ChatManager.GAME, NoobJoin:Prefixs() .. ": " .. armor)
						end
					end
				end
			end
		end)
	end
end

function NoobJoin:Restricted_armor()
	local message = "Restricted armor:"
	local restrictions = {}
	if NoobJoin.settings.armor1 == true then
		table.insert(restrictions, "bm_armor_level_1")
	end
	if NoobJoin.settings.armor2 == true then
		table.insert(restrictions, "bm_armor_level_2")
	end
	if NoobJoin.settings.armor3 == true then
		table.insert(restrictions, "bm_armor_level_3")
	end
	if NoobJoin.settings.armor4 == true then
		table.insert(restrictions, "bm_armor_level_4")
	end
	if NoobJoin.settings.armor5 == true then
		table.insert(restrictions, "bm_armor_level_5")
	end
	if NoobJoin.settings.armor6 == true then
		table.insert(restrictions, "bm_armor_level_6")
	end
	if NoobJoin.settings.armor7 == true then
		table.insert(restrictions, "bm_armor_level_7")
	end
	if #restrictions == 0 then
		return
	else
		for i=1,#restrictions do
			restrictions[i] = string.lower(managers.localization:text(restrictions[i]))
		end
		return NoobJoin:Restrictions_Formatting(message, restrictions)
	end
end

function NoobJoin:Restricted_deployables()
	local message = "Restricted deployables:"
	local restrictions = {}
	if NoobJoin.settings.noequipment == true then
		table.insert(restrictions, "ngbto_no_deployable_title")
	end
	if NoobJoin.settings.singleturret == true then
		table.insert(restrictions, "bm_equipment_sentry_gun")
	end
	if NoobJoin.settings.bodybags == true then
		table.insert(restrictions, "debug_equipment_bodybags_bag")
	end
	if NoobJoin.settings.armorkit == true then
		table.insert(restrictions, "debug_equipment_armor_kit")
	end
	if NoobJoin.settings.singleecm == true then
		table.insert(restrictions, "debug_equipment_ecm_jammer")
	end
	if NoobJoin.settings.first_aid_kit == true then
		table.insert(restrictions, "bm_equipment_first_aid_kit")
	end
	if NoobJoin.settings.ammo_bag == true then
		table.insert(restrictions, "bm_equipment_ammo_bag")
	end
	if NoobJoin.settings.doctor_bag == true then
		table.insert(restrictions, "bm_equipment_doctor_bag")
	end
	if NoobJoin.settings.trip_mine == true then
		table.insert(restrictions, "bm_equipment_trip_mine")
	end
	if #restrictions == 0 and NoobJoin.settings.fourfaks == false then
		return
	else
		for i=1,#restrictions do
			restrictions[i] = string.lower(managers.localization:text(restrictions[i]))
		end
		if NoobJoin.settings.fourfaks == true then
			table.insert(restrictions, string.lower("4 " .. managers.localization:text("debug_equipment_first_aid_kit")))
		end
		return NoobJoin:Restrictions_Formatting(message, restrictions)
	end
end

function NoobJoin:Restricted_perk_decks()
	local message = "Restricted perk decks:"
	local restrictions = {}
	if NoobJoin.settings.perkdeck_1_val == true then
		table.insert(restrictions, 1)
	end
	if NoobJoin.settings.perkdeck_2_val == true then
		table.insert(restrictions, 2)
	end
	if NoobJoin.settings.perkdeck_3_val == true then
		table.insert(restrictions, 3)
	end
	if NoobJoin.settings.perkdeck_4_val == true then
		table.insert(restrictions, 4)
	end
	if NoobJoin.settings.perkdeck_5_val == true then
		table.insert(restrictions, 5)
	end
	if NoobJoin.settings.perkdeck_6_val == true then
		table.insert(restrictions, 6)
	end
	if NoobJoin.settings.perkdeck_7_val == true then
		table.insert(restrictions, 7)
	end
	if NoobJoin.settings.perkdeck_8_val == true then
		table.insert(restrictions, 8)
	end
	if NoobJoin.settings.perkdeck_9_val == true then
		table.insert(restrictions, 9)
	end
	if NoobJoin.settings.perkdeck_10_val == true then
		table.insert(restrictions, 10)
	end
	if NoobJoin.settings.perkdeck_11_val == true then
		table.insert(restrictions, 11)
	end
	if NoobJoin.settings.perkdeck_12_val == true then
		table.insert(restrictions, 12)
	end
	if NoobJoin.settings.perkdeck_13_val == true then
		table.insert(restrictions, 13)
	end
	if NoobJoin.settings.perkdeck_14_val == true then
		table.insert(restrictions, 14)
	end
	if NoobJoin.settings.perkdeck_15_val == true then
		table.insert(restrictions, 15)
	end
	if NoobJoin.settings.perkdeck_16_val == true then
		table.insert(restrictions, 16)
	end
	if NoobJoin.settings.perkdeck_17_val == true then
		table.insert(restrictions, 17)
	end
	if NoobJoin.settings.perkdeck_18_val == true then
		table.insert(restrictions, 18)
	end
	if NoobJoin.settings.perkdeck_19_val == true then
		table.insert(restrictions, 19)
	end
	if NoobJoin.settings.perkdeck_20_val == true then
		table.insert(restrictions, 20)
	end
	if #restrictions == 0 and NoobJoin.settings.incompletedeck == false then
		return
	else
		for i=1,#restrictions do
			restrictions[i] = string.lower(managers.localization:text("menu_st_spec_" .. restrictions[i]))
		end
		if NoobJoin.settings.incompletedeck == true then
			table.insert(restrictions, string.lower(managers.localization:text("ngbto_incomplete_perk_deck_title")))
		end
		return NoobJoin:Restrictions_Formatting(message, restrictions)
	end
end

function NoobJoin:Restrictions_Formatting(message, restrictions)
	for i=1,#restrictions do
		if #restrictions == i then
			message = string.format("%s %s.",  message, restrictions[i])
		else
			message = string.format("%s %s,",  message, restrictions[i])
		end
	end
	return message
end

function NoobJoin:Skills(peer_id)
	if managers.network:session() and managers.network:session():peers() then
		local peer = managers.network:session():peer(peer_id)
		if peer then
			if peer:skills() ~= nil then
				local skills = string.split(string.split(peer:skills(), "-")[1], "_")
				local cheater = NoobJoin:Skill_cheater(skills, peer)
				local perk_deck = string.split(string.split(peer:skills(), "-")[2], "_")
				local perk_deck_id = tonumber(perk_deck[1])
				local perk_deck_completion = tonumber(perk_deck[2])
				local message = peer:name().. NoobJoin:Text_Formatting(skills, managers.localization:text("menu_st_spec_" .. perk_deck_id), perk_deck_completion)
				if NoobJoin.settings.show_perks_info_val == true then
					if NoobJoin.Players[peer_id][1] ~= true then
						NoobJoin:Message_Receive(message, 2)
						if not NoobJoin.LoadCompleted then
							table.insert(NoobJoin.synced, {message, 2})
						end
						NoobJoin.Players[peer_id][1] = true
					end
				end
				NoobJoin:Skills_Kicking(peer_id, cheater, perk_deck_id, perk_deck_completion)
			end
		end
	end
end

function NoobJoin:Skills_Kicking(peer_id, cheater, perk_deck_id, perk_deck_completion)
	local peer = managers.network:session():peer(peer_id)
	local message = ""
	local kicked = false
	if peer and NoobJoin.settings.Toggle == 1 and NoobJoin:Is_Friend(peer:user_id()) == false and tonumber(peer_id) ~= 1 then
		if cheater == true then
			message = peer:name() .. " " .. managers.localization:text("cheater_ban")
			NoobJoin:Add_Cheater(peer:user_id(), peer:name(), "Using too many skill points")
			if NoobJoin.Players[peer_id][8] ~= true then
				NoobJoin:Message_Receive(message, 1)
				if not NoobJoin.LoadCompleted then
					table.insert(NoobJoin.synced, {message, 1})
				end
				NoobJoin.Players[peer_id][8] = true
				NoobJoin:Kick_Selected_Peer(peer:id(), message, peer:user_id(), true)
			end
			return
		end
		if Network:is_server() then
			if Global.game_settings.difficulty == "overkill_145" or Global.game_settings.difficulty == "overkill_290" or Global.game_settings.difficulty == "easy_wish" or Global.game_settings.difficulty == "sm_wish" then
				if NoobJoin.settings.perkdeck_1_val == true and perk_deck_id == 1 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_2_val == true and perk_deck_id == 2 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_3_val == true and perk_deck_id == 3 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_4_val == true and perk_deck_id == 4 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_5_val == true and perk_deck_id == 5 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_6_val == true and perk_deck_id == 6 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_7_val == true and perk_deck_id == 7 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_8_val == true and perk_deck_id == 8 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_9_val == true and perk_deck_id == 9 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_10_val == true and perk_deck_id == 10 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_11_val == true and perk_deck_id == 11 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_12_val == true and perk_deck_id == 12 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_13_val == true and perk_deck_id == 13 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_14_val == true and perk_deck_id == 14 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_15_val == true and perk_deck_id == 15 then
					kicked = true
				elseif NoobJoin.settings.perkdeck_16_val == true and perk_deck_id == 16 then
					kicked = true
				end
				if kicked == true then
					message = peer:name() .. " " .. managers.localization:text("perk_deck_kick_1") .. " " .. managers.localization:text("menu_st_spec_" .. perk_deck_id) .. " " .. managers.localization:text("perk_deck_kick_2")
				elseif NoobJoin.settings.perkdeck0_val == true and tonumber(perk_deck_completion) == 0 then
					message = peer:name() .. " " .. managers.localization:text("perk_deck_kick_3")
					kicked = true
				elseif NoobJoin.settings.incompletedeck == true and tonumber(perk_deck_completion) < 9 then
					message = peer:name() .. " " .. managers.localization:text("incomplete_perk_deck_kick")
					kicked = true
				end
				if kicked == true then
					if NoobJoin.Players[peer_id][8] ~= true then
						NoobJoin:Message_Receive(message, 1)
						NoobJoin.Players[peer_id][8] = true
						NoobJoin:Kick_Selected_Peer(peer:id(), message, peer:user_id())
					end
					return
				end
			end
		end
	end
end

function NoobJoin:NumberFormat(input_data)
	local array = {}
	for i=1,#input_data do
		if tonumber(input_data[i]) < 10 then
			input_data[i] = "0" .. input_data[i]
		end
		table.insert(array, input_data[i])
	end
	return array
end

function NoobJoin:Text_Formatting(skills, perk_deck, completion)
	local sk = {}
	local skill_string = {}
	local number = 0
	if #skills == 15 then
		if NoobJoin.settings.skills_detailed == false then
			sk[1] = skills[1] + skills[2] + skills[3] -- Mastermind
			sk[2] = skills[4] + skills[5] + skills[6] -- Enforcer
			sk[3] = skills[7] + skills[8] + skills[9] -- Technician
			sk[4] = skills[10] + skills[11] + skills[12] -- Ghost
			sk[5] = skills[13] + skills[14] + skills[15] -- Fugitive
			skill_string = NoobJoin:NumberFormat(sk)
			if perk_deck and completion then
				return string.format(" |%02u:%02u:%02u:%02u:%02u| %s %s/9", skill_string[1], skill_string[2], skill_string[3], skill_string[4], skill_string[5], perk_deck, completion)
			else
				return string.format("|%02u:%02u:%02u:%02u:%02u|", skill_string[1], skill_string[2], skill_string[3], skill_string[4], skill_string[5])
			end
		else
			skill_string = NoobJoin:NumberFormat(skills)
			if perk_deck and completion then
				return string.format(" M(%02u:%02u:%02u) E(%02u:%02u:%02u) T(%02u:%02u:%02u) G(%02u:%02u:%02u) F(%02u:%02u:%02u) %s %s/9", skill_string[1], skill_string[2], skill_string[3], skill_string[4], skill_string[5], skill_string[6], skill_string[7], skill_string[8], skill_string[9], skill_string[10], skill_string[11], skill_string[12], skill_string[13], skill_string[14], skill_string[15], perk_deck, completion)
			else
				return string.format("M(%02u:%02u:%02u) E(%02u:%02u:%02u) T(%02u:%02u:%02u) G(%02u:%02u:%02u) F(%02u:%02u:%02u)", skill_string[1], skill_string[2], skill_string[3], skill_string[4], skill_string[5], skill_string[6], skill_string[7], skill_string[8], skill_string[9], skill_string[10], skill_string[11], skill_string[12], skill_string[13], skill_string[14], skill_string[15])
			end
		end
	else
		return "invalid data received"
	end
end

function NoobJoin:Information_To_HUD(peer)
	if peer ~= nil then
		if peer:is_outfit_loaded() then
			local skills_perk_deck_info = string.split(peer:skills(), "-") or {}
			if #skills_perk_deck_info == 2 then
				local skills = string.split(skills_perk_deck_info[1], "_")
				local perk_deck = string.split(skills_perk_deck_info[2], "_")
				local p = managers.localization:text("menu_st_spec_" .. perk_deck[1])
				NoobJoin.Players[peer:id()][3] = peer:name() .. NoobJoin:Text_Formatting(skills, p, perk_deck[2])
			end
		end
	end
end

function NoobJoin:Is_From_Blacklist(user_id)
	for _,line in pairs(NoobJoin.blacklist) do
		if line == user_id then
			return true
		end
	end
	return false
end

function NoobJoin:Add_Cheater(user_id, username, reason)
	if NoobJoin:Is_From_Blacklist(user_id) == false and NoobJoin:Is_Friend(user_id) == false then
		table.insert(NoobJoin.blacklist, user_id)
		local time = os.date("*t")
		local timestamp = NoobJoin:NumberFormat({time.year, time.month, time.day, time.hour, time.min, time.sec})
		timestamp = timestamp[1] .. "-" .. timestamp[2] .. "-" .. timestamp[3] .. " " .. timestamp[4] .. ":" .. timestamp[5] .. ":" .. timestamp[6]
		file = io.open(NoobJoin.Blacklist_name, "a")
		file:write("\n" .. user_id .. "\n" .. ";" .. username .. " reason: " .. reason .. ". Date: " .. timestamp)
		file:close()
	end
end

function NoobJoin:Return_Playtime(peer_id, user_id)
	local hours = nil
	local achievements = nil
	dohttpreq("http://steamcommunity.com/profiles/".. user_id .. "/?l=english",
	function(page)
		local _, hours_start = string.find(page, '<div class="game_info_details">')
		if hours_start then
			local hours_ends = string.find(page, '<div class="game_name"><a', hours_start)
			if hours_ends then
				hours = (string.sub(page, hours_start, hours_ends))
				hours = string.gsub(hours, "	", "")
				hours = string.gsub(hours, "hrs on record<br>", "")
				hours = string.gsub(hours, "<", "")
				hours = string.gsub(hours, ">", "")
				hours = string.split(hours, "\n")
				hours = hours[2]
				hours = string.gsub(hours, ",", "")
				hours = (math.floor((hours + 1/2)/1) * 1)
				hours = tonumber(hours)
				if hours ~= nil then
					hours = (math.floor((hours + 1/2)/1) * 1)
				end
			end
		end
		local _, ach_start = string.find(page, '<h2>Recent Activity</h2>')
		if ach_start then
			local ach_ends = string.find(page, '<span>View mobile website</span>', ach_start)
			if ach_ends then
				local page1 = (string.sub(page, ach_start, ach_ends))
				if page1 then
					local _, ach1_start = string.find(page1, '<span class="ellipsis">')
					if ach1_start then
						local ach1_ends = string.find(page1, '<div class="achievement_progress_bar_ctn">', ach1_start)
						if ach1_ends then
							achievements = (string.sub(page1, ach1_start, ach1_ends))
							achievements = string.split(achievements, " of")
							local achievements2 = string.sub(achievements[2], 2, 4)
							achievements = achievements[1]
							achievements = string.gsub(achievements, ">", "")
							achievements = tonumber(achievements)
							if achievements ~= nil then
								NoobJoin.Players[peer_id][6] = achievements
							end
						end
					end
				end
			end
		end
		NoobJoin.Players[peer_id][5] = hours
		NoobJoin:Hours_Compare(peer_id, user_id)
	end)
end

function NoobJoin:Infamy_check(peer_id)
	if NoobJoin.settings.Toggle == 1 and Network:is_server() then
		if Global.game_settings.difficulty == "overkill_145" or Global.game_settings.difficulty == "overkill_290" or Global.game_settings.difficulty == "easy_wish" or Global.game_settings.difficulty == "sm_wish" then
			if NoobJoin.settings.Infamy_check == true and NoobJoin.Players[peer_id][9] ~= nil and NoobJoin.Players[peer_id][5] ~= nil then
				local peer = managers.network:session():peer(peer_id)
				local kick = false
				local message = ""
				if peer then
					if NoobJoin:Is_Friend(peer:user_id()) == false then
						message = peer:name() .. " " .. managers.localization:text("fast_infamy") .. " " .. NoobJoin.Players[peer_id][9] .. " " .. managers.localization:text("too_fast")
						if NoobJoin.Players[peer_id][9] <= 4 then
						elseif NoobJoin.Players[peer_id][9] <= 10 then -- 5 - 10
							if NoobJoin.Players[peer_id][5] < NoobJoin.settings.Infamy_check_10*20 then
								kick = true
							end
						elseif NoobJoin.Players[peer_id][9] <= 15 then -- 11 - 15
							if NoobJoin.Players[peer_id][5] < NoobJoin.settings.Infamy_check_15*20 then
								kick = true
							end
						elseif NoobJoin.Players[peer_id][9] <= 20 then -- 16 - 20
							if NoobJoin.Players[peer_id][5] < NoobJoin.settings.Infamy_check_20*20 then
								kick = true
							end
						elseif NoobJoin.Players[peer_id][9] < 25 then -- 21 - 24
							if NoobJoin.Players[peer_id][5] < NoobJoin.settings.Infamy_check_24*20 then
								kick = true
							end
						elseif NoobJoin.Players[peer_id][9] == 25 then -- 25
							if NoobJoin.Players[peer_id][5] < NoobJoin.settings.Infamy_check_25*20 then
								kick = true
							end
						end
						if kick == true then
							if NoobJoin.Players[peer_id][8] ~= true then
								NoobJoin:Message_Receive(message, 1)
								NoobJoin.Players[peer_id][8] = true
								NoobJoin:Kick_Selected_Peer(peer_id, message, peer:user_id())
							end
						end
						if NoobJoin.Players[peer_id][5] == nil and tonumber(NoobJoin.Players[peer_id][9]) < (NoobJoin.settings.hiddeninfamy-1) then
							message = peer:name() .. " " .. managers.localization:text("perk_deck_kick_4")
							kick = true
						elseif NoobJoin.Players[peer_id][5] == nil and tonumber(NoobJoin.Players[peer_id][9]) > (NoobJoin.settings.hiddeninfamymax-1) then
							message = peer:name() .. " " .. managers.localization:text("perk_deck_kick_5")
							kick = true
						elseif NoobJoin.Players[peer_id][5] == nil and NoobJoin.settings.hiddenxxv == true and tonumber(NoobJoin.Players[peer_id][9]) == 25 and tonumber(peer:level()) == 100 then
							message = peer:name() .. " " .. managers.localization:text("infamyxxv_kick")
							kick = true
						elseif NoobJoin.Players[peer_id][5] == nil and NoobJoin.settings.hiddenv == true and tonumber(NoobJoin.Players[peer_id][9]) == 5 and tonumber(peer:level()) == 100 then
							message = peer:name() .. " " .. managers.localization:text("infamyv_kick")
							kick = true
						end
						if kick == true then
							if NoobJoin.Players[peer_id][8] ~= true then
								NoobJoin:Message_Receive(message, 1)
								NoobJoin.Players[peer_id][8] = true
								NoobJoin:Kick_Selected_Peer(peer_id, message, peer:user_id())
							end
						end
						NoobJoin.Players[peer_id][9] = true
					end
				end
			end
		end
	end
end

function NoobJoin:Achievements(peer_id)
	if NoobJoin.settings.Toggle == 1 and Network:is_server() then
		if Global.game_settings.difficulty == "overkill_145" or Global.game_settings.difficulty == "overkill_290" or Global.game_settings.difficulty == "easy_wish" or Global.game_settings.difficulty == "sm_wish" then
			if NoobJoin.settings.achievements_check == true and NoobJoin.Players[peer_id][6] ~= 0 then
				local peer = managers.network:session():peer(peer_id)
				if peer then
					if NoobJoin:Is_Friend(peer:user_id()) == false then
						local message = peer:name() .. " " .. managers.localization:text("achievements_too_fast") .. " " .. NoobJoin.Players[peer_id][6] .. "" .. managers.localization:text("Achievements") .. " " .. managers.localization:text("too_fast")
						if NoobJoin.Players[peer_id][6] > 370 and NoobJoin.Players[peer_id][5] < 300 then
							if NoobJoin.Players[peer_id][8] ~= true then
								NoobJoin:Message_Receive(message, 1)
								NoobJoin.Players[peer_id][8] = true
								NoobJoin:Kick_Selected_Peer(peer_id, message, peer:user_id())
							end
						end
						NoobJoin.Players[peer_id][6] = true
					end
				end
			end
		end
	end
end

function NoobJoin:Heists_Completed(user_id, peer_id)
	if NoobJoin.settings.Toggle == 1 then
		if NoobJoin.settings.deathwish_count_enable == true or NoobJoin.settings.total_count_enable == true then
			if Global.game_settings.difficulty == "overkill_145" or Global.game_settings.difficulty == "overkill_290" or Global.game_settings.difficulty == "easy_wish" or Global.game_settings.difficulty == "sm_wish" then
				local sum = 0
				local current = ""
				local number = {} -- Normal, Hard, Very hard, Overkill, Deathwish
				dohttpreq("http://pd2stats.com/profiles/".. user_id .. "/?l=en",
				function(page)
					local _, start = string.find(page, '<table class="maxtable">')
					if start then
						local ends = string.find(page, "Accounting for ", start)
						if ends then
							current = (string.sub(page, start, ends))
							for i in string.gmatch(current, "%S+") do
								if string.sub(i, 1, 13) == 'class="diff">' then
									i = string.gsub(i, 'class="diff">', "")
									sum = sum + tonumber(i)
									table.insert(number, tonumber(i))
								end
							end
						end
					else
						sum = nil
					end
					if sum ~= nil then
						local peer = managers.network:session():peer(peer_id)
						if peer then
							if NoobJoin:Is_Friend(peer:user_id()) == false then
								local message = peer:name() .. " "
								local kick = false
								if NoobJoin.settings.deathwish_count_enable == true and ((NoobJoin.settings.deathwish_count*20)-20) > number[5] then
									message = message ..  managers.localization:text("deathwish_count_kick") .. " " .. tostring(number[5]) .. "/" .. tostring(((NoobJoin.settings.deathwish_count*20)-20))
									kick = true
								elseif NoobJoin.settings.total_count_enable == true and ((NoobJoin.settings.total_count*20)-20) > sum then
									message = message ..  managers.localization:text("total_count_kick") .. " " .. tostring(sum) .. "/" .. tostring(((NoobJoin.settings.total_count*20)-20))
									kick = true
								end
								if kick == true then
									if NoobJoin.Players[peer_id][8] ~= true then
										NoobJoin:Message_Receive(message, 1)
										NoobJoin.Players[peer_id][8] = true
										NoobJoin:Kick_Selected_Peer(peer_id, message, peer:user_id())
									end
								end
							end
						end
					end
				end)
			end
		end
	end
end

function NoobJoin:PD2Stats_API_Check(user_id, peer_id)
	if NoobJoin.settings.usepd2statsanticheat == true and NoobJoin.settings.Toggle == 1 and NoobJoin:Is_Friend(user_id) == false then
		dohttpreq("http://api.pd2stats.com/cheater/v3/?type=saf&id=".. user_id .. "&force=1",
		function(page)
			local peer = managers.network:session():peer(peer_id)
			if peer then
				local cheater = NoobJoin:Pd2stats_cheater(page, true)
				if cheater[1] == true then
					NoobJoin:Add_Cheater(user_id, peer:name(), cheater[2])
					if NoobJoin.Players[peer_id][2] ~= true then
						NoobJoin:Message_Receive(peer:name() .. ": " .. cheater[2], 1)
						if not NoobJoin.LoadCompleted then
							table.insert(NoobJoin.synced, {peer:name() .. ": " .. cheater[2], 1})
						end
						NoobJoin.Players[peer_id][2] = true
						NoobJoin:Kick_Selected_Peer(peer_id, peer:name() .. ": " .. cheater[2], peer:user_id(), true)
					end
				end
			end
		end)
	end
end

function NoobJoin:Return_Minimum_Hours()
	if Global.game_settings.difficulty == "sm_wish" then
		if Global.game_settings.job_plan == -1 or Global.game_settings.job_plan == 1 then
			return ((NoobJoin.settings.min_hours_loud_sm_wish_val * 20) - 20)
		else
			return ((NoobJoin.settings.min_hours_stealth_sm_wish_val * 20) - 20)
		end
	elseif Global.game_settings.difficulty == "overkill_290" then
		if Global.game_settings.job_plan == -1 or Global.game_settings.job_plan == 1 then
			return ((NoobJoin.settings.min_hours_loud_dw_val * 20) - 20)
		else
			return ((NoobJoin.settings.min_hours_stealth_dw_val * 20) - 20)
		end
	elseif Global.game_settings.difficulty == "easy_wish" then
		if Global.game_settings.job_plan == -1 or Global.game_settings.job_plan == 1 then
			return ((NoobJoin.settings.min_hours_loud_easy_wish_val * 20) - 20)
		else
			return ((NoobJoin.settings.min_hours_stealth_ovk_val * 20) - 20)
		end
	elseif Global.game_settings.difficulty == "overkill_145" then
		if Global.game_settings.job_plan == -1 or Global.game_settings.job_plan == 1 then
			return ((NoobJoin.settings.min_hours_loud_ovk_val * 20) - 20)
		else
			return ((NoobJoin.settings.min_hours_stealth_ovk_val * 20) - 20)
		end
	end
	return -1
end

function NoobJoin:Send_kick_announce(id, message)
	local peer = managers.network:session():peer(id)
	if peer then
		peer:send("send_chat_message", ChatManager.GAME, message)
		peer:send("send_chat_message", ChatManager.GAME, message) -- Three times, so they could see it
		peer:send("send_chat_message", ChatManager.GAME, message)
	end
end

function NoobJoin:Slow_kick(id, message, user_id)
	if managers.network:session():peer(id)._loaded == true or not Utils:IsInGameState() then
		DelayedCalls:Add("NoobJoin:Delayed_Kick_" .. id .. "_1", 1, function()
			NoobJoin:Send_kick_announce(id, message)
		end)
		DelayedCalls:Add("NoobJoin:Delayed_Kick_" .. id .. "_2", 10, function()
			local session = managers.network._session
			local peer = session:peer(id)
			if peer then
				if user_id == peer:user_id() then
					NoobJoin:Instant_kick(id)
				end
			end
		end)
	else
		NoobJoin.Kick_on_join[id] = {true, message, user_id}
	end
end

function NoobJoin:Instant_kick(id)
	local session = managers.network._session
	local peer = session:peer(id)
	DelayedCalls:Add("NoobJoin:HideKickmessage", 0.2, function()
		NoobJoin.hide_kick = false
	end)
	NoobJoin.hide_kick = true
	if peer and NoobJoin.settings.Toggle == 1 then
		if NoobJoin.settings.remove_type == 1 then
			session:on_peer_kicked(peer, id, 0)
			session:send_to_peers("kick_peer", id, 2)
		elseif NoobJoin.settings.remove_type == 2 then
			session:on_peer_kicked(peer, id, 0)
			session:send_to_peers("kick_peer", id, 0)
		else
			session:on_peer_kicked(peer, id, 2)
			session:send_to_peers("kick_peer", id, 2)
		end
	end
end

function NoobJoin:Kick_Selected_Peer(id, message, user_id, block)
	if Network:is_server() and tonumber(id) ~= 1 then
		if NoobJoin.settings.kick_type == true or block then
			NoobJoin:Instant_kick(id)
		else
			NoobJoin:Slow_kick(id, message, user_id)
		end
	end
end

function NoobJoin:Debug_Message(message, color, message2, message3, message4)
	local num_player_slots = BigLobbyGlobals and BigLobbyGlobals:num_player_slots() or 4
	if not NoobJoin.overlay then
		NoobJoin.overlay = Overlay:newgui():create_screen_workspace() or {}
		NoobJoin.fonttype = tweak_data.menu.pd2_small_font
		NoobJoin.fontsize = tweak_data.menu.pd2_small_font_size
		if RenderSettings.resolution.x >= 600 and RenderSettings.resolution.x < 800 then
			NoobJoin.fontsize = 8
		elseif RenderSettings.resolution.x >= 800 and RenderSettings.resolution.x < 1024 then
			NoobJoin.fontsize = 12
		elseif RenderSettings.resolution.x >= 1024 and RenderSettings.resolution.x < 1280 then
			NoobJoin.fontsize = 16
		else
			NoobJoin.fontsize = 22
		end
		NoobJoin.stats = {}
		NoobJoin.mod = NoobJoin.overlay:panel():text{name = "mod", x = - (RenderSettings.resolution.x/2.1) + 0.5 * RenderSettings.resolution.x, y = - (RenderSettings.resolution.y/4) + 4.7/9 * RenderSettings.resolution.y, text = NoobJoin.Name, font = NoobJoin.fonttype, font_size = NoobJoin.fontsize, color = Color(NoobJoin.Colors[2]), layer = 1}
		local pos = 5
		for i=1, num_player_slots do
			NoobJoin.stats[i] = NoobJoin.overlay:panel():text{name = "name" .. i, x = - (RenderSettings.resolution.x/2.1) + 0.5 * RenderSettings.resolution.x, y = - (RenderSettings.resolution.y/4) + pos/9 * RenderSettings.resolution.y, text = "", font = NoobJoin.fonttype, font_size = NoobJoin.fontsize, color = tweak_data.chat_colors[i], layer = 1}
			pos = pos + 0.3
		end
	end
	NoobJoin.mod:show()
	if not message then
		for i=1,num_player_slots do
			if NoobJoin.Players[i][3] ~= 0 then
				NoobJoin.stats[i]:set_text((NoobJoin.Players[i][3]))
				NoobJoin.stats[i]:show()
			end
		end
	else
		NoobJoin.stats[1]:set_text(message)
		NoobJoin.stats[1]:show()
		if message2 then
			NoobJoin.stats[2]:set_text(message2)
			NoobJoin.stats[2]:show()
		end
		if message3 then
			NoobJoin.stats[3]:set_text(message3)
			NoobJoin.stats[3]:show()
		end
		if message4 then
			NoobJoin.stats[4]:set_text(message4)
			NoobJoin.stats[4]:show()
		end
	end
	DelayedCalls:Add("NoobJoin:Timed_Remove", 5, function()
		if NoobJoin.overlay then
			NoobJoin.mod:hide()
			for i=1,num_player_slots do
				NoobJoin.stats[i]:hide()
			end
		end
	end)
end

function NoobJoin:Skill_cheater(skills, peer, me)
	if NoobJoin.settings.skill_cheats == true or me then
		local total = 0
		for i=1,#skills do
			total = total + tonumber(skills[i])
		end
		if total > 120 then
			return true
		end
		if peer and peer:level() ~= nil then
			if total > (tonumber(peer:level()) + 2 * math.floor(tonumber(peer:level()) / 10)) then
				return true
			end
		end
	end
	return false
end

Hooks:PostHook(MenuManager, "_node_selected", "NoobJoin:Node", function(self, menu_name, node)
	if type(node) == "table" and node._parameters.name == "main" then
		NoobJoin:Show_Update_message()
		local num_player_slots = BigLobbyGlobals and BigLobbyGlobals:num_player_slots() or 4
		for i=1, num_player_slots do
			for j=1,9 do -- Skill printed, cheater, skills for overlay, join time, hours played
				NoobJoin.Players[i][j] = 0
			end
		end
	end
end)
