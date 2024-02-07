local Builder = {}
local DataHandler = require(game.ReplicatedStorage.Data)
local Block = require(game.ReplicatedStorage.Block)
local RotationUtils = require(game.ReplicatedStorage.Utils.RotationUtils)
local Cache = require(script.Parent.Parent.RenderCache)
local Texture = require(script.Parent.Parent.BlockTexture)
local Queue = require(game.ReplicatedStorage.Libarys.DataStructures.Queue)
local ChunkClass = require(game.ReplicatedStorage.Chunk)

local StartTime = os.clock()

local CurrentlyBuilding 
local CurrentlyBuildingThread
local Canceled = false

local BuildQueue = Queue.new(10)
local InQueue = {}

local RenderedChunks = {}

Builder.Rendered = RenderedChunks
Builder.Queue = BuildQueue
Builder.InQueue = InQueue

local ChunksFolder:Folder = workspace.Chunks

local tostringBuffer = buffer.create(32)

local function toStringBlockInfo(blockInfo)
    local data = blockInfo.data
    local size = blockInfo.size
    local point = blockInfo.midPoint

    buffer.writef32(tostringBuffer,0,data.X)
    buffer.writef32(tostringBuffer,4,data.Y)
    
    buffer.writef32(tostringBuffer,8,size.X)
    buffer.writef32(tostringBuffer,12,size.Z)
    buffer.writef32(tostringBuffer,16,size.y)

    buffer.writef32(tostringBuffer,20,point.X)
    buffer.writef32(tostringBuffer,24,point.Z)
    buffer.writef32(tostringBuffer,28,point.y)

    return buffer.tostring(tostringBuffer)
end

local function getFolder(chunk)
    local nameString = `{chunk.X},{chunk.Z}`
    local folder = ChunksFolder:FindFirstChild(nameString)
    if folder then return folder,true end 
    folder = Instance.new("Model")
    folder.Name = nameString
    return folder 
end

function Builder.build(chunk,Meshed)
    local Chunk = DataHandler.getChunkFrom(chunk)
    if not Chunk then return end 

    CurrentlyBuilding = chunk
    CurrentlyBuildingThread = coroutine.running()
    
    local Rendered = RenderedChunks[chunk] or {}
    RenderedChunks[chunk] = Rendered

    local folder = getFolder(chunk)
    
    local chunkOffset = chunk*8 - Vector3.new(1,0,1)
    
    local removed = {}

    for key,data in Meshed do
        if os.clock()-StartTime >= .014 then
             coroutine.yield()
             if Canceled then 
                Canceled = false
                return
             end
        end

        local blockID,rot,id = Block.decompressCache(data.data.X)
        local partName = toStringBlockInfo(data)

        if Rendered[partName] then 
            removed[partName] = true 
            continue 
        end 

        rot = RotationUtils.indexPairs[rot]
        local walls = data.data.Y
        local BlockName = Block.getBlock(blockID)
        local p,textures = Texture.CreateBlock(BlockName,walls)
        p.Size = data.size*3
        p.Position = (data.midPoint+chunkOffset)*3
        p.Parent = folder

        Rendered[partName] = {p,textures}
        removed[partName] = true 
    end

    for i,v in Rendered do
        if removed[i] then continue end 
        Rendered[i] = nil
        for _,t in v[2] do
            Cache.sendTextureBackToQueue(t)
        end
        Cache.sendBlockBackToQueue( v[1])
    end
    InQueue[chunk] = nil
    CurrentlyBuilding = nil
    CurrentlyBuildingThread = nil
    folder.Parent = ChunksFolder
end

function Builder.destroy(chunk)
    InQueue[chunk] = nil
    CurrentlyBuilding = chunk
    CurrentlyBuildingThread = coroutine.running()

    local Rendered = RenderedChunks[chunk] or {}
    RenderedChunks[chunk] = Rendered

    local folder = getFolder(chunk)
    
    for i,v in Rendered do
        Rendered[i] = nil
        if os.clock()-StartTime >= .014 then
            coroutine.yield()
            if Canceled then 
               Canceled = false
               return
            end
       end
        for _,t in v[2] do
            Cache.sendTextureBackToQueue(t)
        end
        Cache.sendBlockBackToQueue( v[1])
    end
    RenderedChunks[chunk] = nil
    CurrentlyBuilding = nil
    CurrentlyBuildingThread = nil
    folder:Destroy()
end

function Builder.addToQueue(chunk,Mesh)
    if CurrentlyBuilding == chunk then
        task.cancel(CurrentlyBuildingThread)
        Canceled = true
        CurrentlyBuildingThread = nil
        CurrentlyBuilding = nil
    end

    if not InQueue[chunk] then
        Queue.enqueue(BuildQueue, chunk)
    end
    InQueue[chunk] = Mesh
end

function Builder.deload(chunk)
    if not RenderedChunks[chunk] then
        return 
    end
    Builder.addToQueue(chunk,1)
end

function Builder.buildNext()
    local times = 0
    for i = 1,8 do
        local Chunk = Queue.dequeue(BuildQueue)
        if not Chunk then break end 
        local Data = InQueue[Chunk]
        if Data == 1 then
            Builder.destroy(Chunk)
        else
            Builder.build(Chunk, Data)
        end
       
        times +=1
    end
    return times ~=0 
end

function Builder.run(Start_Time)
    StartTime = Start_Time
    if CurrentlyBuildingThread then
        coroutine.resume(CurrentlyBuildingThread)
        return 1
    end
    local Built = Builder.buildNext()
    return if Built then 2 else 1
end

return Builder