local Queue = {}

function Queue.new(preAllocated)
    local self = {}
    self[1] = 0
    self[2] = -1
    self[3] = table.create(preAllocated or 0)
    return self
end

function Queue.enqueue(self,value)
    local last = self[2] + 1
    self[2] = last
    self[3][last] = value
end

function Queue.dequeue(self)
    local first = self[1]
    if self[1] > self[2] then
        return nil
    end
    local queue = self[3]
    local value =queue[first]
    queue[first] = nil
    self[1] = first + 1
    return value
end


return Queue