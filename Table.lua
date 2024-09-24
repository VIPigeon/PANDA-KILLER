function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function table.equals(t1, t2)
    for i, value in ipairs(t1) do
        if value ~= t2[i] then
            return false
        end
    end
    return true
end

function table.concatTable(destination, source)
    for _, element in ipairs(source) do
        table.insert(destination, element)
    end
end

function table.contains_table(t, element)
    for _, value in pairs(t) do
        if table.equals(value, element) then
            return true
        end
    end
    return false
end

function table.contains(t, element)
    for _, value in pairs(t) do
        if value == element then
            return true
        end
    end
    return false
end

function table.removeElement(t, element)
    ind = 0
    for i, value in ipairs(t) do
        if value == element then
            ind = i
            break
        end
    end

    if ind > 0 and ind <= #t then -- 😁😁😁😁 Тут был '<' я его полтора часа исправлял на '<='
        table.remove(t, ind)
    end
end

function table.removeElements(t, removed)
    for i, value in ipairs(t) do
        if table.contains(removed, value) then
            table.remove(t, i)
        end
    end
end

function table.reversed(t)
    res = {}
    for i = #t, 1, -1 do
        table.insert(res, t[i])
    end
    return res
end

function table.length(t) -- 🤓
    local counter = 0
    for _ in pairs(t) do
        counter = counter + 1
    end
    return counter
end

function table.chooseRandomElement(t)
    local rand = math.random(table.length(t))
    local ind = 1
    local choosen = nil 
    for _, elem in pairs(t) do
        if ind == rand then
            choosen = elem
        end
        ind = ind + 1
    end
    return choosen
end

return table
