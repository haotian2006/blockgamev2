local qf = require(game.ReplicatedStorage.QuickFunctions)
local self = {}
--<Both
self.LoadedChunks = {}
self.LoadedEntities = {}
self.AmmountOfEntities = 0
--<Client Only
self.LocalPlayer = {}
self.GLocalPlayer = {}
--<Server Only
self.CompressedChunks = {}
self.Players = {} 

local multihandeler = require(game.ReplicatedStorage.MultiHandler)
local LocalizationService = game:GetService("LocalizationService")
local runservice = game:GetService("RunService")
local ChunkObj = require(game.ReplicatedStorage.Chunk)
local compresser = require(game.ReplicatedStorage.compressor) 
local settings = require(game.ReplicatedStorage.GameSettings)
function self.AddEntity(uuid:string,address:table)
    self.AmmountOfEntities += 1
    if type(uuid) == "table" then
        self.LoadedEntities[uuid.Id] = uuid
    else
        self.LoadedEntities[uuid] = address or warn(uuid,"Does not have data")
    end
end
local function round(x)
    return math.floor(x+.5)
end
local function round2(x)
    return math.round(x)
end
function self.RemoveEntity(uuid)
    self.AmmountOfEntities -= 1
    self.LoadedEntities[uuid] = nil
end
function self.EntitiesinR(x,y,z,r,ConvertToClient )
    x,y,z,r = x or 0, y ,z or 0 ,r or 0
    local vector = Vector3.new(x,y or 0,z)
    local entitys = {}
    for i,v in self.LoadedEntities do
        if not y then vector = Vector3.new(x,v.Position.Y,z) end 
        if (v.Position - vector).Magnitude <= r then
            entitys[i] = not ConvertToClient and v or v:ConvertToClient()
        end
    end
    return entitys
end
function self.loadEntitys(chunk)
    for i,v in chunk.Entities do
        self.AddEntity(i,v)
    end
end
function self.GetChunk(cx,cz,create)
    if not self.LoadedChunks[cx..','..cz] and create then
        self.CreateChunk(nil,cx,cz)
    end
    return self.LoadedChunks[cx..','..cz] 
end
function self.CreateChunk(cdata,cx,cz)
    self.LoadedChunks[cx..','..cz] = ChunkObj.new(cx,cz,cdata)
    return self.LoadedChunks[cx..','..cz] 
end
function self.DestroyChunk(cx,cz)
    local c = self.GetChunk(cx,cz)
    if c then
        c:Destroy()
        self.LoadedChunks[cx..','..cz] = nil
    end
end
self.HitBox = self.Hitbox or workspace.HitboxL:Clone()

local a = self.HitBox
a.Parent = workspace
a.BrickColor = BrickColor.new("Curry")
function  HitboxL(x,y,z)
  a.Position = Vector3.new(x,y,z)*3 a.Anchored = true   
end
function high(x,z)
    if workspace.Chunks:FindFirstChild(x..','..z) and not workspace.Chunks:FindFirstChild(x..','..z):FindFirstChildWhichIsA("Highlight") then
       local a = Instance.new("Highlight",workspace.Chunks:FindFirstChild(x..','..z)) 
       game:GetService("Debris"):AddItem(a,1)
    end
end
function c(x,y,z) local a = workspace.IDK:Clone() a.Parent = workspace a.Size = Vector3.new(3,3,3) a.Position = Vector3.new(x,y,z)*3 a.Anchored = true game:GetService("Debris"):AddItem(a,1) end 
function self.GetBlock(x,y,z,a)
    local cx,cz = qf.GetChunkfromReal((x),(y),(z),true)
  --  print(type(cz), cz ==1 , cz)
--  if Vector3.new(round(x),round(y),round(z)) == Vector3.new(-6, 58, 10) and not a then c(x,y,z) end 
    -- if cx == -1 and cz == 1 and not a then
    --     HitboxL(x,y,z)
    -- end
   -- high(cx,cz)
    local chunk = self.GetChunk(cx,cz)
    local localgrid = Vector3.new(round(x)%8,round(y),round(z)%8)--qf.cbt("grid","chgrid",(x),(y),(z) )
    localgrid = Vector3.new((localgrid.X),(localgrid.Y),(localgrid.Z))
    if chunk then
       return unpack({chunk:GetBlock(localgrid.X,localgrid.Y,localgrid.Z,true)})
    end
