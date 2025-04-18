--[[

Математика. Ещё нужны пояснения?

--]]

function math.coin_flip()
    return math.random(2) == 2
end

function math.random_sign()
    if math.coin_flip() then
        return 1
    else
        return -1
    end
end

function math.clamp(x, left, right)
    if x < left then
        return left
    end
    if x > right then
        return right
    end
    return x
end

function math.sign(x)
    if x < 0 then
        return -1
    end
    if x > 0 then
        return 1
    end
    return 0
end

function math.round(x)
    return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

function math.sqr(x)
    return x * x
end

function math.in_range_not_inclusive(num, left_border, right_border)
    return num > left_border and num < right_border
end

function math.in_range_inclusive(num, left_border, right_border)
    return num >= left_border and num <= right_border
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end

-- Украдено из юнити
-- https://stackoverflow.com/questions/61372498/how-does-mathf-smoothdamp-work-what-is-it-algorithm
function math.smooth_damp(current, target, velocity, smooth_time)
    assert(smooth_time > 0.0001)

    local omega = 2.0 / smooth_time;

    local x = omega * Time.dt();
    local exp = 1.0 / (1.0 + x + 0.48*x*x + 0.235*x*x*x);
    local change = current - target;
    local original_to = target;

    local target = current - change;

    local temp = (velocity + omega * change) * Time.dt();
    local next_velocity = (velocity - omega * temp) * exp

    local output = target + (change + temp) * exp;

    if ((original_to - current > 0.0) == (output > original_to)) then
        output = original_to;
        velocity = (output - original_to) / Time.dt();
    end

    return output, next_velocity
end


--
-- Векторная математика ↗️
--
function math.vector_length(vec)
    return math.sqrt(math.sqr(vec.x) + math.sqr(vec.y))
end

function math.vector_normalize(vec)
    local len = math.vector_length(vec)
    return {x = vec.x / len, y = vec.y / len}
end

-- Возвращает квадрат расстояния между точками
function math.sq_distance(x1, y1, x2, y2)
    return math.abs(x1 - x2)^2 + math.abs(y1 - y2)^2
end

-- Отрезок ортогональный
-- (Что это значит? 🤔)
function math.sq_point_ortsegment_distance(x, y, x1, y1, x2, y2)
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
