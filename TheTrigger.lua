TriggerTile = table.copy(Body)

function TriggerTile:new(x, y, width, height, trigger)
    trace('hello Im Tiler!😍')
    width = width or 1
    height = height or 8
    local TilerDerden = {
        sprite = data.panda.sprite.stay_boring,
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
    }

    setmetatable(TilerDerden, self)
    self.__index = self; return TilerDerden
end

function TriggerTile:trigger()
    self.status = 'triggered'
    --trace(game.player.x..' '..game.player.y..' '..self.x..' '..self.y)
end

function TriggerTile:monitor_player()
    trace(game.player.x..' -- '..game.player.y)
end

function TriggerTile:is_colliding(collideable)
	return Physics.check_collision_obj_obj(self, collideable)
end

function TriggerTile:draw()
    Hitbox.rect_of(self):draw()
    --rect(self.x-5,self.y-5,10*9+10,10*9+9,0)
    if self.status == 'triggered' then
        local rx, ry = game.camera_window:transform_coordinates(self.x, self.y)
        spr(382, rx + self.button_offset.x, ry + self.button_offset.y)
    end
end

function TriggerTile:update()
	if self:is_colliding(game.player) then
		self:trigger()
	end
    if self.status == 'triggered' then
        --trace(table.length(game.dialog_window))

        self.button_pressed = btnp(BUTTON_A)
            --trace('a'..tostring(self.button_pressed))
            if GAMEMODE == GAMEMODE_DEBUG then
                self.button_pressed = self.button_pressed or key(KEY_TEST)
                --trace('b'..tostring(self.button_pressed))
            end

        if self.button_pressed and not self.drown then
            self.drown = true
            game.triggers.__is_active__ = {status = true, trigger = self}
            -- Здесь я делаю говнокод, потому что в таблицу где казалось бы лежат триггеры
            -- добавляю переменную, которая будет использоваться в DialogWindow
            -- Как говорил KanyaQT: "А что? Думаете это не круто ... ? ... Позор. ... Не, реально ... ."
            -- Если кто-то решит поменять Game, это ничего не поломает
            -- Если кто-то решит исправить это в DialogWindow, это всё поломает
            -- Поэтому мой долг снять с себя это вину и написать 8 строк о том,
            -- что нарушать это ХРУПКОЕ равновесие **НЕЛЬЗЯ**
            local __dx_dw = DialogWindow:new(self.x + self.dialog_offset.x, self.y + self.dialog_offset.y, self.dialog_text)
            table.insert(game.dialog_window, __dx_dw)
            game.status = not game.status
            --trace(tostring(self.trigger_button_pressed)..' '..'AAAAAAAAAAAAAAAAAAAAAHh💦💦💦')
        end
    end
    --self:monitor_player()
end