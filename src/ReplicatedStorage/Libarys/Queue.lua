local Queue = {}

function Queue.new()
    return {size = 0}
end
function Queue.enqueue(self,value)
    local newNode = {value}
    self.size+=1
    if not self.front then
        self.front = newNode
        self.rear = newNode
    else
        self.rear[2] = newNode
        self.rear = newNode
    end
end
function Queue.dequeue(self)
    if not self.front then
        return 
    end
    self.size-=1
    local value = self.front[1]
    self.front = self.front[2]
    return value
end

return Queue