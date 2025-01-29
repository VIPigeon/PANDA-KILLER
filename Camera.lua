Camera = {}

function Camera:new(dead_zone_rect, target, target_width, target_height)
    local obj = {
        area = dead_zone_rect,
        target = target,
        target_width = target_width,
        target_height = target_height,

        shake_magnitude = {},
        statuses = {},
        status = 'normal',

        -- Легаси из бумеранга
        gm = {
            x = 0,
            y = 0,
            sx = 0,
            sy = 0,
        },
    }

    setmetatable(obj, self)
    return obj
end

function Camera:move_camera()
    local center_x = math.floor(self.area:center_x())
    local center_y = math.floor(self.area:center_y())
    local tile_x = math.floor(self.area:center_x() / 8)
    local tile_y = math.floor(self.area:center_y() / 8)

    self.gm.x = tile_x - math.floor(120 / 8)
    self.gm.sx = 8 * (tile_x) - center_x

    self.gm.y = tile_y - math.floor(68 / 8)
    self.gm.sy = 8 * (tile_y) - center_y
end

function Camera:transform_coordinates(x, y)
    local tx = x - self.gm.x * 8 + self.gm.sx
    local ty = y - self.gm.y * 8 + self.gm.sy
    return tx, ty
end

function Camera:center_on_target()
    local dx = self.target.x + self.target_width  / 2 - self.area:center_x()
    local dy = self.target.y - CAMERA_VERTICAL_OFFSET + self.target_height / 2 - self.area:center_y()

    -- Чтобы не камера не дергалась, когда уже достигла игрока
    if math.abs(dx) < 1 and math.abs(dy) < 1 then
        return
    end

    local length = math.sqrt(dx * dx + dy * dy)

    dx = dx / length
    dy = dy / length

    self.area:move(dx * CAMERA_SPEED, dy * CAMERA_SPEED)
end

function Camera:get_direction_to_target()
    local dx, dy = 0, 0

    if self.area:is_object_right(self.target, self.target_width) then
        dx = 1
    elseif self.area:is_object_left(self.target) then
        dx = -1
    end

    if self.area:is_object_below(self.target, self.target_height) then
        dy = 1
    elseif self.area:is_object_above(self.target) then
        dy = -1
    end

    return dx, dy
end

function Camera:update()
    local dx, dy = self:get_direction_to_target()

    if self.area:is_object_inside(self.target, self.target_width, self.target_height) then
        -- 2023 😊:
        -- Ура, я использовал goto!!!
        -- 2024 💀:
        -- Лучше бы я его не использовал
        goto move
    end

    if dx < 0 then
        self.area:move_left_to(self.target.x)
    elseif dx > 0 then
        self.area:move_right_to(self.target.x + self.target_width)
    end

    if dy < 0 then
        self.area:move_up_to(self.target.y)
    elseif dy > 0 then
        self.area:move_down_to(self.target.y + self.target_height)
    end

    ::move::

    self:move_camera()
end

Camera.__index = Camera
