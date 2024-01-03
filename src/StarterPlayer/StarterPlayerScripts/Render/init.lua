local Render = {}
local DataHandler = require(game.ReplicatedStorage.Data)
local WorkerM = require(game:GetService("Players").LocalPlayer.PlayerScripts.ClientWorker)
local RenderWorkers = WorkerM.create("Render", 14,script.Actor,script.RenderStuff)
local subChunkHelper = require(script.SubChunkHelper)
local tasks = require(script.RenderStuff)
local RenderStorage = require(script.RenderStorage)
local Conversion = require(game.ReplicatedStorage.Utils.ConversionUtils)
local OtherUtils = require(game.ReplicatedStorage.Utils.OtherUtils)
local BlockRender = require(script.BlockRender)
local signal = require(game.ReplicatedStorage.Libarys.Signal)
local renderQueue = {}
local BlockQueue = {}
local subChunkQueue = {}
Render.subChunkQueue = subChunkQueue
local Recieved = {}
Render.Recieved = Recieved
local toArray = OtherUtils.chunkDictToArray


local shouldRender = {}
function Render.render(chunk,center,n,e,s,w,a)
    local meshed =  RenderWorkers:DoWork("cull",chunk,center,n,e,s,w,a)
    BlockQueue[chunk] = meshed
end
local debugModel = Instance.new("Model")
debugModel.Name = "Debug"
debugModel.Parent = workspace

local updated = false
function Render.createSubChunks(i,part)
    local chunkO = DataHandler.getChunk(i.X,i.Z)
    RenderWorkers:sendMessage("setSubChunkData",i,chunkO.Blocks)
    local c = i
    local Status = chunkO.Status
    Status.SubChunks = table.create(32)
    local done = 0
    local thread = coroutine.running()
    local start = 0--sections[part][1]
    local goal = 31--sections[part][2]
    local size = 32--goal-start+1
    for i=start,goal do
        task.spawn(function()
            Status.SubChunks[i] = RenderWorkers:DoWork("sampleSection", i,c)
            done +=1
            if done == size then
                coroutine.resume(thread)
            end
        end)
    end
    if done ~= size then
        coroutine.yield()
    end
    RenderWorkers:sendMessage("setSubChunkData",i,nil)
    if part == 1 then
        Status.DoneSubChunks = true
        updated = true
        -- local p = Instance.new("Part")
        -- p.Size = Vector3.new(3,20,3)
        -- p.Anchored = true
        -- p.Position = i*8*3+Vector3.new(0,65*3)
        -- p.Parent = debugModel
        -- p.BrickColor = BrickColor.random()
        -- p.Transparency = .5
    end
end
local function updateSearch()
    local data = subChunkHelper.update(updated)
    updated = false
    shouldRender = data and data or shouldRender 
    if data then 
        --debugModel:ClearAllChildren()
        for c,b in data do

            local chunk = DataHandler.getChunk(c.X,c.Z)
            if not chunk then continue end 
            local Status = chunk.Status
            local sections = Status.LoadedSections or buffer.create(32)
            local changed = false
            for i =0,31 do
                local value = buffer.readu8(b, i)
                if value == 0 then continue end
                local oldValue = buffer.readu8(sections, i)
                if oldValue == 0 then
                    changed = true
                    buffer.writeu8(sections, i,1)
                end
            end

          
            if changed then
                -- local p = Instance.new("Part")
                -- p.Size = Vector3.new(3,20,3)
                -- p.Anchored = true
                -- p.Position = c*8*3+Vector3.new(0,70*3)
                -- p.Parent = debugModel
                -- p.BrickColor = BrickColor.random()
                -- p.Transparency = .5

                Status.LoadedSections = sections
                renderQueue[c] = sections
            end
        end
    end
end
local center = Vector3.new()
local array 
local function updateSubChunks(i)
    if i == 1 then
        array = toArray(subChunkQueue,center)
    end
    local times = 0
    for v,i in array do 
        if times == 1 then break end 
        local value = subChunkQueue[i]
        if not value then 
            continue
        end
       -- if not inFov(i) then  continue end 
        task.spawn(function()
            times +=1
            if value == 1 then
                subChunkQueue[i] = nil
            else
                subChunkQueue[i] +=1
            end
            Render.createSubChunks(i,value)
        end)
    end
    return times == 0
end

local renderArray 
local p = Instance.new("Part")
p.Size = Vector3.new(3,100,3)
p.Anchored = true
p.Parent = workspace
p.BrickColor =BrickColor.Red()

local c = p:Clone()
c.Parent = workspace
p.BrickColor =BrickColor.Green()
local chunkSignals = {}
function Render.deloadChunk(chunk)
    renderQueue[chunk] = nil
    subChunkQueue[chunk] = nil
    BlockQueue[chunk] = nil 
    if   chunkSignals[chunk] then
        chunkSignals[chunk]:fire()
    end
    BlockRender.deload(chunk)
end

local function renderBlocks()
    local times = 0
    for v,i in toArray(BlockQueue,center) do
        if times == 3 then break end 
       -- if not inFov(i) then continue end 
       times+=1
        task.spawn(function() 
          --  c.Position = i*8*3+Vector3.new(0,65*3)
            local meshed = BlockQueue[i]
            BlockQueue[i] = nil
            if   chunkSignals[i] then
                chunkSignals[i]:fire()
            end
            chunkSignals[i] = signal.new()
            BlockRender.render(i, meshed,  chunkSignals[i])
            chunkSignals[i] = nil
        end)
    end
end

local function render(i)
    local times = 0
    if i == 3 then
        renderArray = toArray(renderQueue,center)
    end
    for v,i in renderArray do
        if times == 3 then break end 
       -- if not inFov(i) then continue end 
        local a = renderQueue[i]
        if not a then continue end 
        local n,e,s,w = Recieved[i+Vector3.xAxis],Recieved[i+Vector3.zAxis],Recieved[i-Vector3.xAxis],Recieved[i-Vector3.zAxis]
        if not( n and e and s and w) then continue end 
        times+=1
        task.spawn(function()
          --  p.Position = i*8*3+Vector3.new(0,65*3)
            renderQueue[i] = nil
            Render.render(i,Recieved[i],n,e,s,w,a)
        end)
    end
    task.spawn(updateSubChunks)
end
local function sleep()
    
end
local order = {
     updateSubChunks,
     updateSearch,
     render,
     renderBlocks,
     render,
     renderBlocks,
     render,
     renderBlocks,
     render,
     renderBlocks,
     render,
     renderBlocks,
     render,
     renderBlocks,
    --sleep,
}
local i = 0
local function x()
    i+=1
    if not order[i] then
        i = 0
       return x()
    end
    if order[i](i) then
        return x()
    end
    return 
end
game:GetService("RunService").Stepped:Connect(function()
    if not DataHandler.getPlayerEntity() or game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Q) then return end 
    local camera = workspace.CurrentCamera.CFrame.Position/3
    local cx,cy = Conversion.getChunk(camera.X,camera.Y,camera.Z)
    center = Vector3.new(cx,0,cy)
    x()
end)
 
return Render