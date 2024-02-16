

local distributions = {}

local modes = {
    triangular = require(script.triangularDistribution),
    uniform = require(script.uniformDistribution),
    same = {
        parse = function(data)
            return data.value
        end,
        sample = function(self)
            return self
        end
    }
}
--[[
    {
        type = "triangular"
        ...
    }
]]
export type Distribution = {
   
}

function distributions.addDistributions(name,info)
    modes[name] = info
end

function distributions.sample(self,random)
    return self[2](self[1],random)
end

function distributions.parse(data)
    local mode = modes[data.type or "uniform"]
    if not mode then
        mode = modes.uniform
    end
    local parsed = mode.parse(data)
    return {parsed,mode.sample}
end

distributions.DEFAULT = distributions.parse({
    type = "uniform",
    max = 255,
    min = 10
})

return  table.freeze(distributions)