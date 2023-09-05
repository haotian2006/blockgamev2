local stuff = {}
local HttpService = game:GetService("HttpService")
local runservice = game:GetService("RunService")
local IsClient = runservice:IsClient()
local compressor = require(game.ReplicatedStorage.Libarys.compressor)


function stuff.Compress(data)
	local functions =compressor.compress
	data = HttpService:JSONEncode(data)
	return functions(data)
end
function stuff.DeCompress(data)
	local functions = compressor.decompress
	data = functions(data)
	return HttpService:JSONDecode(data)
end
function stuff.Cull(chunks,ref)
	return culling.HideBlocks(chunks,ref)
end
return stuff