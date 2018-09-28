local original_feed_system_message = ChatManager.feed_system_message
function ChatManager:feed_system_message(channel_id, message)
	if Network:is_server() then
		if NoobJoin.settings.kick_type == true then
			if NoobJoin.hide_kick == false or not NoobJoin.hide_kick then
				original_feed_system_message(self, channel_id, message)
			end
		else
			original_feed_system_message(self, channel_id, message)
		end
	else
		original_feed_system_message(self, channel_id, message)
	end
end
