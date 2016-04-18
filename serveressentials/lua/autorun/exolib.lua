exolib = {}

function exolib.readCfg(filename, portionid)
	textdata = file.Read(filename)
	portions = string.Explode("-- SPLIT CFG --", textdata)
	if portions[portionid] ~= null then return portions[portionid] end
end
