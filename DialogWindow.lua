
local dialog_window = {
    x = 0,
    y = 0,
    text = "",

    draw = function(self,x,y)

        local max_width = 0
        local count_width = 0
        local count_line = 0

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

        rect(x-5,y-5,max_width*6+10,count_line*8+10,0)
        print(self.text,x,y,15,true)
    end  

}

return dialog_window