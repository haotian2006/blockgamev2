local module = {}
module.ToDO = {}
module.Done = {}
module.ActiveKeys = {}
function module.CreateKey()
    for i =0,20000 do
        i = tostring(i)
        if not module.ToDO[i] and not module.Done[i] and not module.ActiveKeys[i]  then
            module.ActiveKeys[i] = true
            task.delay(1,function()
                module.ActiveKeys[i]  = nil
            end)
            return i
        end
    end
end
function module.Upload(...)
    local key = module.CreateKey()
	module.ToDO[key] = {...}
    return key
end
function module.Recieve(key)
    local data = module.ToDO[key]
    module.ToDO[key] = nil
	return unpack(data or {})
end
function module.Set(key,...)
	module.Done[key] = {...}
end
function module.Get(key)
    local data = module.Done[key]
    module.Done[key] = nil
	return unpack(data or {})
end
return module
