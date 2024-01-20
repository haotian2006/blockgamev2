local Chunk = {}

local Communicator = require(script.Parent.Communicator)
local RegionHelper = require(script.Parent.RegionHelper)
local Config = require(script.Parent.Config)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)

local Precompute = OtherUtils.preComputeSquare(Config.StructureRange)
local preComputeLength = #Precompute

local carvedBufferSize =  2*8*256*8
local CONST_IDK = 8*256*8-1

local UINT16 = 65535

local sharedBuffer = buffer.create(carvedBufferSize)
buffer.fill(sharedBuffer, 0,255,carvedBufferSize)

function Chunk.new(chunk)
    local _,ActorID = Communicator.getActor()
    local ChunkRegion = RegionHelper.GetIndexFromChunk(chunk)
    local isSame = ChunkRegion == ActorID
    local count = if isSame then preComputeLength else 0
    local nearby = {}
    for i,offset in Precompute do
        local newChunk = chunk + offset
        local newID = RegionHelper.GetIndexFromChunk(newChunk)
        if newID ~= ActorID  then 
            nearby[newID] =  nearby[newID] or {}
            table.insert(nearby[newID],newChunk)
            continue 
        end 
        if isSame then continue end 
        count += 1
    end

    local carvedBuffer = buffer.create(carvedBufferSize)
    buffer.fill(carvedBuffer, 0,255,carvedBufferSize)

    local self = {
        Loc = chunk,
        Shape = nil,
        LocalCaveDone = false,
        Surface = nil,
        Biome = nil,
        NotInRegion =if isSame then false else ChunkRegion,
        AmmountBuilded = 0,
        AmmountCarved = 0 ,
        ActorsToSend = isSame and nearby,
        CravedData = {},
        CarvedAlready = {},
        RequiredCarved = count,
        Carved = carvedBuffer,
    }

    return self
end

function Chunk.setData(self,shape,surface,biome)
    self.Shape = shape
    self.surface = surface
    self.biome = biome 
end


function Chunk.didCarving(self,chunk)

    local Carved = self.CarvedAlready
    if self.LocalCaveDone then return end 
   
    if Carved[chunk] then return Chunk.checkCaveDone(self) end  
    local v = self.AmmountCarved +1
    self.AmmountCarved = v
   Carved[chunk] = true
    if v < self.RequiredCarved then
        return
    end
    self.LocalDone = true
    return Chunk.checkCaveDone(self)
end

function Chunk.combineCarverfromActor(self,from,carver)
    local Carved = self.CarvedAlready

    for i,chunk in self.ActorsToSend[from] do
        if Carved[chunk] then continue end 
        Carved[chunk] = true
        self.AmmountCarved +=1
    end

    self.CravedData[from] = carver
end

function Chunk.checkCaveDone(self)

    if self.AmmountCarved < self.RequiredCarved then
        return false
    end
    if self.NotInRegion then
        return 1,self.NotInRegion,self.Carved
    end
   
    return 2 
end

function Chunk.combineCarve(self)
    if self.FinishCarve then return end 
    local shape = self.Shape
    debug.profilebegin("combine")
    local function combine(b)
        for i =0,CONST_IDK do
            local value = buffer.readu16(b, i*2)
            if value == UINT16 then continue end 
            buffer.writeu32(shape, i*4, value)
        end
    end
    for i,v in self.CravedData do
        combine(v)
    end
    combine(self.Carved)
    self.FinishCarve = true
    self.Carved = sharedBuffer
    table.clear(self.CravedData)
    debug.profileend()

end

function Chunk.destroy(self)
    table.clear(self)
end

return Chunk