local NoiseParameters = {}
function NoiseParameters.create(obj,ampl)
    return {obj,ampl}
end
function NoiseParameters.Evaluate(obj)
    return obj
end
return NoiseParameters