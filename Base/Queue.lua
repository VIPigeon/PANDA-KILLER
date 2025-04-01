Queue = {}

function Queue:new()
    local obj = {
        head = 1,
        tail = 1,
        items = {},
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Queue:size() --additional +1
    return self.head - self.tail + 1 - 1
end

function Queue:empty()
    return self:size() == 0
end

function Queue:enqueue(item)
    table.insert(self.items, self.head, item)
    self.head = self.head + 1
end

function Queue:dequeue()
    if self:size() == 0 then
        error('Queue has no elements!')
    end

    item = self.items[self.tail]
    self.tail = self.tail + 1
    return item
end