end
if runservice:IsClient() then return self end
--<server functions
function self.AddToLoad(cx,cz,stuff)
    local c = self.GetChunk(cx,cz,true)
    c:AddToLoad(stuff)
end
function self.DoCaves(cx,cz)
    local c = self.GetChunk(cx,cz,true)
    c:DoCaves()
end
script.DoFunc.OnInvoke = function(func,...)
   if self[func] then
    self[func](...)
   end
   return
end
self.SendToClient = {}
self.InProgress = {}

task.spawn(function()
    local times = 0
    if not self.WhileLoop then
        self.WhileLoop = true
        times+=1
        while true do
            local i = 0
            for c,v in self.SendToClient do
                if not self.SendToClient[c] or self.InProgress[c] then continue end 
                i +=1
                local function fun()
                    local a = self.SendToClient[c]
                    self.SendToClient[c] = nil
                    self.InProgress[c] = true
                    --task.spawn(function()
                    local cx,cz = unpack(string.split(c,","))
                    cx,cz = tonumber(cx),tonumber(cz)
                    local chun = self.GetChunk(cx,cz,true)
                    chun:Generate()     
                    for i,v in a do
                        game.ReplicatedStorage.Events.GetChunk:FireClient(v,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
                    end
                    self.InProgress[c] = nil
                end
                task.spawn(fun)
                if i%20 == 0 then task.wait() end
            end 
            -- for i,v in pairs(self.SendToClient) do
            --     if not self.SendToClient[i] then continue end 
            --        --task.spawn(function()
            --        local cx,cz = unpack(string.split(i,","))
            --        cx,cz = tonumber(cx),tonumber(cz)
            --         local chun = self.GetChunk(cx,cz,true)
            --         chun:Generate()     
            --         for i,v in self.SendToClient[i] do
            --             game.ReplicatedStorage.Events.GetChunk:FireClient(v,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
            --         end
            --         self.SendToClient[i] = nil
            --       -- end)
            --        --if i %6 == 0 then task.wait(.05) end 
            -- end
            task.wait()
        end
    end
end)
self.EntityLoop = false
if not self.EntityLoop then
    self.EntityLoop = true
    game:GetService("RunService").Heartbeat:Connect(function( deltaTime)
        for id,entity in self.LoadedEntities do
            task.spawn(entity.Update,entity,deltaTime)
        end
    end)
end
game.ReplicatedStorage.Events.GetChunk.OnServerEvent:Connect(function(player,cx,cz)
    -- local position = player.Character.PrimaryPart.Position
    local new = self.GetChunk(cx,cz)
    if new and new:IsGenerating() then
        game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,new:GetBlocks() )
        return 
    end
     --new:Generate()
     --print("e")
     self.SendToClient[cx..','..cz] =  self.SendToClient[cx..','..cz] or {}
     table.insert(self.SendToClient[cx..','..cz],player )
    --game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
   --                                                              task.wait(1)
   -- self.GetChunk(cx,cz).Blocks = {}
   -- self.GetChunk(cx,cz).Setttings.Generated = false
     -- game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,compresser.compresslargetable(self.GetChunk(cx,cz):GetBlocks(),6) )
 end)
--  game.ReplicatedStorage.Events.GetChunk.OnServerEvent:Connect(function(player,cx,cz)
--     -- local position = player.Character.PrimaryPart.Position
--     local new = self.GetChunk(cx,cz,true)
--      new:Generate()
--     game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,self.GetChunk(cx,cz):GetBlocks() )
--    --                                                              task.wait(1)
--    -- self.GetChunk(cx,cz).Blocks = {}
--    -- self.GetChunk(cx,cz).Setttings.Generated = false
--      -- game.ReplicatedStorage.Events.GetChunk:FireClient(player,cx,cz,compresser.compresslargetable(self.GetChunk(cx,cz):GetBlocks(),6) )
--  end)
return self