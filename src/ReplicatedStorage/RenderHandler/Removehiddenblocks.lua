local LocalizationService = game:GetService("LocalizationService")
local self = {}
local f,qf = pcall(require,game.ReplicatedStorage.QuickFunctions)
local f,settings = pcall(require,game.ReplicatedStorage.GameSettings)
function self.HideBlocks(cx,cz,chunks,blockstocheck,libs)
    local currentblockid 
    qf = qf or libs.QuickFunctions
    settings = settings or libs.GameSettings
    local siz = settings.GridSize
    local function checkblockinch(ch,x,y,z)
        local a = ch[qf.cbt("grid","1d",x,y,z)]
        return a
    end
    local function checksurroundingblocks(x,y,z)
        
    end
    local function IsAnBorder(x,y,z)
        local walls,ammount = {},0
        if qf.GridIsInChunk(cx+1,cz,x,y,z)then
            walls["x1"] = true
            ammount+=1
        end
        if qf.GridIsInChunk(cx-1,cz,x,y,z)then
            walls["x-1"] = true
            ammount+=1
        end
        if qf.GridIsInChunk(cx,cz,x,y,z+1)then
            walls["z1"] = true
            ammount+=1
        end
        if qf.GridIsInChunk(cx,cz,x,y,z-1)then
            walls["z-1"] = true
            ammount+=1
        end
        return ammount ~=0, walls
    end
    local function can(x,y,z)
        
    end
    for index,data in blockstocheck do
        currentblockid = qf.cbt("1d","grid",cx,cz,index)
    end
end
return self 