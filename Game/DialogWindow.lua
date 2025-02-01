
DialogWindow = {}

function DialogWindow:new(x, y, text)
    local object = {
        x = x,
        y = y,
        text = text,
        is_closed = false,
    }
    
    setmetatable(object,self)  -- чистая магия!
    return object
end


function DialogWindow:update()
    -- здесь будет анимация
    
    self:close()
end


function DialogWindow:draw()
    if self.is_closed then
        return
    end
    if game.player.is_dead then
        DialogWindow:draw_dialog_death()
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

function DialogWindow:close()
    if btn(BUTTON_A) or btn(BUTTON_S) or btn(BUTTON_X) or btn(BUTTON_Z) then
        self.is_closed = true
        self.text = ""
        self:draw_dialog()
        game.state = GAME_STATE_GAMEPLAY
        game.player.is_dead = false
    end
end

DialogWindow.__index = DialogWindow  -- Это должно быть в самом конце🤦‍♂️
