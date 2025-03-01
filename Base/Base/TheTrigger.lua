TriggerTile = table.copy(Body)

function TriggerTile:new(x, y, width, height, triggerAction, sprite, wrapper)
    width = width or 1
    height = height or 8
    wrapper = wrapper or nil
    sprite = sprite or nil
    local TilerDerden = {
        sprite = sprite,
        hitbox = Hitbox:new(0, 0, width, height),
        x = x, y = y,
        status = 'idle',
        button_pressed = false,
        button_offset = {
            x = width // 8, y = -(height // 8 + 12),
        },
        dialog_offset = {
            x = width // 8 - 12, y = - (height // 8 + 24)
        },
        dialog_text = 'А ТАКОЕ ВИДЕЛ?',
        drown = false, -- keep calm🤙 just chill bro. funny name

        trigger_action = triggerAction,
        wrapper = wrapper,
    }

    setmetatable(TilerDerden, self)
    self.__index = self; 
    return TilerDerden
end

function TriggerTile:trigger()
    self.status = 'triggered'
end

function TriggerTile:untrigger()
    self.status = 'idle'
end

function TriggerTile:monitor_player()
end

function TriggerTile:is_colliding(collideable)
	return Physics.check_collision_obj_obj(self, collideable)
end

function TriggerTile:draw()
    Hitbox.rect_of(self):draw()
    
    --rect(self.x-5,self.y-5,10*9+10,10*9+9,0)
    if self.status == 'triggered' then
        local rx, ry = game.camera:transform_coordinates(self.x, self.y)
        spr(109, rx + self.button_offset.x, ry + self.button_offset.y)
    end
end

function TriggerTile:update()
	if self:is_colliding(game.player) then
        TriggerTiles.__is_active__ = nil
        self:trigger()
	end
    if self.status == 'triggered' then

        if not self:is_colliding(game.player) then
            self:untrigger()
        end

        self.button_pressed = btnp(BUTTON_A)

        self.trigger_action(self)
    end
    --self:monitor_player()
end

--Я взял идею у Вани. Ну это удобно, но entities было бы удобнее. Как обычно, лишь бы дублировать код. Только и умеете, что копипастить, трудоголики🥶🥶🐴
TriggerTiles = {
    Tiles = {}
}

function TriggerTiles.add(TriggerTile)
    table.insert(TriggerTiles.Tiles, TriggerTile)
end

function TriggerTiles.update()
    for _, trigger in ipairs(game.triggers) do
        trigger:update()
    end
end

function TriggerTiles.draw()
    for _, trigger in ipairs(game.triggers) do
        trigger:draw()
    end
end

TriggerActions = {}

function TriggerActions.dialogue(triggerTile)
    if triggerTile.button_pressed and not triggerTile.drown then
        --self.drown = true
        TriggerTiles.__is_active__ = {status = true, trigger = triggerTile, type = 'MONOLOGUE'}
        -- Здесь я делаю говнокод, потому что в таблицу где казалось бы лежат триггеры
        -- добавляю переменную, которая будет использоваться в DialogWindow
        -- Как говорил KanyaQT: "А что? Думаете это не круто ... ? ... Позор. ... Не, реально ... ."
        -- Если кто-то решит поменять Game, это ничего не поломает
        -- Если кто-то решит исправить это в DialogWindow, это всё поломает
        -- Поэтому мой долг снять с себя это вину и написать 8 строк о том,
        -- что нарушать это ХРУПКОЕ равновесие **НЕЛЬЗЯ**
        local __dx_dw = DialogWindow:new(triggerTile.x + triggerTile.dialog_offset.x, triggerTile.y + triggerTile.dialog_offset.y, triggerTile.dialog_text)
        __dx_dw.is_closed = false
        table.insert(game.CRUTCH_dialog_window, __dx_dw)
        game.state = GAME_STATE_RIDING_BIKE
        triggerTile:untrigger()
    end
end

function TriggerActions.bike(triggerTile)
    if true then --triggerTile.button_pressed then
        triggerTile.wrapper.sprite = data.bike.sprite.saddled

        TriggerTiles.__is_active__ = {status = true, trigger = triggerTile, type = 'BIKE'}
        -- Если после сцены с байком будет что-то кроме титров(например сцена после титров), то всё сломается
        game.player.hide = true
        local __dx_dw = DialogWindow:new(0, 0, 0, 0, '')
        __dx_dw.is_closed = false
        table.insert(game.CRUTCH_dialog_window, __dx_dw)
        game.state = GAME_STATE_RIDING_BIKE
        triggerTile:untrigger()
    end
end

function TriggerActions.tug_of(triggerTile)
    if true then
        -- dead code
        game.state = GAME_STATE_RIDING_BIKE
        TriggerTiles.__is_active__ = {status = true, trigger = triggerTile, type = 'TUGGING'}
        local __dx_dw = DialogWindow:new(triggerTile.x + triggerTile.dialog_offset.x, triggerTile.y + triggerTile.dialog_offset.y, triggerTile.dialog_text)
        __dx_dw.is_closed = false
        table.insert(game.CRUTCH_dialog_window, __dx_dw)
    end
end
