exolib = include("exolib.lua")

function configInit()
	-----------------------------Config File-----------------------------
	stafftable = {'superadmin', 'manager', 'managercust', 'managercustrainbow', 'director', 'headdev', 'dev', 'mod', 'modcust', 'modcustrainbow', 'admin', 'admincust', 'adminrainbowcust', 'owner', 'chiefdirector', 'trailmod', 'donormod', 'dmodcust', 'dmodcustrainbow','senioradmin'}
	-----------------------------AutoCensor-----------------------------
	autocensorenabled = true 
	bannedwords = {'fag', 'nigger', 'nigga', 'niger'}
	acwarnenabled = false
	timetowarnac = 10 -- In seconds
	acmuteenabled = true
	timetounmuteac = 30 -- In seconds
	-----------------------------Anti Admin Chat Spam-----------------------------
	antiadminspamenabled = true
	resetadminspam = 5
	amounttokick = 8
	-----------------------------Ghoster Buster-----------------------------
	ghosterbusterenabled = true
	gbwarnenabled = true
	alertwords = {'kos','defib','kill','avenge','revive','k0s'}
	warntimeramountgb = 30
	psaysee = {'manager', 'managercust', 'managercustrainbow', 'director', 'headdev', 'owner', 'chiefdirector', 'superadmin','senioradmin'}
	psayseeenabled = false
	-----------------------------Anti Chat Spam-----------------------------
	antichatspamenabled = true
	timetochatspamreset = 5
	amounttomute = 10
	timetounmute = 20
	hudprintenable = true
	-----------------------------Karma Cheat Detector-----------------------------
	karmacheatdetectenabled = true
	karmalimit = 1000
	timetokick = 10
	timetoban = 10
	lengthofban = 1
	autokick = true
	autoban = false
	-----------------------------Karma Checker-----------------------------
	karmacheckerenabled = true
	printtoadminskarma = false
	printkarmatoplayer = false
	-----------------------------Anti Radio Spam-----------------------------
	antiradiospamenabled = true
	timetoradiospamreset = 10
	radiospamlimit = 8
	radiospamwarn = true
	radiospamwarnlimit = 12
	-----------------------------GhosterBuster Stop-----------------------------
	gbdisabletable = {'admin', 'admincust', 'adminrainbowcust', 'manager', 'managercust', 'managercustrainbow', 'director', 'dev', 'headdev', 'chiefdirector', 'owner', 'senioradmin', 'superadmin'}
end
hook.Add("Initialize","configinit", configInit)

function autoCensor(ply, text, public)
	if (autocensorenabled == true) then
		for i, line in ipairs(bannedwords) do
			if(line ~= nil and line ~= "") then
			returnedstring, bannedword = string.gsub(string.lower(text), line, line)
				if (bannedword > 0) then
					staff = exolib.checkPlayerRanks(stafftable,player.GetAll())
					for i, line in ipairs(staff) do end
					for i, player in ipairs(staff) do return(true) end
					RunConsoleCommand("ulx","asay", "ServerEssentials: has detected use a banned word by "..ply:Name().."")
					if (acwarnenabled == true) then
						timer.Create("warncountdown"..ply:SteamID(), timetowarnac, 1, function() RunConsoleCommand("awarn_warn", ply:SteamID(), "ServerEssentials: "..warnreasonac) end)
					end
					if (acmuteenabled == true) then
						RunConsoleCommand("ulx","mute",ply:Name())
						timer.Create("timetounmutewarn"..ply:SteamID(), timetounmuteac, function() RunConsoleCommand("ulx","unmute", ply:Name()) end)
					end
				end
			end
		end
	end
end
hook.Add("PlayerSay","AutoCensor", autoCensor)

SpamDetector = {}
function antiadminSpam(ply, commandName, translated_args)
	if (antiadminspamenabled == true) then
		if ply:IsValid() then
			if(commandName == "ulx asay") then
				if(SpamDetector[ply:SteamID()] != nil) then
					SpamDetector[ply:SteamID()] = SpamDetector[ply:SteamID()] + 1
				else
					SpamDetector[ply:SteamID()] = 1
				end
				timer.Create("AntiAdminSpamClear", resetadminspam, 0, function() SpamDetector = {} end)
				if(SpamDetector[ply:SteamID()] >= amounttokick) then
					if(kickenabled == true) then
						ply:Kick("ServerEssentials: has detected chat spam by you "..ply:Name().." you've been automatically disconnected from the server.")
						SpamDetector[ply:SteamID()] = 0
					else
						ply:PrintMessage(HUD_PRINTTALK,"Please refrain from spamming admin chat the staff team will get to you when it's your turn.")
					end
				end
			end
		end
	end
end
hook.Add("ULibPostTranslatedCommand", "antiadminspam", antiadminSpam)

function disablepreRound()
	round = false
end
hook.Add("TTTPrepareRound","disablepreround", disablepreRound)

function disableendRound()
	round = false
