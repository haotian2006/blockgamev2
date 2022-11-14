local LocalizationService = game:GetService("LocalizationService")
local self = {}
local f,qf = pcall(require,game.ReplicatedStorage.QuickFunctions)
local f,settings = pcall(require,game.ReplicatedStorage.GameSettings)
function self.HideBlocks(cx,cz,chunks,blockstocheck,libs)--chunks 1 = middle 2 = +x 3 = -x 4 = +z 5 = -z
    if type(chunks) == "string" then
        chunks = game.HttpService:JSONDecode(chunks)
    end
    if not chunks then
        chunks = {}
        chunks[1] = blockstocheck
    end
    if not blockstocheck then
        blockstocheck =  chunks
        local p = chunks
        chunks = {p}
    end
    local currentblockid 
    local new = {}
    if libs then
        qf = qf or libs.QuickFunctions
        qf.ADDSETTINGS(libs)
        settings = settings or libs.GameSettings
    end
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
        local nn = tostring(qf.cv3type("string",qf.cbt("grid","chgrid",x,y,z)))

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
    --EX: 'Name|s%Cubic:dirt/Orientation|t%0,0,0/Position|0,0,0'
    local function checksurroundingblocks(x,y,z)
        local walls,ammount = IsAnBorder(x,y,z)
        local check = 0
        local sides = {}
        --/AirBlocks|t%
        local str,a = "",""
        local function addtorstr(w)
            if str ~= "" then str ..= ',' end
            str..=w
            a..=w
        end
        if (not walls["x1"] and checkblockinch(1,x+1,y,z)) or (walls["x1"] and checkblockinch(2,x+1,y,z))  then
            check +=1
            sides['x1'] = true--right
            addtorstr(1)
        end
        if (not walls["x-1"] and checkblockinch(1,x-1,y,z)) or (walls["x-1"] and checkblockinch(3,x-1,y,z))  then
            check +=1
            sides['x-1'] = true--left
            addtorstr(2)
        end
        if (checkblockinch(1,x,y+1,z)) then
            check +=1
            sides['y1'] = true--up
            addtorstr(3)
        end
        if (checkblockinch(1,x,y-1,z))  then
            check +=1
            sides['y-1'] = true--down
            addtorstr(4)
        end
        if (not walls["z1"] and checkblockinch(1,x,y,z+1)) or (walls["z1"] and checkblockinch(4,x,y,z+1))  then
            check +=1
            sides['z1'] = true--back
            addtorstr(5)
        end
        if (not walls["z-1"] and checkblockinch(1,x,y,z-1)) or (walls["z-1"] and checkblockinch(5,x,y,z-1))  then
            check +=1
            sides['z-1'] = true--front
            addtorstr(6)
        end
        return check == 6,'/AirBlocks|t%'..a..','..str
    end
    local function can(x,y,z)
        local a,b = checksurroundingblocks(x,y,z)
        return  a,b
    end
    local i = 0
    for index,data in blockstocheck do
        if not data then continue end
        i+=1
        currentblockid = qf.cbt("chgrid","grid",cx,cz,qf.cv3type("tuple",index))
        local cann,newstr = can(currentblockid.X,currentblockid.Y,currentblockid.Z)
        new[index] = (not (cann)and data..newstr) or nil
        --if i%2000 == 0 then task.wait() end
    end
    return new
end
return self 