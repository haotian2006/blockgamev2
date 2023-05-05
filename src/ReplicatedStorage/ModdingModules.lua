local rs = game.ReplicatedStorage

export type Types = {
    Math : {
        newPoint : <number>(x:number,y:number) -> ()
    },
}
local a:Types
local toRequire = {
    Math = rs.Libarys.MathFunctions,Debris = rs.Libarys.Debris,Compresser = rs.Libarys.compressor,Manager = rs.Managers,
    DataHandler = rs.DataHandler,Behaviors = rs.BehaviorHandler, Resources = rs.ResourceHandler, Settings = rs.GameSettings,Ray = rs.Ray,Functions = rs.QuickFunctions,
    Remote = rs.BridgeNet,AnimationController = rs.AnimationController,ItemHandler = rs.ItemHandler 
}
for i,v in toRequire do
    toRequire[i] = require(v)
end
function toRequire:GetModule(name)
    return self[name]
end
return toRequire