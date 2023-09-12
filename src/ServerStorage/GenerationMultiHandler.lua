local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local GH = {}
local Worker = {}
local Workers = {}
local SPEICALWorkers = {}
local InProgress = {}
local Index = 0
Worker.__index = Worker
local amtofspecial = 5
local deafultAmount = 3
local Settings = require(game.ReplicatedStorage.GameSettings)
local BehaviorHandler = require(game.ReplicatedStorage.BehaviorHandler)
local ResourceHandler = require(game.ReplicatedStorage.ResourceHandler)
local GenHandler = require(game.ServerStorage.GenerationHandler)
local qf = require(game.ReplicatedStorage.QuickFunctions)
local sharedservice = game:GetService("SharedTableRegistry")
local sharedtable = sharedservice:GetSharedTable("Generation")
local terrian = require(game.ServerStorage.GenerationHandler.TerrianHandler)
local st ={}
local mhworkers = Instance.new("Folder")
mhworkers.Name = "idk"
mhworkers.Parent = game.ServerScriptService

local function SharedToNormal(shared,p)
    if typeof(shared) ~= "SharedTable" then return shared end 
    p = p or {}
    for i,v in shared do
        if typeof(v) == "SharedTable" then
            p[i] = {}
            SharedToNormal(v,p[i])
        else
            p[i] = v
        end
    end
    return p
end
local pdata = {}
function Worker.new(index)
   local clone = script.Parent.Actor:Clone()
   clone.Name = index
   clone.Parent = mhworkers
   clone.MainG.Enabled = true
   clone.DataHandler.Event:connect(function(id,data)
        pdata[id] = data--SharedToNormal(sharedtable[id])
        coroutine.resume(st[id])
        sharedtable[id] = nil
   end)
   return clone
end
local inited = false

function GH:GetWorker(SPEICIAL)
    local Workers = not SPEICIAL and Workers or SPEICALWorkers
    if #Workers == 0 then error("TABLE IS EMPTY") end 
    Index +=1
    if Workers[Index] then
        if not InProgress[Index] or not SPEICIAL  then
            return Workers[Index],Index
        end
        if SPEICIAL and Index <amtofspecial then 
            return Workers[Index],Index
        end
        return self:GetWorker(SPEICIAL)
    else
        Index = 0
        task.wait()
        return self:GetWorker(SPEICIAL)
    end
end
local id = 0
function GH:GetId()
    id += 1
    if st[id] ~= nil then
        return self:GetId()
    elseif id >= 32768 then
        id = 0
        return self:GetId()
    end
    return id 
end
local SPEICALFUNCTIONS = {"ComputeChunk","GetBiomesstuffidkdebug"}
function GH:DoWork(func,...)
    local SPEICIAL = table.find(SPEICALFUNCTIONS,func)
    local c = self:GetId()
    local worker:Actor,idx = GH:GetWorker(SPEICIAL)
    if SPEICIAL then 
        InProgress[idx] = true
    end
    worker:SendMessage("M",c,func,...)
    st[c] = coroutine.running()
    coroutine.yield()
    local data = pdata[c]
     st[c] = nil
     pdata[c] = nil
    if SPEICIAL then 
        InProgress[idx] = nil
    end
    return data
end
function GH:Init(amt)
    amt = amt or deafultAmount
    if inited then warn("GENERATION WAS INITEDED TWICE") return end 
    inited = true
    for i = 1,amt do
        local worker = Worker.new(i)
        table.insert(Workers,worker)
        task.spawn(function()
            repeat
                task.wait()
            until worker.Init.Value == true
            worker:SendMessage('Init',Settings.Seed)
       end)
    end
    for i =1,amtofspecial do
        local worker = Worker.new(i)
        table.insert(SPEICALWorkers,worker)
        task.spawn(function()
            repeat
                task.wait()
            until worker.Init.Value == true
            worker:SendMessage('Init',Settings.Seed,true)
       end)
    end
    return GH
end
local sizex,sizey = Settings.getChunkSize()
local farea3 = (sizex)*(sizey) 
function to3D4x256(index)
    index = tonumber(index) - 1
	local x = index % 4
	index = math.floor(index / 4)
	local y = index % 256
	index = math.floor(index / 256)
	local z = index % 4
	return x, y, z
end
local aa = 4*256
local function to1d4x256(x,y,z)
    return x + y * 4 + z *aa+1
end
local function to1DXZ4x(x,z)
    return x + z *4 + 1
