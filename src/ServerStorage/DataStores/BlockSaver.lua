local dss = game:GetService("DataStoreService")
local module = {}
local dataHandler = require(game.ReplicatedStorage.DataHandler)
local compresser = require(game.ReplicatedStorage.Libarys.compressor)
local SaveInGroupsOf = 20
local sus,blockdss = pcall(dss.GetDataStore,dss,'Blocks',7)
local Debris = require(game.ReplicatedStorage.Libarys.Debris)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local blockqueue = Debris.CreateFolder('BlockLoading')
function module.GetLargeChunk(x,y)
    local cx =	tonumber(math.floor((x+.5)/SaveInGroupsOf))
    local cy= 	tonumber(math.floor((y+.5)/SaveInGroupsOf))
    return cx,cy
end
function module.clone(t)
    local new = {}
	for i,v in t do
        new[i] = v
	end
    return new
end
function module.Save()
    print("a")
    local stuff = {}
    local t,tt = 0,0
    local thread = coroutine.running()
    local atm = module.clone(dataHandler.LoadedChunks)
    for i,v in atm do t +=1 end 
    for i,v in atm do
        local sx,sy = module.GetLargeChunk(v())
        stuff[sx..','..sy] = stuff[sx..','..sy] or {}
        if t%6 then task.wait() end 
        task.spawn(function()
            stuff[sx..','..sy][tostring(v)] = v:Compress()
            tt += 1
            if tt == t then
                print("passes")
                coroutine.resume(thread)
            end
        end)
    end
    if t ~= 0 and t ~= tt then
        coroutine.yield()
    end
    print("passed1")
    for i,new in stuff do
        if not next(new) then continue end 
        local sus,error = pcall(function()
            blockdss:UpdateAsync(i,function(old)
                if not old then return new end 
                for i,v in new do
                    old[i] = v
                end
                return old 
            end)
        end)
        if not sus then
            warn('Large Chunk:',i,"Failed To Save ERROR:",error)
        end
    end
    print("DoneDebris")
end
local queue = {}
function module.GetChunk(cx,cy)
    local sx,sy = module.GetLargeChunk(cx,cy)
    local str = sx..','..sy
    if queue[str] then
        repeat task.wait() until not queue[str]
    end
    local data = blockqueue:GetItemData(str)
    if not data then
        queue[str] = true
        local ds 
        local sus,error = pcall(function()
            ds = blockdss:GetAsync(str)
        end)
        if not sus then
            warn('Large Chunk:',str,"Failed to get ERROR:",error)
        end
        blockqueue:AddItem(str,(ds or {}),120)
        data = ds or {}
        queue[str] = false
        --print(str,"B")
    else
        blockqueue:SetTime(str,120)
    end
    return data[cx..','..cy]
end
return module  