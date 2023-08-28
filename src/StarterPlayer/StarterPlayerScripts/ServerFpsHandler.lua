local fps =	game.ReplicatedStorage.ServerInfo.ServerFps ::IntValue
local last = time()
-- this is a concept/ if fps isn't updated within 4 seconds assume the server crashed
fps.Changed:Connect(function(value)
    if value ~= - 1 then
        last = time()
    end
end)
while task.wait(4) do
    if time()-last >= 4 and fps.Value <=40 then
        fps.Value = -1
    end
end