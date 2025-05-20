-- sync(0, 1, false)

ADDR = 0x3FC0

palette = {
    defaultColors={},
    whiteColor = {r=255, g=255, b=255},
    bgColor = {r=63, g=31, b=60},
    isOneBit = false
}


astropalette = {
    white = {218, 242, 233},
    light_blue = {149, 224, 204},
    blue = {57, 112, 122},
    dark_blue = {35, 73, 93},
    bg = {28, 38, 56},
    red = {241, 78, 82},
    dark_red = {155, 34, 43},
    black = {0, 0, 0},
}

function palette.toggle1Bit()
    -- небольшая подмена
    palette.toggleAstroPalette()

    --[[
    for id = 1, 15 do
        local color
        if not palette.isOneBit then
            if id == 6 then
                color = palette.bgColor
            else
                color = palette.whiteColor
            end
        else
            color = palette.defaultColors[id]
        end

        palette.colorChange(id, color.r, color.g, color.b)
    end

    palette.isOneBit = not palette.isOneBit
    --]]
end


function palette.toggleAstroPalette()
    palette.isOneBit = not palette.isOneBit

    if not palette.isOneBit then
        for id = 1, 15 do
            local color = palette.defaultColors[id]
            palette.colorChange(id, color.r, color.g, color.b)
        end
        return
    end

    palette.colorChange(0, astropalette.bg[1], astropalette.bg[2], astropalette.bg[3])
    palette.colorChange(1, astropalette.red[1], astropalette.red[2], astropalette.red[3])
    palette.colorChange(2, astropalette.blue[1], astropalette.blue[2], astropalette.blue[3])
    palette.colorChange(3, astropalette.light_blue[1], astropalette.light_blue[2], astropalette.light_blue[3])
    palette.colorChange(4, astropalette.blue[1], astropalette.blue[2], astropalette.blue[3])
    palette.colorChange(5, astropalette.blue[1], astropalette.blue[2], astropalette.blue[3])
    palette.colorChange(6, astropalette.black[1], astropalette.black[2], astropalette.black[3])
    palette.colorChange(7, astropalette.dark_red[1], astropalette.dark_red[2], astropalette.dark_red[3])
    palette.colorChange(8, astropalette.light_blue[1], astropalette.light_blue[2], astropalette.light_blue[3])
    palette.colorChange(9, astropalette.blue[1], astropalette.blue[2], astropalette.blue[3])
    palette.colorChange(10, astropalette.dark_blue[1], astropalette.dark_blue[2], astropalette.dark_blue[3])
    palette.colorChange(11, astropalette.white[1], astropalette.white[2], astropalette.white[3])
    palette.colorChange(12, astropalette.white[1], astropalette.white[2], astropalette.white[3])
    palette.colorChange(13, astropalette.white[1], astropalette.white[2], astropalette.white[3])
    palette.colorChange(14, astropalette.red[1], astropalette.red[2], astropalette.red[3])
    palette.colorChange(15, astropalette.light_blue[1], astropalette.light_blue[2], astropalette.light_blue[3])
end


function palette.getColor(id)
    color = {}
    color.r = peek(ADDR+(id*3))
    color.g = peek(ADDR+(id*3)+1)
    color.b = peek(ADDR+(id*3)+2)
    return color
end

function palette.colorChange(id, red, green, blue)
    -- id -- color index in tic80 palette
    -- red, green, blue -- new color parameters
    poke(ADDR+(id*3), red)
    poke(ADDR+(id*3)+1, green)
    poke(ADDR+(id*3)+2, blue)
end

function palette.ghostColor(GC)
    -- я понятия не имею как это работает
    -- я тоже 😎😎
    -- Всем привет, ребята 🤠
    -- здесь GC = 11
    local id = GC  -- id цвета
    poke(ADDR+(id*3)+2, peek(ADDR))  -- red
    poke(ADDR+(id*3)+1, peek(ADDR+1))  -- green
    poke(ADDR+(id*3), peek(ADDR+2))  -- blue
end

for i = 1, 15 do
    local color = palette.getColor(i)
    table.insert(palette.defaultColors, color)
end
