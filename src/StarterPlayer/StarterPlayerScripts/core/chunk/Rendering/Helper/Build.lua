local Builder = {}
local DataHandler = require(game.ReplicatedStorage.Data)
local Block = require(game.ReplicatedStorage.Block)
local RotationUtils = require(game.ReplicatedStorage.Utils.RotationUtils)
local Cache = require(script.Parent.Parent.RenderCache)
local Texture = require(script.Parent.Parent.BlockTexture)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)
local Queue = require(game.ReplicatedStorage.Libs.DataStructures.Queue)
local ConversionUtils = require(game.ReplicatedStorage.Utils.ConversionUtils)
local ChunkClass = require(game.ReplicatedStorage.Chunk)
local Config = require(script.Parent.Parent.Config)

local AntiLag = Config.ANTI_LAG
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
    local toMoveP = {}
    local toMoveC = {}
    local i = 0
    for key,data in Meshed do
    
        local partName = toStringBlockInfo(data)
        if Rendered[partName] then 
            removed[partName] = true 
            continue 
        end 
        local blockID,id = Block.decompress(data.data.X)
        
        local walls = data.data.Y
        local BlockName = Block.getBlock(blockID)

        local p,textures = Texture.CreateBlock(BlockName,walls,nil,id)
        p.Size = data.size*3
        i+=1
        toMoveP[i] = p
        toMoveC[i] = CFrame.new((data.midPoint+chunkOffset)*3)
        --p.Position = (data.midPoint+chunkOffset)*3
        p.Parent = folder

        Rendered[partName] = {p,textures}
        removed[partName] = true 

        if os.clock()-StartTime >= .014 and AntiLag then
            coroutine.yield()
            if Canceled then 
               Canceled = false
               break
            end
       end

    end
    workspace:BulkMoveTo(toMoveP, toMoveC)

    for i,v in Rendered do
        if removed[i] then continue end 
        Rendered[i] = nil
        for _,t in v[2] do
            Cache.sendTextureBackToQueue(t)
        end
        Cache.sendBlockBackToQueue( v[1])
    end
    CurrentlyBuilding = nil
    CurrentlyBuildingThread = nil
    if not folder.Parent then
        folder.Parent = ChunksFolder
    end
end

function Builder.destroy(chunk)
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
               break
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
        Canceled = true
        coroutine.resume(CurrentlyBuildingThread)
        CurrentlyBuildingThread = nil
        CurrentlyBuilding = nil
    end


    InQueue[chunk] = Mesh
end

function Builder.deload(chunk)
    if not RenderedChunks[chunk] then
        return 
    end
    Builder.addToQueue(chunk,-1)
end

-- function Builder.buildNext()
--     local times = 0
--     for i = 1,8 do
--         local Chunk = Queue.dequeue(BuildQueue)
--         if not Chunk then break end 
--         local Data = InQueue[Chunk]
--         if Data == 1 then
--             Builder.destroy(Chunk)
--         else
--             Builder.build(Chunk, Data)
--         end
       
--         times +=1
--     end
--     return times ~=0 
-- end

function Builder.buildNext()
    local times = 0

    local camera = workspace.CurrentCamera.CFrame.Position/3
    local cx,cy = ConversionUtils.getChunk(camera.X,camera.Y,camera.Z)
    local Center = Vector3.new(cx,0,cy)
    local InRadius = Config.InRadius
    local ComputeBuild = OtherUtils.chunkDictToArray(InQueue, Center)
    for _,Chunk in ComputeBuild do
        if times >= 8 then break end 
        local Data = InQueue[Chunk]
        if Data == -1 then
            Builder.destroy(Chunk)
        elseif Data then
            if not InRadius[Chunk] then
                InQueue[Chunk] = nil
                continue
            end
            Builder.build(Chunk, Data)
        end
        InQueue[Chunk] = nil
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