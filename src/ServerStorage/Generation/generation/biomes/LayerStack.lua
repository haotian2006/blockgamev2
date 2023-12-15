local Stack = {}
function Stack.add(self,value)
    self[#self+1] = value
end
function Stack.next(self,index)
    index = index+1 or 1
    return self[index],index
end

return Stack