
DialogWindow = {}

function DialogWindow:new(x, y, text)
    local obj = {
        x = x,
        y = y,
        text = text,
    }
    
    setmetatable(obj,self)  -- чистая магия!
    return obj
end


function DialogWindow:update()
    -- здесь будет анимация
    self:close()
end


function DialogWindow:draw()
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

    rect(self.x-5,self.y-5,max_width*6+10,count_line*6+9,0)
    print(self.text,self.x,self.y,15,true)
end 

function DialogWindow:close()
    if btn(4) or btn(5) or btn(6) or btn(7) then
        self.text = ""
    end
end

DialogWindow.__index = DialogWindow  -- Это должно быть в самом конце🤦‍♂️