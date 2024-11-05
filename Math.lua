function math.isObtuse(x1,y1,x2,y2,x3,y3)
    return (x1-x2)*(x3-x2)+(y1-y2)*(y3-y2)>0
end

function math.coin_flip()
    return math.random(2) == 2
end

--old fence collapsed
function math.clamp(x, left, right)
    if x < left then
        return left
    end
    if x > right then
        return right
    end
    return x
end


function math.round(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

function math.sqr(x)
    return x * x
end

function math.vecLength(vec)
    return math.sqrt(math.sqr(vec.x) + math.sqr(vec.y))
end

function math.vecNormalize(vec)
    local len = math.vecLength(vec)
    return {x = vec.x / len, y = vec.y / len}
end

function math.sign(x)
    if x<0 then
        return -1
    end
    if x>0 then
        return 1
    end
    return 0
end


function math.sq_distance(x1, y1, x2, y2)
    -- возвращает квадрат расстояния между точками
    return math.abs(x1 - x2)^2 + math.abs(y1 - y2)^2
end


function math.sq_point_ortsegment_distance(x, y, x1, y1, x2, y2)
    -- отрезок ортогональный
    if (x == x1 and x == x2) or (y == y1 and y == y2) then
        return 0
    end
    if x1 <= x and x <= x2 then
        return math.min(math.sq_distance(x, y, x1, y1), math.sq_distance(x, y, x2, y2), math.sq_distance(x, y, x, y1))
    end
    if y1 <= y and y <= y2 then
        return math.min(math.sq_distance(x, y, x1, y1), math.sq_distance(x, y, x2, y2), math.sq_distance(x, y, x1, y))
    end
    return math.min(math.sq_distance(x, y, x1, y1), math.sq_distance(x, y, x2, y2))
end


function math.inRangeNotIncl(num, leftBoarder, rightBoarder)
    return num > leftBoarder and num < rightBoarder
end

function math.inRangeIncl(num, leftBoarder, rightBoarder)
    return num >= leftBoarder and num <= rightBoarder
end
