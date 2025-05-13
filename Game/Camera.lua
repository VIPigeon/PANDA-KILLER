Camera = {}

CAMERA_STATE_NORMAL = 0
CAMERA_STATE_SHAKING = 1

CAMERA_NO_HORIZONTAL_PAN = 0
CAMERA_PANNING_LEFT = 1
CAMERA_PANNING_RIGHT = 2

function Camera:new(player)
    local object = {
        x = 0,
        y = 0,

        center_x = player.x + 8,
        center_y = player.y,
        pan_x_velocity = 0.0,
        pan_y_velocity = 0.0,

        horizontal_pan_state = CAMERA_NO_HORIZONTAL_PAN,
        --vertical_pan_state = CAMERA_NO_VERTICAL_PAN,

        player = player,

        state = CAMERA_STATE_NORMAL,
        shake_magnitude = 0,
        shake_time_left = 0,

        time_since_player_changed_direction = 0.0,
        --scale = 1,
    }

    setmetatable(object, self)
    return object
end

-- function Camera:rescale(scale_mult)
--     for y = 0, 135 do
--         for x = 0, 239 do
--             local color = pix(x, y)
--             --trace('rescaling')
--             rect(x * scale_mult, y * scale_mult, scale_mult, scale_mult, color)
--         end
--     end
-- end

function Camera:transform_coordinates(x, y)
    local tx = x + SCREEN_WIDTH/2 - math.floor(self.x)
    local ty = y + SCREEN_HEIGHT/2 - math.ceil(self.y) - 4
    return tx, ty
end

function Camera:shake(magnitude, duration)
    self.state = CAMERA_STATE_SHAKING
    self.shake_magnitude = magnitude
    self.shake_time_left = duration
end

function Camera:trap_inside_borders(min_x, max_x, min_y, max_y)
    local tile_x = math.floor(self.x / 8)
    local camera_tile_width = math.floor(SCREEN_WIDTH / 16)

    local left_border = tile_x - camera_tile_width
    if left_border < min_x then
        self.x = 8 * (min_x + camera_tile_width)
    end
    local right_border = tile_x + camera_tile_width
    if right_border > max_x then
        self.x = 8 * (max_x - camera_tile_width + 1)
    end


    local tile_y = math.floor(self.y / 8)
    local camera_tile_height = math.floor(SCREEN_HEIGHT / 16)

    local upper_border = tile_y - camera_tile_height
    if upper_border < min_y then
        self.y = 8 * (min_y + camera_tile_height)
    end
    local bottom_border = tile_y + camera_tile_height
    if bottom_border > max_y then
        self.y = 8 * (max_y - camera_tile_height + 1)
    end
end

function Camera:set_position(x, y)
    self.center_x = x
    self.center_y = y
    self.x = x
    self.y = y
end

