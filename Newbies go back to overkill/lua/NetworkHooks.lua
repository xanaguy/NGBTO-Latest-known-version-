if RequiredScript == "lib/network/base/networkpeer" then

	Hooks:PostHook(HostNetworkSession, "init", "NoobJoin:Stuff", function(self, ...)
		for k, v in ipairs(NoobJoin.blacklist or {}) do
			self._kicked_list[v] = true
		end
	end)

	Hooks:Add("NetworkManagerOnPeerAdded", "NoobJoin:PeerAdded", function(peer, peer_id)
		NoobJoin:PlayerJoin(peer_id)
	end)

	Hooks:Add("BaseNetworkSessionOnLoadComplete", "NoobJoin:LoadComplete", function(peer, id)
		NoobJoin.LoadCompleted = true
		DelayedCalls:Add("NoobJoin:Skkils_" .. tostring(id), 0.5 , function()
			if managers.network._session and #managers.network:session():peers() > 0 then
				NoobJoin:Skills(id)
				for i=1,#NoobJoin.synced do
					NoobJoin:Message_Receive(NoobJoin.synced[i][1], NoobJoin.synced[i][2])
				end
				for _, peer in pairs(managers.network:session():peers()) do
					NoobJoin:Player_Announce(peer)
				end
			end
		end)
	end)

	Hooks:Add("BaseNetworkSessionOnPeerRemoved", "NoobJoin:PeerRemoved", function(peer, peer_id, reason)
		for j=1,9 do -- Skill printed, cheater, skills for overlay, join time, hours played
			NoobJoin.Players[peer_id][j] = 0
			if NoobJoin.Kick_on_join[1] == true then
				NoobJoin.Kick_on_join[1] = false
			end
		end
	end)

	Hooks:PostHook(NetworkPeer, "mark_cheater", "NoobJoin:CheaterCaught", function(self, reason, auto_kick)
		if NoobJoin.settings.ingame_anticheat == true and self:id() ~= managers.network:session():local_peer():id() then
			local message = string.format("%s: %s",  self:name(), managers.localization:text("pd_anticheat_self"))
			NoobJoin:Message_Receive(message, 1)
			NoobJoin:Add_Cheater(self:user_id(), self:name(), message)
		end
	end)

	Hooks:PostHook(NetworkPeer, "set_outfit_string", "NoobJoin:SetOutfit", function(self, outfit_string, outfit_version, outfit_signature)
		DelayedCalls:Add("Skills" .. tostring(self:id()), 0.5 , function()
			NoobJoin:Skills(self:id())
		end)
	end)

	Hooks:PostHook(NetworkPeer, "set_loading", "NoobJoin:Loaded", function(self, state)
		if self._loaded == true then
			if Utils:IsInGameState() then
				NoobJoin:Join_Message(self:id())
			end
			if NoobJoin.Kick_on_join[self:id()] then
				if NoobJoin.Kick_on_join[self:id()][1] == true then
					NoobJoin:Slow_kick(self:id(), NoobJoin.Kick_on_join[self:id()][2], NoobJoin.Kick_on_join[self:id()][3])
				end
			end
		end
	end)
end

if RequiredScript == "lib/network/matchmaking/networkmatchmakingsteam" then
	local _is_server_ok_original = NetworkMatchMakingSTEAM.is_server_ok
	function NetworkMatchMakingSTEAM:is_server_ok(friends_only, room, ...)
		for _,line in pairs(NoobJoin.blacklist) do
			if line == room then
				return false
			end
		end
		return _is_server_ok_original(self, friends_only, room, ...)
	end
end

if RequiredScript == "lib/network/base/basenetworksession" then
	Printed = false
	Current_time = 0
	Hooks:PostHook(BaseNetworkSession, "on_set_member_ready", "NoobJoin:Deployables", function(self, peer_id, ready, state_changed, from_network)
			NoobJoin:Deployables_Lookup(peer_id)
	end)

	Hooks:PostHook(BaseNetworkSession, "on_statistics_recieved", "NoobJoin:Stats", function(self, peer_id, peer_kills, peer_specials_kills, peer_head_shots, accuracy, downs)
		if Printed == false then
			Printed = true
			Current_time = managers.game_play_central and managers.game_play_central:get_heist_timer() or 0
			DelayedCalls:Add("NoobJoin:Statistics_message", 0.5, function()
				if NoobJoin.settings.Stats_Print == true then
					local message = managers.localization:text("Newbie_Statistics") .. ":" .. " " .. managers.localization:text("Newbie_Kills") .. " | " .. managers.localization:text("Newbie_Kill_Per_Minute") .. " | " .. managers.localization:text("Newbie_Spec_Kills") .. " | " .. managers.localization:text("Newbie_Headshots") .. " | " .. managers.localization:text("Newbie_Accuracy") .. " | " .. managers.localization:text("Newbie_Downs")
					NoobJoin:Message_Receive(message, 2)
				end
			end)
		end
		DelayedCalls:Add("NoobJoin:Statistics_message_peer_" .. tostring(peer_id) , 0.7, function()
			if NoobJoin.settings.Stats_Print == true then
				local peer = managers.network:session():peer(peer_id)
				local kpm = peer_kills
				if Current_time > 60 and peer_kills > 0 then
					kpm =(math.floor(((peer_kills / ((Current_time/60)-(NoobJoin.Players[peer_id][4]/60))) + 1/2)/1) * 1)
				end
				if peer:has_statistics() then
					local message = peer:name() .. " | K:" .. peer_kills .. " | KPM:" .. kpm .. " | S/K:" .. peer_specials_kills .. " | H:" .. peer_head_shots .. " | A:" .. accuracy .. " % | D:" .. downs .. " "
					NoobJoin:Message_Receive(message, 2)
				end
			end
		end)
	end)
end

if RequiredScript == "lib/managers/hudmanagerpd2" then
	Hooks:PostHook(HUDManager, "set_slot_outfit", "NoobJoin:Detection", function(self, peer_id, criminal_name, outfit, ...)
		NoobJoin.Players[peer_id][7] = tonumber(string.format("%.0f", managers.blackmarket:get_suspicion_offset_of_outfit_string(outfit, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75) * 100))
	end)
end

if RequiredScript == "lib/managers/playermanager" then
	Hooks:PostHook(PlayerManager, "set_synced_deployable_equipment", "NoobJoin:DeployablesSwitch", function(self, peer, deployable, amount)
		if Utils:IsInHeist() and NoobJoin.settings.Toggle == 1 and peer:id() ~= 1 and Network:is_server() then
			NoobJoin:Deployables(peer:id(), deployable, amount)
		end
	end)
end