end
hook.Add("TTTEndRound","disableendRound", disableendRound)

function enableRound()
	round = true
end
hook.Add("TTTBeginRound","enabledround",enableRound)

function ghosterBuster(ply, commandName, translated_args)
	staff = exolib.checkPlayerRanks(stafftable,player.GetAll())
	for i, line in ipairs(staff) do end
	if(ghosterbusterenabled == true) then
		if round == true then
			if(commandName == "ulx psay") then
				ply2 = translated_args[2]
				msg = translated_args[3]
				for i, line in ipairs(alertwords) do
					if(line ~= nil and line ~= "") then
					returnedstring, alertword = string.gsub( string.lower(msg), line, line)
						if(alertword > 0) then
							staff = exolib.checkPlayerRanks(stafftable,player.GetAll())
							for i, line in ipairs(staff) do end
							for i, player in ipairs(staff) do return(true) end
							if(ply:Alive() == false and ply2:Alive() == true) then
								for i, player in ipairs(staff) do player:PrintMessage(HUD_PRINTTALK,"[ServerEssentials]Detected potential ghosting by "..ply:Name().." to "..ply2:Name()..": '"..msg.."'") end
								print("WarnCheckw")
								if(gbwarnenabled == true) then
									timer.Create("warntimer"..string.lower(ply:Name()),warntimeramountgb,1, function() RunConsoleCommand("awarn_warn",ply:SteamID(), "[ServerEssentials]"..ply:Name().." please do not ghost with other players you've been warned.") end)
								end
							elseif (ply:IsSpec() == true and ply2:Alive() == true) then
								for i, player in ipairs(staff) do player:PrintMessage(HUD_PRINTTALK,"[ServerEssentials]has detected potential ghosting by "..ply:Name().." to "..ply2:Name()..": '"..msg.."'") end
								if(gbwarnenabled == true) then
									timer.Create("warntimer"..string.lower(ply:Name()),warntimeramountgb,1, function() RunConsoleCommand("awarn_warn",ply:SteamID(), "[ServerEssentials]"..ply:Name().." please do not ghost with other players you've been warned.") end)
								end
							else
								for i, player in ipairs(staff) do player:PrintMessage(HUD_PRINTTALK,"[ServerEssentials]"..ply:Name().." has been detected using a alert word in a psay to "..ply2:Name()..": '"..msg.."'") end
								print("alertwordsaid")
							end
						break end
					end
					canseepsay = exolib.checkPlayerRanks(psaysee,player.GetAll())
					for i, line in ipairs(canseepsay) do end
					for i, player in ipairs(canseepsay) do return(true) end
					if(psayseeenabled == true) then
						if(alertword > 0) then
							return
						else
							for i, player in ipairs(canseepsay) do player:PrintMessage(HUD_PRINTTALK,"[ServerEssentials]"..ply:Name().." to "..ply2:Name()..": '"..msg.."'") end
						end
					break end
				end
			end
		else
			return(false)
		end
	end
end
hook.Add("ULibPostTranslatedCommand", "PsaySpy", ghosterBuster)

chatspamdetector = {}
function antichatSpam(ply, text, public)
	if(antichatspamenabled == true) then
		if(chatspamdetector[ply:SteamID()] != nil) then
			chatspamdetector[ply:SteamID()] = chatspamdetector[ply:SteamID()] + 1
		else
			chatspamdetector[ply:SteamID()] = 1
		end
		timer.Create("AntiChatSpamClear", timetochatspamreset, 0, function() chatspamdetector = {} end)
		if(chatspamdetector[ply:SteamID()] >= amounttomute) then
			RunConsoleCommand("ulx","mute", ply:Name())
			timer.Create("TimeToUnmute"..ply:SteamID(), timetounmute, 1, function() RunConsoleCommand("ulx","unmute",ply:Name()) end)
			if(hudprintenable == true) then
				ply:PrintMessage(HUD_PRINTTALK,"[ServerEssentials]"..ply:Name().." You have been muted for "..timetounmute.." seconds for chat spam.")
			end
			if(asaytoadminacs == true) then
				RunConsoleCommand("ulx","asay","[ServerEssentials]"..ply:Name().." has been muted for chat spam and will be unmuted in "..timetounmute.." seconds.")
			end
			chatspamdetector[ply:SteamID()] = 0
			return(false)
		end
	end
end
hook.Add("PlayerSay","ACS",antichatSpam)

function karmaChecker(ply)
	if(karmacheckerenabled == true) then
		if(printkarmatoplayer == true) then
			ply:PrintMessage(HUD_PRINTTALK, "[ServerEssentials]"..ply:Name().." you currently have "..math.Round(ply:GetLiveKarma(), 0).." karma")
		end
		if(printtoadminskarma == true) then
			if ply:GetLiveKarma() <= 500 then
				RunConsoleCommand("ulx","asay","[ServerEssentials]"..ply:Name().." has "..math.Round(ply:GetLiveKarma(),0).." karma left.")
			end
		end
	end