end
local once = false
function GH:InterpolateDensity(cx,cz)
    -- lerp[`{cx},{cz}`] = table.create(Settings.maxChunkSize)
     local tasks,done = 0,0
     local thread = coroutine.running()
     local alldata = {}
     for x =0,1 do
         for z = 0,1 do
             tasks +=1
             local tk = tasks
             task.spawn(function()
                 alldata[tk]=  GH:DoWork("LerpFinalXZ",cx,cz,x,z)
                 done+=1
                 if done == 4 then
                     coroutine.resume(thread)
                 end
             end)
 
         end
     end
     if 4 ~= done then coroutine.yield() end 
          --[[
     local t ,s=  table.create(farea3*8),table.create(8*8)
     debug.profilebegin("InterpolateDensity")
     local t1 = alldata[1]
     local t2 = alldata[2]
     local t3 = alldata[3]
     local t4 = alldata[4]

     local d1 = t1[1]
     local d2 = t2[1]
     local d3 = t3[1]
     local d4 = t4[1]

     local s1 = t1[2]
     local s2 = t2[2]
     local s3 = t3[2]
     local s4 = t4[2]
     for x = 0,3 do
         local fx1 = (x)
         local fx2 = (x+4)
 
         for z = 0,3 do
            local fz1 = (z)
            local fz2 = (z+4)

            local xzidx = x + z *4 + 1
            local xzidx1 = fx1 + fz1 *8 + 1
            local xzidx2 = fx1 + fz2 *8 + 1
            local xzidx3 = fx2 + fz1 *8 + 1
            local xzidx4 = fx2 + fz2 *8 + 1
            
            s[xzidx1] = s1[xzidx]
            s[xzidx2] = s2[xzidx]
            s[xzidx3] = s3[xzidx]
            s[xzidx4] = s4[xzidx]
            -- if  s2[xzidx] == nil then
            --     print(x,z,xzidx,xzidx2)
            -- end

             local idx  =  x  + z *aa+1
             local ide1 =  fx1  + fz1 *farea3+1
             local ide2 =  fx1  + fz2 *farea3+1
             local ide3 =  fx2  + fz1 *farea3+1
             local ide4 =  fx2  + fz2 *farea3+1
 
             for y = 0,255 do
                 local idx255 = idx + y * 4
                 local yof = y * 8
                  t[ide1+yof] = d1[idx255] >0 
                  t[ide2+yof] = d2[idx255]>0 
                  t[ide3+yof] = d3[idx255]>0 
                  t[ide4+yof] = d4[idx255]>0 
             end
         end
     end
    --  for i,v in alldata do
    --      for i,v in v[1] do
    --          t[v.X] =  v.Y>0 and true or false
    --      end
    --      for i,v in v[2] do
    --          s[v.X] = v.Y
    --      end
    --  end
     debug.profileend()
    -- print(s1,s2,s3,s4)
   --  print(s)
   --  lerp[`{cx},{cz}`] = nil]]
     return alldata--t
 end
function GH:Color(alldata2,biome)
    local t = table.create(farea3*8)
   -- lerp[`{cx},{cz}`] = table.create(Settings.maxChunkSize)
    local tasks,done = 0,0
    local thread = coroutine.running()
    local alldata = {}
    for x =0,1 do
        for z = 0,1 do
            tasks +=1
            local i = tasks
            local s = {}
            local holes2 = {}
          --  local d22 = d2 and {}
          --[[
          debug.profilebegin("calculate values")
            for xx =0,3 do
                local x = xx+4*x
                for zz = 0,3 do
                    local z = zz+4*z
                    local xz1 = to1DXZ4x(xx,zz)
                    local xz2 = Settings.to1DXZ(x,z)
                    local d1256 = x + 0 + z *aa+1
                    local to1d = x  + z *farea3+1
                    s[xz1] = surface[xz2]
                    for y = 0,255 do
                        local idx1 =  d1256 +y * 4--to1d4x256(xx,y,zz)
                        local idx2 = to1d+y*8
                        holes2[idx1] = holes[idx2]
                    end
                end
            end
            debug.profileend()]]
            local t = alldata2[i]
            local newhol = {}
            task.spawn(function()
                alldata[i]= terrian.DeCompressVoxels(unpack(GH:DoWork("ColorSection",x,z,t[1],t[2],biome))) --terrian.DeCompressVoxels(unpack(GH:DoWork("ColorSection",x,z,holes2,surface,d1,d22)))
                done +=1
                if 4 == done then
                    coroutine.resume(thread)
                end
            end)
        end
    end
    if 4 ~= done then coroutine.yield() end 
    local t1 = alldata[1]
    local t2 = alldata[2]
    local t3 = alldata[3]
    local t4 = alldata[4]
    debug.profilebegin("y stuff")
    for x = 0,3 do
        local fx1 = (x)
        local fx2 = (x+4)

        for z = 0,3 do
            local fz1 = (z)
            local fz2 = (z+4)
    
            local idx  =  x  + z *aa+1
            local ide1 =  fx1  + fz1 *farea3+1
            local ide2 =  fx1  + fz2 *farea3+1
            local ide3 =  fx2  + fz1 *farea3+1
            local ide4 =  fx2  + fz2 *farea3+1

            for y = 0,255 do
                local idx255 = idx + y * 4
                local yof = y * 8
                 t[ide1+yof] = t1[idx255]
                 t[ide2+yof] = t2[idx255]
                 t[ide3+yof] = t3[idx255]
                 t[ide4+yof] = t4[idx255]
            end
        end
    end
    debug.profileend()
    return t
