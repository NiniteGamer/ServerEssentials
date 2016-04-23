exolib = {}

function exolib.checkPlayerRanks(ranks, players)
	staff = {}
	for i, player in ipairs(players) do
		if table.HasValue(ranks,player:GetNWString("usergroup")) then
			staff[#staff+1] = player
		end
	end
	return staff
end

function exolib.readCfg(filename, portionid)
	textdata = file.Read(filename)
	portions = string.Explode("-- SPLIT CFG --", textdata)
	if portions[portionid] ~= null then return portions[portionid] end
end

function exolib.closestVal(nums, number)
	lowest = nil
	lowestnum = nil
	for i, num in ipairs(nums) do
		if tonumber(num) == nil then print("EXOLIB ERROR: All variables given to closestVal() MUST be numeric.") return nil
		elseif tonumber(number) == nil then print("All variables given to closestVa() MUST be numeric.") return nil
		else
			absval = math.abs(num-number)
			print("DEBUG: "..tostring(absval))
			if lowest == nil then lowest = absval lowestnum = num
			else
				if absval < lowest then lowest = absval lowestnum = num end
			end
		end
		if i >= #nums then return lowestnum end
	end
end

function exolib.getBelow(nums, number, equal) -- if equal is true, then it will return numbers equal to the number argument
	if equal == nil then equal = false end
	numbers = {}
	print(equal)
	for i, num in ipairs(nums) do
		if tonumber(num) == nil then print("EXOLIB ERROR: All variables given to getBelow() MUST be numeric.") return nil
		elseif tonumber(number) == nil then print("EXOLIB ERROR: All variables given to getBelow() MUST be numeric.") return nil
		else
			if equal == false then if num < number then numbers[#numbers+1] = num end
			elseif equal == true then if num <= number then numbers[#numbers+1] = num end end
		end
		if i >= #nums then return numbers end
	end
end

function exolib.gmatchpos(str, subject)
	found = {}
	for i in string.gmatch(str,subject) do
		if found ~= {} and found[#found] ~= nil then j = string.find(str,subject,found[#found]+1)
		else j = string.find(str,subject) print(j) end
		found[#found+1] = j
	end
	if found ~= {} and found ~= nil then return found end
end