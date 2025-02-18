
DialogWindow = {}

function DialogWindow:new(x, y, text)
    local obj = {
        x = x,
        y = y,
        text = text,
        is_closed = false,
    }
    
    setmetatable(obj,self)  -- чистая магия!
    return obj
end


function DialogWindow:update()
    -- здесь будет анимация

    self:close()
end


function DialogWindow:draw()
    -- a здесь вылетит птичка

    --trace('im closed')
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
        trace('reading dialog of trigger-'..tostring(TriggerTiles.__is_active__.trigger))
        DialogWindow:draw_monologue(TriggerTiles.__is_active__.trigger)

        self.is_closed = false
    end

    if not (TriggerTiles.__is_active__ == nil) and TriggerTiles.__is_active__.status and TriggerTiles.__is_active__.type == 'BIKE' then
        --trace('wrrrrrrrrrrrrrrrr')
        DialogWindow:draw_bikelogue(TriggerTiles.__is_active__.trigger)

        self.is_closed = false
    end

    -- когда-нибудь пофиксим🙏
    if self.tugologue then
        self:draw_tugologue()
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
    self.text = russian_to_translit('\n\n\n\n\n\n  ДЛЯ ВОЗРОЖДЕНИЯ НАЖМИТЕ\n   НА ОДНУ ЛЮБУЮ КНОПКУ')
    self.x = 0
    self.y = 0
    rect(self.x,self.y,SCREEN_WIDTH,SCREEN_HEIGHT,0)
    self:draw_dialog()
end 

function DialogWindow:draw_monologue(trigger)
    --trace('hellp')
    self.text = russian_to_translit(trigger.dialog_text)
    self.x = trigger.x + trigger.dialog_offset.x
    self.y = trigger.y + trigger.dialog_offset.y
    rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 0)
    self:draw_dialog()
    --trace(self.text)
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

function DialogWindow:draw_tugologue(trigger)
    -- я не думмаю, что это сильно плохая практика для такого небольшого количества механик,
    -- как раз, ровно столько, сколько есть у нас
    self.tugologue = true
    -- да, если у dialogwindow не будет синглтоном или что-то будет происходить с triggerом,
    -- то возможно не unопределённое behaveдение
    self.trigger = trigger
    self.trigger.text_progress = ClickerMinigame.update_progress_for_visual()

    self.text = 'PROG'..self.trigger.text_progress
    -- 'BANBOOK GAME. LIFE OR DEATH?'
    self.x = 0
    self.y = 0
    rect(self.x, self.y, 50, 50, 0)
    self:draw_dialog()

    ClickerMinigame:update()
    ClickerMinigame:draw()
end

function DialogWindow:close()
    -- Я убрал отсюда проверку на BUTTON_A, потому что перестаёт работать диалог по триггеру.
    --Если это действительно нужно, потом разберёмся
    if btnp(BUTTON_S) or btnp(BUTTON_X) or btnp(BUTTON_Z) then
        self.is_closed = true
        self.text = ""
        self:draw_dialog()
        game.status = true
        game.player.is_dead = false
        game.dialog_window = DialogWindow:new(0,0, '')
    end
end

DialogWindow.__index = DialogWindow  -- Это должно быть в самом конце🤦‍♂️
