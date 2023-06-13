local types = require(script.Types)
local rs = game.ReplicatedStorage
local mod = {
	Math = "Libarys.MathFunctions",
	Debris = "Libarys.Debris",
	Compresser = "Libarys.compressor",
	Manager = "Managers",
	DataHandler = "DataHandler",
	Behaviors = "BehaviorHandler", 
	Resources = "ResourceHandler", 
	Settings = "GameSettings",
	Ray = "Ray",
	Functions = "QuickFunctions",
	Remote = "Libarys.ModingRemote",
	AnimationController = "AnimationController",
	ItemHandler = "ItemHandler",
}
export type AutoFill =  {
	Math:types.Math,
	Remote:types.Remote,
	Debris : types.Debris,
	Compresser : types.Compresser,
	Manager : types.Manager,
	DataHandler : types.DataHandler,
	Behaviors : types.Behaviors, 
	Resources : types.Resources, 
	Settings : types.Settings,
	Ray : types.Ray,
	Functions : types.Functions,
	AnimationController : types.AnimationController,
	ItemHandler : types.ItemHandler ,

}

local function getInstanceFromPath(path)
	local split = path:split('.')
	local current = rs
	for i,v in split do
		current = current:FindFirstChild(v)
		if not current  then
			return nil
		end
	end
	return current
end
for i,v in mod do
	local pass,lib = pcall(require,getInstanceFromPath(v));
	if pass then     
		mod[i] = lib
	end
end
function mod:GetModule(name)
	return mod[name]
end
return mod