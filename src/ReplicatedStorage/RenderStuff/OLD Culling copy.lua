
local self = {}
local f,qf = pcall(require,game.ReplicatedStorage.QuickFunctions)
local f,settings = pcall(require,game.ReplicatedStorage.GameSettings)
local f,debris = pcall(require,game.ReplicatedStorage.Libarys.Debris)
local f,res = pcall(require,game.ReplicatedStorage.ResourceHandler)
function self.GridIsInChunk(cx,cz,x,y,z)
    local ccx,ccz = tonumber(math.floor((x+.5)/settings.ChunkSize.X)),tonumber(math.floor((z+.5)/settings.ChunkSize.X))
    return tonumber(cx) == ccx and tonumber(cz) == ccz
end
local function IsAnBorder(lx,ly,lz,chsiz)
    local walls,ammount = {},0
    if lx+1 >= chsiz.X then
        walls["x1"] = true
        ammount+=1
    end
    if lx-1 <= -1 then
        walls["x-1"] = true
        ammount+=1
    end
    if lz+1 >= chsiz.X  then
        walls["z1"] = true
        ammount+=1
    end
    if lz-1 <= -1 then
        walls["z-1"] = true
        ammount+=1
    end
    return walls,ammount
end
function self.HideBlocks(cx,cz,chunks,blockstocheck,libs)--chunks 1 = middle 2 = +x 3 = -x 4 = +z 5 = -z
    if not blockstocheck then
        blockstocheck =  chunks[1]
    end
    local currentblockid 
    local new = {}
    if libs then
        qf = qf or libs.QuickFunctions
        qf.ADDSETTINGS(libs)
        settings = settings or libs.GameSettings
        debris = libs.Debris
        res = libs.ResourceHandler
    end
    local chsiz:Vector2 = settings.ChunkSize
    local alreadychecked = {{},{},{},{},{}}
    local once = false
    local function checkblockinch(wt,x,y,z)
        local combined = x..','..y..','..z
        if alreadychecked[wt][combined] ~= nil then
            return alreadychecked[wt][combined] 
        end
        local nn = combined
        local a = chunks[wt][nn]
        local transparency = false
        if a then
            if not debris:GetItemData(a) then
                local d = qf.DecompressItemData(a,'T') 
                if  d and res.GetBlock(d) then
                    transparency = res.GetBlock(d).Transparency
                    if transparency and transparency ~= 0 then
                        debris:AddItem(a,transparency,60)
                    else
                        debris:AddItem(a,false,60)
                        transparency = false
                    end
                end
            else
                transparency = debris:GetItemData(a)
                debris:SetTime(a,60)
            end
        end
        if transparency then
            a = false
        end
        alreadychecked[wt][combined] = a
        return a
    end
    --EX: 'Name|s%C:dirt/Orientation|t%0,0,0/Position|0,0,0'
    local function checksurroundingblocks(x,y,z)
        local walls,ammount = IsAnBorder(x,y,z,chsiz)
        local check = 0
        local sides = {}
        --/AirBlocks|t%
        local str,a = "",""
        local function addtorstr(w)
            if str ~= "" then str ..= ',' end
            str..=w
            a..=w
        end
        if (not walls["x1"] and checkblockinch(1,x+1,y,z)) or (walls["x1"] and checkblockinch(2,0,y,z))  then
            check +=1
            sides['x1'] = true--right
            addtorstr(1)
        end 
        if (not walls["x-1"] and checkblockinch(1,x-1,y,z)) or (walls["x-1"] and checkblockinch(3,7,y,z))  then
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
        if (not walls["z1"] and checkblockinch(1,x,y,z+1)) or (walls["z1"] and checkblockinch(4,x,y,0))  then
            check +=1
            sides['z1'] = true--back
            addtorstr(5)
        end
        if (not walls["z-1"] and checkblockinch(1,x,y,z-1)) or (walls["z-1"] and checkblockinch(5,x,y,7))  then
            check +=1
            sides['z-1'] = true--front
            addtorstr(6)
         end
        return check == 6,'/AirBlocks|t%'..a..','..str
    end
    local i = 0
    for index:string,data in blockstocheck do
        if not data then continue end
        i+=1
        
        local x,y,z = unpack(index:split(','))
        -- currentblockid = qf.convertchgridtoreal(cx,cz,x,y,z,true)
        local cann,newstr = checksurroundingblocks(x,y,z)
        new[index] = (not (cann)and data..newstr) or nil
    end
    -- delay:update("1")
    -- print(delay:gettime())
    return new
end
return self 