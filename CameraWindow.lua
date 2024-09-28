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

function CameraWindow:moveCamera()
    local centerX = math.floor(self.area:centerX())
    local centerY = math.floor(self.area:centerY())
    local tileX = math.floor(self.area:centerX() / 8)
    local tileY = math.floor(self.area:centerY() / 8)

    self.gm.x = tileX - math.floor(120 / 8)
    self.gm.sx = 8 * (tileX) - centerX

    self.gm.y = tileY - math.floor(68 / 8)
    self.gm.sy = 8 * (tileY) - centerY
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
        self:centerOnTarget()
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

    self:moveCamera()
end

CameraWindow.__index = CameraWindow
