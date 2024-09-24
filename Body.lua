Body = {}

function Body:new(sprite, x, y)
    local obj = {
        sprite = sprite,
        hitbox = 'nil',
        flip = 0,
        rotate = 0,
        x = x, y = y,
        isDead = false,  -- в этой игре не нужно понятие здоровья
        born_flag = true
    }

    setmetatable(obj, self)
    self.__index = self; return obj
end

-- no collideables
function Body:willCollideAfter(dx, dy)
    local oldX = self.x
    local oldY = self.y

    self:move(dx, dy)
    -- если враги будут уметь двигаться, то будет ошибка из-за проверки с самим собой
    for _, collideable in ipairs(game.collideables) do
        if collideable.hitbox == nil then
            if collideable.hitboxLeft:collide(self.hitbox) or
                collideable.hitboxRight:collide(self.hitbox) then
                    self:set_position(oldX, oldY)
                    return true
            end
        elseif collideable.hitbox:collide(self.hitbox) then
            self:set_position(oldX, oldY)
            return true
        end
    end
    local will_collide = not self.hitbox:mapCheck()

    self:set_position(oldX, oldY)
    return will_collide
end

function Body:moveUnclamped(dx, dy)
    local newX = self.x + dx * Time.dt()
    local newY = self.y + dy * Time.dt()

    self.x = newX
    self.y = newY

    self.hitbox:set_xy(self.x, self.y)
end

function Body:move(dx, dy)
    local newX = self.x + dx
    local newY = self.y + dy

    self.x = newX
    self.y = newY

    --self.x = math.clamp(newX, 0, 240 - 8)
    --self.y = math.clamp(newY, 0, 136 - 8)

    self.hitbox:set_xy(self.x, self.y)
end

function Body:stay_in_borders()
    self.x = math.clamp(newX, 0, 240 - 8)
    self.y = math.clamp(newY, 0, 136 - 8)

    self.hitbox:set_xy(self.x, self.y)
end

function Body:set_position(x, y)
    self.x = x
    self.y = y
    self.hitbox:set_xy(x, y)
end

--OOPSie there's no GAME MASTER in this game
function Body:draw()
    --self.sprite:draw(self.x - gm.x*8 + gm.sx, self.y - gm.y*8 + gm.sy, self.flip, self.rotate)
    self.sprite:draw(self.x, self.y, self.flip, self.rotate)
end

function Body:born_update()
    self:draw()
    if self.sprite:animationEnd() then
        self.born_flag = false
        return false
    end
    self.sprite:nextFrame()
    return true
end

return Body
