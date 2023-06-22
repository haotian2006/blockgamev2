
local self = {}
local f,qf = pcall(require,game.ReplicatedStorage.QuickFunctions)
local f,settings = pcall(require,game.ReplicatedStorage.GameSettings)
local f,debris = pcall(require,game.ReplicatedStorage.Libarys.Debris)
local f,res = pcall(require,game.ReplicatedStorage.ResourceHandler)
local f,datahandler = pcall(require,game.ReplicatedStorage.DataHandler)
local chsiz:Vector2 = settings.ChunkSize
local debrisfolder = debris.CreateFolder("Blocks",true)

local function IsAnBorder(lx,ly,lz)
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
function self.HideBlocks(cx,cz,chunks)
    local new = {}
    local i = 0
    debrisfolder:Update()
    local function checkblockinch(wt,x,y,z)
        local combined = Vector3.new(x,y,z)
        local a = chunks[wt][combined]
        local transparency = false
        if not a then return a end 
        local dt = debrisfolder:GetItemData(a)
        if dt == nil then
            local d = qf.DecompressItemData(a)
            d = d and d.T 
            local cb = res.GetBlock(d)
            if  d and cb then
                transparency = cb.Transparency
                if transparency and transparency ~= 0 then
                    debrisfolder:AddItem(a,transparency,60)
                else
                    debrisfolder:AddItem(a,false,60)
                    transparency = false
                end
            end
        else
            transparency = dt
            debrisfolder:SetTime(a,60)
        end
        if transparency then
            a = false
        end
        return a 
    end
    local function checksurroundingblocks(x,y,z)
        local walls,ammount = IsAnBorder(x,y,z)
        local sides = {}
        --/AirBlocks|t%
        local num = 0
    
        if (not walls["x1"] and checkblockinch(1,x+1,y,z)) or (walls["x1"] and checkblockinch(2,0,y,z))  then
            num += 1
        end 
        if (not walls["x-1"] and checkblockinch(1,x-1,y,z)) or (walls["x-1"] and checkblockinch(3,7,y,z))  then
            num += 2
        end
        if (checkblockinch(1,x,y+1,z)) then
            num += 4
        end
        if (checkblockinch(1,x,y-1,z))  then
            num += 8
        end
        if (not walls["z1"] and checkblockinch(1,x,y,z+1)) or (walls["z1"] and checkblockinch(4,x,y,0))  then
            num += 16
        end
        if (not walls["z-1"] and checkblockinch(1,x,y,z-1)) or (walls["z-1"] and checkblockinch(5,x,y,7))  then
            num += 32
         end
         return num == 63,num
    end
    for index:Vector3,data in chunks[1] do
        if not data then continue end
        i+=1
        local x,y,z = index.X,index.Y,index.Z
        local cann,newstr = checksurroundingblocks(x,y,z)
        if newstr then
            data..='/AirBlocks|'..newstr
			--data.AirBlocks = newstr
		end
        new[index] = (not (cann) and data) or nil 
    end
   -- error(new)
    return new
end
return self 