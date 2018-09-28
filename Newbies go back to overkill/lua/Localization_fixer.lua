local LocalizationManager_text_orig = LocalizationManager.text -- provided by hollerbach ;)
function LocalizationManager:text(string_id, ...)
	if string_id == nil then
		log("[Crash fixer] LocalizationManager:text error; string_id is nil.")
		string_id = ""
	end
	return LocalizationManager_text_orig (self, string_id, ...) 
end