end
function GH:ComputeChunkS(cx,cz)
    local t = {}
   -- lerp[`{cx},{cz}`] = table.create(Settings.maxChunkSize)
    local tasks,done = 0,0
    local thread = coroutine.running()
    local alldata = {}
    for x =0,1 do
        for z = 0,1 do
            tasks +=1
            local tk = Vector2.new(x,z)
            task.spawn(function()
                alldata[tk]= GH:DoWork("ComputeChunkSection",cx,cz,x,z)
                done +=1
                if 4 == done then
                    coroutine.resume(thread)
                end
            end)
            tasks +=1
        end
    end
    if 4 ~= done then coroutine.yield() end 
    local data = {}
    local base = {}
    local biomes ={}
    local bi 
    local climate2d = {}
    local climate3d = {}
    -- {data,base,bi or biomes,climate2d,climate3d}
    debug.profilebegin("Chunk Data")
    for tk,d in alldata do
        local qx,qz = tk.X,tk.Y
        local x,z = 4*qx,4*qz
        local lx,lz = x/4,z/4
        local to1dxz = terrian.to1dLocalXZ(lx,lz)
        climate2d[to1dxz] = d[4]
        climate3d[to1dxz] = d[5]
        biomes = d[3]
        base[to1dxz] = d[2]
        if bi == nil then
            bi = d[3]
        elseif bi ~= d[3] then
            bi = false
        end
        for y = 0,255,8 do
            local ly = y/8
            local idx = terrian.to1dLocal(lx,ly,lz)
            ly +=1
            data[idx] = d[1][ly]
        end
    end
    debug.profileend()
    return {data,base,bi or biomes,climate2d,climate3d}
end
local farea4 = 4*32
local function to1d4x32(x,y,z)
    return x + y * 4 + z *farea4+1
end
function GH:LerpBiomes(cx,cz,height)
    -- lerp[`{cx},{cz}`] = table.create(Settings.maxChunkSize)
     local tasks,done = 0,0
     local thread = coroutine.running()
     local alldata = table.create(4)
     for x =0,1 do
         for z = 0,1 do
             tasks +=1
             local tk = Vector2.new(x,z)
             task.spawn(function()
                 alldata[tasks]= GH:DoWork("LerpBiomesSection",cx,cz,x,z)
                 done +=1
                 if 4 == done then
                     coroutine.resume(thread)
                 end
             end)
         end
     end
     if 4 ~= done then coroutine.yield() end 
     local b = table.create(8*8)
     debug.profilebegin("biome convert")
     local s1 = alldata[1]
     local s2 = alldata[2]
     local s3 = alldata[3]
     local s4 = alldata[4]

     for x = 0,3 do
         local fx1 = (x)
         local fx2 = (x+4)
 
         for z = 0,3 do
            local fz1 = (z)
            local fz2 = (z+4)

            local xzidx = x + z *4 + 1
            local xzidx1 = fx1 + fz1 *8 + 1
            local xzidx2 = fx1 + fz2 *8 + 1
            local xzidx3 = fx2 + fz1 *8 + 1
            local xzidx4 = fx2 + fz2 *8 + 1
            
            b[xzidx1] = s1[xzidx]
            b[xzidx2] = s2[xzidx]
            b[xzidx3] = s3[xzidx]
            b[xzidx4] = s4[xzidx]

         end
     end
     local d 
     for i,v in b do
        if d == nil then
            d = v
        elseif d and d ~= v then
            d = false
        end
     end
     debug.profileend()
    return d or b
end
function GH:ComputeChunk(cx,cz)
    local data = GH:DoWork("ComputeChunk",cx,cz)
    return data
end
function GH:SmoothTerrian(cx,cz,data)
    return GH:DoWork("SmoothTerrian",cx,cz,data)
end
function GH:CreateTerrain(cx,cz)
    return GH:DoWork("GenerateTerrain",cx,cz)
end
function GH:GenerateSurfaceDensity(cx,cz)
    return GH:DoWork("GenerateSurfaceDensity",cx,cz)
end
function GH:SmoothDensity(cx,cz,data)
    return GH:DoWork("SmoothDensity",cx,cz,data)
end
function GH:GetBiomeValues(x,y,z)
    return GH:DoWork("GetBiomesstuffidkdebug",x,y,z)
end 
function GH:GenerateCaves(cx,cz)
    local sx,sy,sz,ammount,Resolution = GenHandler.GetWormData(cx,cz)
    if sx == nil then return end 
    local data = GH:DoWork("GenerateCaves",cx,cz)
    local new = {}
    for chunk,chdata in data do
        local commaPos = string.find(chunk, ",")
        local cx = tonumber(string.sub(chunk, 1, commaPos - 1))
        local cy = tonumber(string.sub(chunk, commaPos + 1))
        for i,index in chdata do
            local x,y,z = Settings.to3D(index)
            x,y,z = Settings.convertchgridtoreal(cx,cz,x,y,z)
            GenHandler.sphere(new,Resolution,x,y,z)
        end
    end
    return new
end

return setmetatable(GH,{__index =function(self,key)
    GH[key] = function (self,...)
        return GH:DoWork(key,...)
    end
    return  GH[key] 
end})
