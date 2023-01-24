local movers = {}
for i,v in script:GetChildren() do
    movers[v.Name] = require(v) 
end
return movers