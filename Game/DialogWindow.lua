
DialogWindow = {}

function DialogWindow:new(x, y, text)
    local object = {
        x = x,
        y = y,
        text = text,
        is_closed = true,
    }
    
    setmetatable(object, self)
    return object
end


function DialogWindow:update()
    -- здесь будет анимация
    if self.is_closed then
        return
    end

    self:close()
end


function DialogWindow:draw()
    -- a здесь вылетит птичка

    if self.is_closed then
        return
    end
    if game.player.is_dead then
        DialogWindow:draw_dialog_death()
        self.is_closed = false
    end
    
    -- Кто поменяет, тот бед не оберётся
    
    if not (TriggerTiles.__is_active__ == nil) and TriggerTiles.__is_active__.status and TriggerTiles.__is_active__.type == 'MONOLOGUE' then
        -- Нужен рефакторинг🙄
        -- СДЕЛАНО!! 😄👍
        DialogWindow:draw_monologue(TriggerTiles.__is_active__.trigger)

        self.is_closed = false
    end

    if not (TriggerTiles.__is_active__ == nil) and TriggerTiles.__is_active__.status and TriggerTiles.__is_active__.type == 'BIKE' then
        DialogWindow:draw_bikelogue(TriggerTiles.__is_active__.trigger)

        self.is_closed = false
    end

    -- когда-нибудь пофиксим🙏
    if self.tugologue then
        self:draw_tugologue(self.trigger)
        self.is_closed = false
    end
end 
    
function DialogWindow:draw_dialog()
    if self.text == "" then
        return
    end
    local max_width = 0
    local count_width = 0
    local count_line = 1

    for i = 1, #self.text do
        if self.text:sub(i,i) ~= '\n' then
            count_width = count_width + 1
        else 
            if max_width < count_width then
                max_width = count_width   
            end
            count_line = count_line + 1
            count_width = 0
        end
    end
    if max_width < count_width then
        max_width = count_width   
    end

    rect(self.x-5,self.y-5,max_width*9+10,count_line*9+9,0)
    font(self.text,self.x,self.y,15,true)
end

function DialogWindow:draw_dialog_death()
    self.text = localize(TEXT.PRESS_ANY_BUTTON_TO_RESPAWN)
    self.x = 0
    self.y = 0
    rect(self.x,self.y,SCREEN_WIDTH,SCREEN_HEIGHT,0)
    self:draw_dialog()
end 

function DialogWindow:draw_monologue(trigger)
    self.text = russian_to_translit(trigger.dialog_text)
    self.x = trigger.x + trigger.dialog_offset.x
    self.y = trigger.y + trigger.dialog_offset.y
    rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 0)
    self:draw_dialog()
end

function DialogWindow:draw_bikelogue(trigger)
    --self.text = russian_to_translit(trigger.dialog_text)
    --self.x = trigger.x + trigger.dialog_offset.x
    --self.y = trigger.y + trigger.dialog_offset.y
    --rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 0)
    --self:draw_dialog()
    trigger.wrapper:init_go_away()
    trigger.wrapper:go_away()
    trigger.wrapper:draw()
end

-- аварийная функция. Просьба забрать все ценные вещи до 12.03.25
function DialogWindow:draw_tugologue()
    -- я не думмаю, что это сильно плохая практика для такого небольшого количества механик,
    -- как раз, ровно столько, сколько есть у нас
    --self.tugologue = true
    -- да, если у dialogwindow не будет синглтоном или что-то будет происходить с triggerом,
    -- то возможно не unопределённое behaveдение
    self.text_progress = ClickerMinigame.update_progress_for_visual()

    self.text = 'PROG'..self.text_progress
    -- 'BANBOOK GAME. LIFE OR DEATH?'
    self.x = 0
    self.y = 0
    rect(self.x, self.y, 50, 50, 0)
    self:draw_dialog()
end

function DialogWindow:close()
    -- Я убрал отсюда проверку на BUTTON_A, потому что перестаёт работать диалог по триггеру.
    --Если это действительно нужно, потом разберёмся
    if Basic.is_any_key_pressed() then
        self.is_closed = true
        self.text = ""
        self:draw_dialog()

        -- Отзыв от **сотрудник**@sisyphus.jam (2025.02.25)
        -- Если триггер должен быть реализован через рисовать диалог, то ниже несусветный bad design
        game.restart()

        -- Памятка о EXCLUSIVE DIRTY PROCEDURE DISIGN
        -- game.state = GAME_STATE_GAMEPLAY
    end
end

DialogWindow.__index = DialogWindow  -- Это должно быть в самом конце🤦‍♂️
