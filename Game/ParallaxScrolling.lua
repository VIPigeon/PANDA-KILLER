
ParallaxScrolling = {}

function ParallaxScrolling:new()
    local object = {
        speed = PARALLAX_LAYER_SPEED,
        offset = 0,
        tileId = PARALLAX_LAYER_TILE_ID,
        tileHeight = PARALLAX_TILE_HEIGHT * 16,
        target_x = 0,
    }
    setmetatable(object, self)
    return object
end

function ParallaxScrolling:update()
    local x = game.camera.x
    
    if (math.abs(self.target_x-x) > 0.1) then
        if(self.target_x-x > 0) then
            self.offset = (self.offset + self.speed) % 240
        else
            self.offset = (self.offset - self.speed) % 240
        end
    end
    self.target_x = x
end

function ParallaxScrolling:draw()
    local y = 0
    local tx, ty = game.camera:transform_coordinates(0, y)
    --while ty < 136 do 
        spr(self.tileId, self.offset,  ty + 50, 1, 4, 0, 0, 8, 2) 
        spr(self.tileId, self.offset - 240,  ty + 50, 1, 4, 0, 0, 8, 2) 
        --ty =  ty + self.tileHeight 
    --end
end

ParallaxScrolling.__index = ParallaxScrolling
