local LocalizationService = game:GetService("LocalizationService")
local self = {}
local f,qf = pcall(require,game.ReplicatedStorage.QuickFunctions)
local f,settings = pcall(require,game.ReplicatedStorage.GameSettings)
function self.HideBlocks(cx,cz,chunks,blockstocheck,mods)
    local currentblockid 
    qf = qf or mods.QuickFunctions
    settings = settings or mods.GameSettings
    local siz = settings.GridSize
    local function checkblockinch(ch,x,y,z)
        local a = ch[qf.Realto1DBlock(x,y,z)]
        return a
    end
    local function checksurroundingblocks(x,y,z)
        
    end
    local function IsAnBorder(x,y,z)
        local walls,ammount = {},0
        if checkblockinch(blockstocheck+4,x,y,z) == nil then
            walls["x1"] = true
            ammount+=1
        end
        if checkblockinch(blockstocheck-4,x,y,z) == nil then
            walls["x-1"] = true
            ammount+=1
        end
        if checkblockinch(blockstocheck,x,y,z+4) == nil then
            walls["z1"] = true
            ammount+=1
        end
        if checkblockinch(blockstocheck,x,y,z-4) == nil then
            walls["z-1"] = true
            ammount+=1
        end
        return ammount ~=0, walls
    end
    local function can(x,y,z)
        
    end
    for index,data in blockstocheck do
        currentblockid = qf.from1DToReal(cx,cz,index)
    end
end
return self 