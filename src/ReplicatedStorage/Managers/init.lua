local mods = {}
function mods:Init()
    for i,v in script:GetChildren() do
        mods[v.Name] = require(v)
    end
    return mods
end
script.ChildAdded:Connect(function(v)
    mods[v.Name] = require(v)
end)
return mods