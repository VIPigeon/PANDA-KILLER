CameraWindow = {}

function CameraWindow:new(deadZoneRect, target, targetWidth, targetHeight)
    local obj = {
        area = deadZoneRect,
        target = target,
        targetWidth = targetWidth,
        targetHeight = targetHeight,

        shakeMagnitude = {},
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

function CameraWindow:move_camera()
    local center_x = math.floor(self.area:center_x())
    local center_y = math.floor(self.area:center_y())
    local tile_x = math.floor(self.area:center_x() / 8)
    local tile_y = math.floor(self.area:center_y() / 8)

    self.gm.x = tile_x - math.floor(120 / 8)
    self.gm.sx = 8 * (tile_x) - center_x

    self.gm.y = tile_y - math.floor(68 / 8)
    self.gm.sy = 8 * (tile_y) - center_y
end

function CameraWindow:transform_coordinates(x, y)
    local tx = x - self.gm.x * 8 + self.gm.sx
    local ty = y - self.gm.y * 8 + self.gm.sy
    return tx, ty
end

function CameraWindow:centerOnTarget()
    local dx = self.target.x + self.targetWidth  / 2 - self.area:centerX()
    local dy = self.target.y - CAMERA_VERTICAL_OFFSET + self.targetHeight / 2 - self.area:centerY()

    -- Чтобы не камера не дергалась, когда уже достигла игрока
    if math.abs(dx) < 1 and math.abs(dy) < 1 then
        return
    end

    local length = math.sqrt(dx * dx + dy * dy)

    dx = dx / length
    dy = dy / length

    self.area:move(dx * CAMERA_SPEED, dy * CAMERA_SPEED)
end

function CameraWindow:getDirectionToTarget()
    local dx, dy = 0, 0

    if self.area:isObjectRight(self.target, self.targetWidth) then
        dx = 1
    elseif self.area:isObjectLeft(self.target) then
        dx = -1
    end

    if self.area:isObjectBelow(self.target, self.targetHeight) then
        dy = 1
    elseif self.area:isObjectAbove(self.target) then
        dy = -1
    end

    return dx, dy
end

function CameraWindow:update()
    local dx, dy = self:getDirectionToTarget()

    if self.area:isObjectInside(self.target, self.targetWidth, self.targetHeight) then
        -- 2023 😊:
        -- Ура, я использовал goto!!!
        -- 2024 💀:
        -- Лучше бы я его не использовал
        goto move
    end

    if dx < 0 then
        self.area:moveLeftTo(self.target.x)
    elseif dx > 0 then
        self.area:moveRightTo(self.target.x + self.targetWidth)
    end

    if dy < 0 then
        self.area:moveUpTo(self.target.y)
    elseif dy > 0 then
        self.area:moveDownTo(self.target.y + self.targetHeight)
    end

    ::move::

    self:move_camera()
end

CameraWindow.__index = CameraWindow
