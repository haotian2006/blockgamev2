 local render = {}
local libs = {}
for i,v in ipairs(script:GetChildren())do
    if v:IsA("ModuleScript") then
        libs[v.Name] = require(v)
        for i,fun in libs[v.Name] do
            if type(fun) == "function" then
                render[i] = fun
            end
        end
    end
end
return render