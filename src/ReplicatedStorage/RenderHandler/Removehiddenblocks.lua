local LocalizationService = game:GetService("LocalizationService")
local self = {}
local f,qf = pcall(require,game.ReplicatedStorage.QuickFunctions)
local f,settings = pcall(require,game.ReplicatedStorage.GameSettings)
function self.HideBlocks(cx,cz,chunks,blockstocheck,libs)--chunks 1 = middle 2 = +x 3 = -x 4 = +z 5 = -z
    local currentblockid 
    qf = qf or libs.QuickFunctions
    settings = settings or libs.GameSettings
    local siz = settings.GridSize
    local function checkblockinch(ch,x,y,z)
        local a = ch[qf.cbt("grid","1d",x,y,z)]
        return a
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
        return walls,ammount
    end
    local function checksurroundingblocks(x,y,z)
        local walls,ammount = IsAnBorder(x,y,z)
        local check = 0
        local sides = {}
        if (not walls["x1"] and checkblockinch(chunks[1],x+1,y,z)) or (walls["x1"] and checkblockinch(chunks[2],x+1,y,z))  then
            check +=1
            sides['x1'] = true
        end
        if (not walls["x-1"] and checkblockinch(chunks[1],x-1,y,z)) or (walls["x-1"] and checkblockinch(chunks[3],x-1,y,z))  then
            check +=1
            sides['x-1'] = true
        end
        if (checkblockinch(chunks[1],x,y+1,z)) then
            check +=1
            sides['y1'] = true
        end
        if (checkblockinch(chunks[1],x,y-1,z))  then
            check +=1
            sides['y-1'] = true
        end
        if (not walls["z1"] and checkblockinch(chunks[1],x,y,z+1)) or (walls["z1"] and checkblockinch(chunks[4],x,y,z+1))  then
            check +=1
            sides['z1'] = true
        end
        if (not walls["z-1"] and checkblockinch(chunks[1],x,y,z-1)) or (walls["z-1"] and checkblockinch(chunks[5],x,y,z-z))  then
            check +=1
            sides['z-1'] = true
        end
    end
    local function can(x,y,z)
        
    end
    for index,data in blockstocheck do
        currentblockid = qf.cbt("1d","grid",cx,cz,index)
    end
end
return self 