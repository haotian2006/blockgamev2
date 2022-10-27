local LocalizationService = game:GetService("LocalizationService")
local self = {}
local f,qf = pcall(require,game.ReplicatedStorage.QuickFunctions)
local f,settings = pcall(require,game.ReplicatedStorage.GameSettings)
function self.HideBlocks(cx,cz,chunks,blockstocheck,libs)--chunks 1 = middle 2 = +x 3 = -x 4 = +z 5 = -z
    local currentblockid 
    local new = {}
    qf = qf or libs.QuickFunctions
    settings = settings or libs.GameSettings
    local siz = settings.GridSize
    local acas = 0
    local alreadychecked = {{},{},{},{},{}}
    local function checkblockinch(wt,x,y,z)
        if not qf.GridIsInChunk(cx,cz,x,y,z) and wt ==1 then
            return false
        end
        if alreadychecked[wt][x..','..y..','..z] then
            return alreadychecked[wt][x..','..y..','..z]
        end
        acas+=1 
        local nn = tostring(qf.cbt("grid","1d",x,y,z))
        local a = chunks[wt][nn]
        alreadychecked[wt][x..','..y..','..z] = a
        return a
    end
    local function IsAnBorder(x,y,z)
        local walls,ammount = {},0
        if not qf.GridIsInChunk(cx,cz,x+1,y,z)then
            walls["x1"] = true
            ammount+=1
        end
        if not qf.GridIsInChunk(cx,cz,x-1,y,z)then
            walls["x-1"] = true
            ammount+=1
        end
        if not qf.GridIsInChunk(cx,cz,x,y,z+1)then
            walls["z1"] = true
            ammount+=1
        end
        if not qf.GridIsInChunk(cx,cz,x,y,z-1)then
            walls["z-1"] = true
            ammount+=1
        end
        return walls,ammount
    end
    local function checksurroundingblocks(x,y,z)
        local walls,ammount = IsAnBorder(x,y,z)
        local check = 0
        local sides = {}
        if (not walls["x1"] and checkblockinch(1,x+1,y,z)) or (walls["x1"] and checkblockinch(2,x+1,y,z))  then
            check +=1
            sides['x1'] = true
        end
        if (not walls["x-1"] and checkblockinch(1,x-1,y,z)) or (walls["x-1"] and checkblockinch(3,x-1,y,z))  then
            check +=1
            sides['x-1'] = true
        end
        if (checkblockinch(1,x,y+1,z)) then
            check +=1
            sides['y1'] = true
        end
        if (checkblockinch(1,x,y-1,z))  then
            check +=1
            sides['y-1'] = true
        end
        if (not walls["z1"] and checkblockinch(1,x,y,z+1)) or (walls["z1"] and checkblockinch(4,x,y,z+1))  then
            check +=1
            sides['z1'] = true
        end
        if (not walls["z-1"] and checkblockinch(1,x,y,z-1)) or (walls["z-1"] and checkblockinch(5,x,y,z-1))  then
            check +=1
            sides['z-1'] = true
        end
        return check == 6
    end
    local function can(x,y,z)
        return checksurroundingblocks(x,y,z)
    end
    for index,data in blockstocheck do
        if not data then continue end
        currentblockid = qf.cbt("1d","grid",cx,cz,index)
        new[index] = (not (can(currentblockid.X,currentblockid.Y,currentblockid.Z) )and data) or nil
    end
    return new
end
return self 