end
hook.Add("PlayerSpawn","KarmaPenatlyChecker", karmaChecker) 

function karmacheatDetector(ply)
	if(karmacheatdetectenabled == true) then
		if(ply:GetLiveKarma() > karmalimit) then
			RunConsoleCommand("ulx","asay","(ServerEssentials) has detected potential cheating by "..ply:Name().." they have more than the allowed karma limit.")
			if(autokick == true) then
				timer.Create("karmacheatkicktimer", timetokick, 1, function() RunConsoleCommand("ulx","kick",ply:SteamID(),"[ServerEssentials]Detected you're using possible cheats/hacks you've been automatically kicked from the game.") end)
			end
			if(autoban == true) then
				timer.Create("karmacheatbantimer", timetoban, 1, function() RunConsoleCommand("ulx","banid",ply:SteamID(),lengthofban,"[ServerEssentials]Detected you're using possible cheats/hacks you've been automatically banned from the game. You've been banned for "..lengthofban.. " minute(s)") end)
			end
		end
	end
end
hook.Add("PlayerSpawn","KarmaCheats", karmacheatDetector)

radiospamdetector = {}
function antiradioSpam(ply, cmd_name, cmd_target)
	if(antiradiospamenabled == true) then
		if(radiospamdetector[ply:SteamID()] != nil) then
			radiospamdetector[ply:SteamID()] = radiospamdetector[ply:SteamID()] + 1
		else
			radiospamdetector[ply:SteamID()] = 1
		end
		timer.Create("antiradiospamtimer", timetoradiospamreset, 0, function() radiospamdetector = {} end)
		if(radiospamdetector[ply:SteamID()] >= radiospamlimit) then
			ply:PrintMessage(HUD_PRINTTALK,"Please do not spam chat with radio commands.")
			timer.Create("antiradiospamdecay", timetoradiospamreset, 0, function() radiospamdetector = {} end)
			if(radiospamwarn == true) then
				if(radiospamdetector[ply:SteamID()] >= radiospamwarnlimit) then
					RunConsoleCommand("awarn_warn",ply:SteamID(),"[ServerEssentials]"..ply:Name().." please do not spam chat with radio commands.")
					radiospamdetector[ply:SteamID()] = 0
				end
			end
		end
	end
end
hook.Add("TTTPlayerRadioCommand","antiradiospam", antiradioSpam)

function serveressentialschat(ply, text, public)
	if(string.sub( string.lower(text), 1, 21) == "!serveressentialsinfo") then
		PrintMessage(HUD_PRINTTALK, "The server is running ServerEssentials version 1.2.4")
		return(false)
	end
end
hook.Add("PlayerSay","serveressnetialschatcommand", serveressentialschat)

function chatCommand(ply, text, public)
    if (string.sub( string.lower(text), 1, 8) == "!gb_stop" and table.HasValue(stafftable,ply:GetNWString("usergroup"))) then
            args = text:gsub("!gb_stop ","")
            if player == nil then return true end
            if (timer.Exists("warntimer"..args) == true) then
                ply:PrintMessage(HUD_PRINTTALK,"Succesfully removed the autowarn timer on "..args.."!")
                timer.Remove("warntimer"..args)
            else
                ply:PrintMessage(HUD_PRINTTALK,"There is no active autowarn timer for the player "..args.."!")
            end
        return(false)
    end
end
hook.Add("PlayerSay", "chatCommand", chatCommand)

function ghosterbusterStop(ply, text, public)
	if(string.sub( string.lower(text), 1, 12) == "!gb_disable" and table.HasValue(gbdisabletable,ply:GetNWString("usergroup"))) then
		if(ghosterbusterenabled == true) then
			ghosterbusterenabled = false
			ply:PrintMessage(HUD_PRINTTALK,"[ServerEssentials]You've successful disabled GhosterBuster")
			ServerLog("Staff member "..ply:Name().." has disabled GhosterBuster\n")
		else
			ply:PrintMessage(HUD_PRINTTALK,"[ServerEssentials]GhosterBuster is already disabled")
		end
		return(false)
	end
end
hook.Add("PlayerSay", "ghosterbusterStop", ghosterbusterStop)

function ghosterbusterStart(ply, text, public)
	if(string.sub( string.lower(text), 1, 9) == "!gb_start" and table.HasValue(gbdisabletable,ply:GetNWString("usergroup"))) then
		if(ghosterbusterenabled == false) then
			ghosterbusterenabled = true
			ply:PrintMessage(HUD_PRINTTALK,"[ServerEssentials]You've successfully started GhosterBuster")
			ServerLog("Staff member "..ply:Name().." has enabled GhosterBuster\n")
		else
			ply:PrintMessage(HUD_PRINTTALK,"[ServerEssentials]GhosterBuster is already enabled")
		end
		return(false)
	end
end
hook.Add("PlayerSay", "ghosterbusterstart", ghosterbusterStart)