cutscene = {}

function special_panda_update(self)
	--self.state = PANDA_STATE.chase
	local our_rect = Hitbox.rect_of(self)
	local player_rect = Hitbox.rect_of(game.player)

	local sprites = SPRITES.panda[self.type]

	self:set_look_direction(math.sign(player_rect:center_x() - our_rect:center_x()))

    local should_we_chase_the_player = true
    local x_direction_to_player = math.sign(player_rect:center_x() - our_rect:center_x())

    self.velocity.x = PANDA_SETTINGS[self.type].chase_speed * x_direction_to_player

    local x_distance_to_player = math.abs(player_rect:center_x() - our_rect:center_x())
    local y_distance_to_player = math.abs(player_rect:center_y() - our_rect:center_y())

    if x_distance_to_player <= PANDA_X_DISTANCE_TO_PLAYER_UNTIL_BASIC_ATTACK and y_distance_to_player <= PANDA_Y_DISTANCE_TO_PLAYER_UNTIL_BASIC_ATTACK then
    	Basic.play_sound(SOUNDS.PANDA_BASIC_ATTACK_CHARGE)
    	game.state = GAME_STATE_CLICKERMINIGAME
    	ClickerMinigame:init(self)
    end
    Physics.update(self)

    self.animation_controller:set_sprite(sprites.chase)
    self.animation_controller:next_frame()
end

function cutscene:init()
	
	PLAYER_SPAWNPOINT_X = 10*8
	PLAYER_SPAWNPOINT_Y = 11*8

	cutscene.something_in_the_shape_of_panda = Panda:new(15 * 8, 11 * 8, PANDA_TYPE.basic)
	cutscene.something_in_the_shape_of_panda.special_update = special_panda_update
	table.insert(game.current_level.pandas, cutscene.something_in_the_shape_of_panda)
end


function cutscene:update()
	cutscene.something_in_the_shape_of_panda:special_update()
end

function cutscene:draw()
	game.draw_map()
	game.player:draw()
	cutscene.something_in_the_shape_of_panda:draw()
end
