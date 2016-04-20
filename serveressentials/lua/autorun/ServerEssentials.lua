local exolib = include("exolib.lua")
function makeCfgFile(ply)
	if (file.Exists("serveressentials.txt","DATA")) then
		return
	else
		file.Write("serveressentials.txt", "")
		file.Append("serveressentials.txt","-- ServerEssentials --\nstaffranks = {'superadmin'}\n-- SPLIT CONFIG --\n-- AutoWarn -- \nenabled = true\nracialslurs = {'ban'}\ntimetowarn = 5\nmuteenabled = false\ntimetounmuteawarn = 30\n-- SPLIT CONFIG --\n-- AntiAdminSpam-- \nenabled = true\nAdminSpamID = 5\namounttokick = 5\n-- SPLIT CONFIG --\n-- AutoMute --\nenabled = true\nbannedwords = {}\n-- SPLIT CONFIG --\n-- PsaySpy --\nenabled= true\nalertwords = {'kos','defib','KOS','k0s'}\nwarnenabled = true\nwarntimeramount = 20\n-- SPLIT CONFIG --\n-- AntiChatSpam --\nenabled = true\nhudprintenable = true\nasaytoadminacs = true\nAdmoonID = 5\namounttomute = 5\ntimetounmute = 60\n-- SPLIT CONFIG --")
		print("Config file made in your GarrysMod/Data folder for Server Essentials")
	end
end
function readCfg(portion)
	textdata = file.Read("serveressentials.txt")
	portions = string.Explode("-- SPLIT CONFIG --", textdata)
	if (portion == "ServerEssentials") then return (portions[1])
	elseif (portion == "AutoWarn") then return (portions[2])
	elseif (portion == "AntiAdminSpam") then return (portions[3])
	elseif (portion == "AutoMute") then return (portions[4])
	elseif (portion == "PsaySpy") then return (portions[5])
	elseif (portion == "AntiChatSpam") then return (portions[6])
	end
end
--Auto Warn Code Below
function AutoWarn(ply, text, public)
	if(file.Exists("serveressentials.txt", "DATA")) then
		textdata = readCfg("AutoWarn")
		RunString(textdata)
		if (enabled == true) then
			textdata = string.Explode("\n", textdata)
			for i, line in ipairs(racialslurs) do
				if(line ~= nil and line ~= "") then
				returnedstring, racialslur = string.gsub(text, line, line)
					if (racialslur > 0) then
						RunConsoleCommand("ulx","asay", "(ServerEssentials) has detected use of racial slur(s) by "..ply:Name().." and is about to be warned.")
						timer.Create("warncountdown"..ply:SteamID(), timetowarn, 1, function() RunConsoleCommand("awarn_warn", ply:SteamID(), "(ServerEssentials) Please do not use racial slur(s) in chat.") end)
						if (muteenabled == true) then
							RunConsoleCommand("ulx","mute",ply:Name())
							timer.Create("timetounmutewarn"..ply:SteamID(), timetounmuteawarn, function() RunConsoleCommand("ulx","unmute", ply:Name()) end)
						end
					end
				end
			end
		end
	end
end
--Anti Admin Chat Spam
SpamDetector = {}
function AntiAdminSpam(ply, commandName, translated_args)
	textdata = readCfg("AntiAdminSpam")
	RunString(textdata)
	if (enabled == true) then
		if(commandName == "ulx asay") then
			if(SpamDetector[ply:SteamID()] != nil) then
				SpamDetector[ply:SteamID()] = SpamDetector[ply:SteamID()] + 1
			else
				SpamDetector[ply:SteamID()] = 1
			end
			timer.Create("AntiAdminSpamClear", AdminSpamID, 0, function() SpamDetector = {} end)
			if(SpamDetector[ply:SteamID()] >= amounttokick) then
				ply:Kick("Please do not spam admin chat "..ply:Name().." (ServerEssentials)")
				SpamDetector[ply:SteamID()] = 0
				return false
			end
		end
	end
