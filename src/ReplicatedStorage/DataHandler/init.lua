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
local runservice = game:GetService("RunService")
local ChunkObj = require(game.ReplicatedStorage.Chunk)
local compresser = require(game.ReplicatedStorage.Libarys.compressor) 
local settings = require(game.ReplicatedStorage.GameSettings)
local bridge = require(game.ReplicatedStorage.BridgeNet)
local EntityBridge = bridge.CreateBridge("EntityBridge")
local GetChunk = bridge.CreateBridge("GetChunk")
local isserver = runservice:IsServer()
local bS = require(game.ReplicatedStorage.Libarys.BlockStore)
function self.AddEntity(uuid:string,address:table)
    self.AmmountOfEntities += 1
    if type(uuid) == "table" then
        self.LoadedEntities[uuid.Id] = uuid
    else
        self.LoadedEntities[uuid] = address or warn(uuid,"Does not have data")
    end
end
script.DoFunc.OnInvoke = function(func,...)
    if self[func] then
        return self[func](...)
    end
    return
 end
local function round(x)
    return math.floor(x+.5)
end
local function round2(x)
    return math.round(x)
end
function self.GetEntity(tag)
    return self.LoadedEntities[tostring(tag)]
end
function self.GetEntityFromPlayer(player:Player)
    return self.LoadedEntities[tostring(player.UserId)]
end
function self.RemoveEntity(uuid)
    self.AmmountOfEntities -= 1
    self.LoadedEntities[tostring(uuid)] = nil
end
function self.GetLocalPlayer()
    return self.LocalPlayer.Entity and next(self.LocalPlayer) ~= nil and self.LocalPlayer
end
function self.EntitiesinR(x,y,z,r,ConvertToClient,interval )
    x,y,z,r = x or 0, y ,z or 0 ,r or 0
    local vector = Vector3.new(x,y or 0,z)
    local entitys = {}
    for i,v in self.LoadedEntities do
        if not y then vector = Vector3.new(x,v.Position.Y,z) end 
        if (v.Position - vector).Magnitude <= r then
            entitys[i] = not ConvertToClient and v or v:ConvertToClient(ConvertToClient,interval)
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
self.Hitbox = self.Hitbox or workspace.HitboxL:Clone()

local a = self.Hitbox
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
function self.RemoveBlock(x,y,z)
    local cx,cz,lx,ly,lz = qf.GetChunkAndLocal(x,y,z)
    local chunk = self.GetChunk(cx,cz)
    if chunk then
        chunk:RemoveBlock(lx,ly,lz)
    end
    return chunk 
end
function self.canPlaceBlockAt(X,Y,Z,block) 
    if self.GetBlock(X,Y,Z) then return end
    for i,v in self.EntitiesinR(X,Y,Z,1.5) or {} do
        local a = require(game.ReplicatedStorage.CollisonHandler).AABBcheck(v.Position+v:GetVelocity()*task.wait(),Vector3.new(X,Y,Z),Vector3.new(v.Hitbox.X,v.Hitbox.Y,v.Hitbox.X),Vector3.new(1,1,1))
        if a then
            return false 
        end
    end
    return true
end
function self.InsertBlock(x,y,z,block)
    local cx,cz,lx,ly,lz = qf.GetChunkAndLocal(x,y,z)
    local chunk = self.GetChunk(cx,cz)
    if chunk then
        chunk:InsertBlock(lx,ly,lz,block)
    end
    return chunk
end
function c(x,y,z) local a = workspace.IDK:Clone() a.Parent = workspace a.Size = Vector3.new(3,3,3) a.Position = Vector3.new(x,y,z)*3 a.Anchored = true game:GetService("Debris"):AddItem(a,1) end 
function self.GetBlock(x,y,z)
    local cx,cz = qf.GetChunkfromReal((x),(y),(z),true)
    local chunk = self.GetChunk(cx,cz)
    local localgrid = Vector3.new(round(x)%settings.ChunkSize.X,round(y),round(z)%settings.ChunkSize.X)
    localgrid = Vector3.new((localgrid.X),(localgrid.Y),(localgrid.Z))
    if chunk and (not isserver or chunk.Setttings["Generated"]) then
        if localgrid.Y >= settings.ChunkSize.Y then
            return false,localgrid.X..','..localgrid.Y..','..localgrid.Z
        end
        local b = chunk:GetBlock(localgrid.X,localgrid.Y,localgrid.Z)
        if b and not b:getKey() then b = false  end 
       return b,localgrid.X..','..localgrid.Y..','..localgrid.Z
    else
       return bS:get("NULL"),localgrid.X..','..localgrid.Y..','..localgrid.Z
    end
end

--<server functions
--local WorldDataStore = game:GetService("DataStoreService"):GetDataStore("World-1")

return self