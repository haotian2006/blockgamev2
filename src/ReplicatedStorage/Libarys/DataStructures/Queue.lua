local Queue = {}

function Queue.new(preAllocated)
    local self = table.create(preAllocated or 0)
    self.S = 1
    self.E = 0
    return self
end

function Queue.size(self)
    return self.E - self.S + 1
end

function Queue.enqueue(self,value)
    local last = self.E + 1
    self.E = last
    self[last] = value
end

function Queue.dequeue(self)
    local first = self.S
    if first > self.E then
        self.S = 1
        self.E = 0
        return nil
    end
    local value =self[first]
    self[first] = nil
    self.S = first + 1
    return value
end

return Queue