end
-- PsaySpy
function PsaySpy(ply, commandName, translated_args)
	textdata = readCfg("PsaySpy")
	RunString(textdata)
	if(enabled == true) then
		if(commandName == "ulx psay") then
			ply2 = translated_args[2]
			msg = translated_args[3]
			for i, line in ipairs(alertwords) do
				if(line ~= nil and line ~= "") then
				returnedstring, alertword = string.gsub(msg, line, line)
					if(alertword > 0) then
						if(ply:Alive() == false and ply2:Alive() == true) then
							RunConsoleCommand("ulx","asay","(ServerEssentials) has detected potential ghosting by "..ply:Name().." to "..ply2:Name()..": '"..msg.."'")
							if(warnenabled == true) then
								timer.Create("warntimer"..ply:SteamID(),warntimeramount,1, function() RunConsoleCommand("awarn_warn",ply:SteamID(), "(ServerEssentials) "..ply:Name().." please do not ghost again final warning.") end)
							end
						else
							RunConsoleCommand("ulx","asay","(ServerEssentials) "..ply:Name().." has been detected using a alert word in a psay to "..ply2:Name()..": '"..msg.."'")
						end
					end
				end
			end
		end
	end
end
-- Anti Chat Spam
chatspamdetector = {}
function AntiChatSpam(ply, text, public)
	textdata = readCfg("AntiChatSpam")
	RunString(textdata)
	if(enabled == true) then
		if(chatspamdetector[ply:SteamID()] != nil) then
			chatspamdetector[ply:SteamID()] = chatspamdetector[ply:SteamID()] + 1
		else
			chatspamdetector[ply:SteamID()] = 1
		end
		timer.Create("AntiChatSpamClear", AdmoonID, 0, function() chatspamdetector = {} end)
		if(chatspamdetector[ply:SteamID()] >= amounttomute) then
			RunConsoleCommand("ulx","mute", ply:Name())
			timer.Create("TimeToUnmute"..ply:SteamID(), timetounmute, 1, function() RunConsoleCommand("ulx","unmute",ply:Name()) end)
			if(hudprintenable == true) then
				ply:PrintMessage(HUD_PRINTTALK,"(ServerEssentials) "..ply:Name().." You have been muted for "..timetounmute.." seconds for chat spam.")
			end
			if(asaytoadminacs == true) then
				RunConsoleCommand("ulx","asay","(ServerEssentials) "..ply:Name().." has been muted for chat spam and will be unmuted in "..timetounmute.." seconds.")
			end
			chatspamdetector[ply:SteamID()] = 0
			return(false)
		end
	end
end
--Auto Mute Code Below
function AutoMute(ply, text, public)
	textdata = readCfg("AutoMute")
	RunString(textdata)
		if(enabled == true) then
			for i, line in ipairs(bannedwords) do
				if(line ~= nil and line ~= "") then
					returnedstring, bannedword = string.gsub(text, line, line)
						if(bannedword > 0) then
							RunConsoleCommand("ulx","mute",ply:Name())
							if(printtoplayer == true) then
								ply:PrintMessage(HUD_PRINTTALK,""..ply:Name().." you've been muted for "..mutelength.." seconds.")
							end
							if(printtoadmins == true) then
								RunConsoleCommand("ulx","asay",""..ply:Name().." has been muted for "..mutelength.." seconds for use of a banned word "..text..".")
							end
							timer.Create("timeuntilunmute"..ply:SteamID(), mutelength, 1, function() RunConsoleCommand("ulx","unmute", ply:Name()) end)
						end
				end
				break
			end
		end
end
hook.Add("Initialize", "makeCfgFile", makeCfgFile)
hook.Add("PlayerSay","AutoMute", AutoMute)
hook.Add("PlayerSay","AntiChatSpam", AntiChatSpam)
hook.Add("ULibPostTranslatedCommand", "antiadminspam", AntiAdminSpam)
hook.Add("ULibPostTranslatedCommand", "PsaySpy", PsaySpy)
hook.Add("PlayerSay","AutoWarn", AutoWarn)