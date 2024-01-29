local Chunk = {}

local Communicator = require(script.Parent.Communicator)
local RegionHelper = require(script.Parent.RegionHelper)
local Config = require(script.Parent.Config)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)

local Precompute = OtherUtils.preComputeSquare(Config.StructureRange)
local preComputeLength = #Precompute

local indexUtils = require(game.ReplicatedStorage.Utils.IndexUtils)
indexUtils.preComputeAll()

local t = buffer.create(4*8*256*8)
for x = 1,8 do
    for z = 1,8 do
        local idx = indexUtils.to1D[x][1][z]
        buffer.writeu32(t, (idx-1)*4, 1)
    end
end



local carvedBufferSize =  2*8*256*8
local CONST_IDK = 8*256*8-1

local FeatureBufferSize = carvedBufferSize*2
local UINT16 = 65535
local UINT32 = 2^32-1


function Chunk.new(chunk)
    local _,ActorID = Communicator.getActor()
    local ChunkRegion = RegionHelper.GetIndexFromChunk(chunk)
    local isSame = ChunkRegion == ActorID
    local count = if isSame then preComputeLength else 0
    local nearby = isSame and {}
    local ToQueue = {}
    debug.profilebegin("precompute")
    for i,offset in Precompute do
        local newChunk = chunk + offset
        local newID = RegionHelper.GetIndexFromChunk(newChunk)
        local equals = newID == ActorID 
        if isSame and not equals  then 
            nearby[newID] =  nearby[newID] or {}
            table.insert(nearby[newID],newChunk)
            continue 
        elseif equals  then
            table.insert(ToQueue,newChunk)
        end 
        if isSame or not equals then continue end 
        count += 1
    end
    debug.profileend()

    local self = {
        Loc = chunk,
        Shape = nil,
       -- LocalCaveDone = false,
        MainThread = nil,
        Surface = nil,
        Biome = nil,
        NotInRegion =if isSame then nil else ChunkRegion,
        AmtChecked = 0,
        BAmtChecked = 0,
        FAmtChecked = 0,
        ActorsToSend = nearby,
        ChunksToQueue = ToQueue,
        Checked = {},
        FChecked = {},
        BChecked = {},
        RequiredAmmount = count,
    }

    return self
end

function Chunk.initFeatureBuffer(self)
    local fBuffer = buffer.create(FeatureBufferSize)
    buffer.fill(fBuffer, 0,255,FeatureBufferSize)
    self.FeatureBuffer = fBuffer
end
initCarved = {}
function Chunk.initCarveBuffer(self)
    initCarved[self.Loc] = true
    local fBuffer = buffer.create(carvedBufferSize)
    buffer.fill(fBuffer, 0,255,carvedBufferSize)
    self.Carved = fBuffer
    
end

local function AttempCombineCave(self,data)
    if typeof(data) ~= "buffer" then return end 
    if not self.Carved then Chunk.initCarveBuffer(self) end 
    local carved = self.Carved
    for i =0,CONST_IDK do
        i*=2
        local value = buffer.readu16(data, i)
        if value == UINT16 then continue end 
        buffer.writeu16(carved, i, value)
    end
end

local function AttempCombineFeature(self,data)
    if typeof(data) ~= "buffer" then return end 
    if not self.FeatureBuffer then Chunk.initFeatureBuffer(self) end 
    local carved = self.FeatureBuffer
    for i =0,CONST_IDK do
        i*=4
        local value = buffer.readu32(data, i)
        if value == UINT32 then continue end 
        buffer.writeu32(carved, i, value)
    end
end



function Chunk.combineCarve(self,from,data)
    if self.FCarve then return end 
    local Carved = self.Checked or {}
    for i,chunk in self.ActorsToSend[from] do
        if Carved[chunk] then continue end 
        Carved[chunk] = true
        self.AmtChecked +=1
    end
    AttempCombineCave(self,data)
    if self.AmtChecked >= self.RequiredAmmount then
        self.FCarve = true
        return true
    end
    return false 
end

function Chunk.combineFeature(self,from,data)
    if self.FFeature then return end 
    local checked = self.FChecked or {}
    for i,chunk in self.ActorsToSend[from] do
        if checked[chunk] then continue end 
        checked[chunk] = true
        self.FAmtChecked +=1
    end
    AttempCombineFeature(self,data)
    if self.FAmtChecked >= self.RequiredAmmount then
        self.FFeature = true
        return true
    end
    return false 
end

function Chunk.finishCarve(self)
    if not self.Carved then return end 
    local carved = self.Carved
    local Shape = self.Shape
    for i =0,CONST_IDK do
        i*=2
        local value = buffer.readu16(carved, i)
        if value == UINT16 then continue end 
        buffer.writeu32(Shape, i*2, value)
    end
end

function Chunk.finishFeature(self)
    if not self.FeatureBuffer then return end 
    local FB = self.FeatureBuffer
    local Shape = self.Shape
    for i =0,CONST_IDK do
        i*=4
        local value = buffer.readu32(FB, i)
        if value == UINT32 then continue end 
        buffer.writeu32(Shape, i, value)
    end
end

function Chunk.destroy(self)
    --table.clear(self)
end

return Chunk