function Camera:update()
    local player = self.player
    local player_x = (player.x + 8)
    local line_left_x = self.center_x - CAMERA_LINES_DISTANCE_FROM_CENTER
    local line_right_x = self.center_x + CAMERA_LINES_DISTANCE_FROM_CENTER

    -- if self.scale ~= 1 then
    --     trace('hahahahahhahahah')
    --     self:rescale(self.scale)
    -- end

    if self.horizontal_pan_state == CAMERA_NO_HORIZONTAL_PAN then
        self.time_since_player_changed_direction = 0.0
        if player_x < line_left_x - CAMERA_PAN_OFFSET  then
            if player.looking_left then
                self.horizontal_pan_state = CAMERA_PANNING_LEFT
                self.pan_x_velocity = 0
            end
        elseif player_x > line_right_x + CAMERA_PAN_OFFSET then
            if not player.looking_left then
                self.horizontal_pan_state = CAMERA_PANNING_RIGHT
                self.pan_x_velocity = 0
            end
        end
    elseif self.horizontal_pan_state == CAMERA_PANNING_LEFT then
        if not player.looking_left then
            self.time_since_player_changed_direction = self.time_since_player_changed_direction + Time.dt()
            if self.time_since_player_changed_direction > CAMERA_DIRECTION_CHANGE_TIME then
                self.horizontal_pan_state = CAMERA_NO_HORIZONTAL_PAN
                self.pan_x_velocity = 0
            end
        else
            self.time_since_player_changed_direction = 0.0
        end

        local next_x, next_velocity = math.smooth_damp(line_right_x, player_x + CAMERA_PAN_OFFSET, self.pan_x_velocity, CAMERA_SMOOTH_TIME)

        self.center_x = next_x - CAMERA_LINES_DISTANCE_FROM_CENTER
        self.pan_x_velocity = next_velocity
    elseif self.horizontal_pan_state == CAMERA_PANNING_RIGHT then
        if player.looking_left then
            self.time_since_player_changed_direction = self.time_since_player_changed_direction + Time.dt()
            if self.time_since_player_changed_direction > CAMERA_DIRECTION_CHANGE_TIME then
                self.horizontal_pan_state = CAMERA_NO_HORIZONTAL_PAN
                self.pan_x_velocity = 0
            end
        else
            self.time_since_player_changed_direction = 0.0
        end

        local next_x, next_velocity = math.smooth_damp(line_left_x, player_x - CAMERA_PAN_OFFSET, self.pan_x_velocity, CAMERA_SMOOTH_TIME)

        self.center_x = next_x + CAMERA_LINES_DISTANCE_FROM_CENTER
        self.pan_x_velocity = next_velocity
    end

    local player_y = player.y
    if player_y - self.center_y > CAMERA_LINES_DISTANCE_FROM_CENTER then
        self.center_y = self.center_y + (player_y - self.center_y - CAMERA_LINES_DISTANCE_FROM_CENTER)
    elseif self.center_y - player_y > CAMERA_LINES_DISTANCE_FROM_CENTER then
        self.center_y = self.center_y - (self.center_y - player_y - CAMERA_LINES_DISTANCE_FROM_CENTER)
    end

    self.x = self.center_x
    self.y = self.center_y

    self:trap_inside_borders(game.current_level.min_x, game.current_level.max_x, game.current_level.min_y, game.current_level.max_y)

    if self.shake_time_left > 0 then
        self.x = self.x + math.random_sign() * self.shake_magnitude
        self.y = self.y + math.random_sign() * self.shake_magnitude
        self.shake_time_left = Basic.tick_timer(self.shake_time_left)
    end

    -- Дебаг, рисует линии, управляющие камерой 🕷️
    --
    --Debug.add(function()
    --    local middle_x = self.center_x
    --    local left_x = middle_x + (line_left_x - self.center_x)
    --    local right_x = middle_x + (line_right_x - self.center_x)

    --    local left_pan_x = left_x + CAMERA_PAN_OFFSET
    --    local right_pan_x = right_x - CAMERA_PAN_OFFSET

    --    local left_transition_x = left_x - CAMERA_PAN_OFFSET
    --    local right_transition_x = right_x + CAMERA_PAN_OFFSET

    --    local transformed_line = function(x1, y1, x2, y2, color)
    --        local tx1, ty1 = self:transform_coordinates(x1, y1)
    --        local tx2, ty2 = self:transform_coordinates(x2, y2)
    --        line(tx1, ty1, tx2, ty2, color)
    --    end

    --    transformed_line(left_x, 0, left_x, WORLD_HEIGHT, 2)
    --    transformed_line(middle_x, 0, middle_x, WORLD_HEIGHT, 2)
    --    transformed_line(right_x, 0, right_x, WORLD_HEIGHT, 2)

    --    transformed_line(left_pan_x, 0, left_pan_x, WORLD_HEIGHT, 3)
    --    transformed_line(right_pan_x, 0, right_pan_x, WORLD_HEIGHT, 3)

    --    transformed_line(left_transition_x, 0, left_transition_x, WORLD_HEIGHT, 4)
    --    transformed_line(right_transition_x, 0, right_transition_x, WORLD_HEIGHT, 4)
    --end)
end

Camera.__index = Camera
