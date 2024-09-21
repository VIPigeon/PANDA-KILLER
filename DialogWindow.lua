
DialogWindow = {}

function DialogWindow:new()
    local obj ={
        x = 0,
        y = 0,
        text = ""
    }
    
    setmetatable(obj,self)
    return obj
end

function DialogWindow:update(x,y,text)
    self.x = x
    self.y = y
    self.text = text
end

function DialogWindow:draw()
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

DialogWindow.__index = DialogWindow --Это должно быть в самом конце🤦‍♂️