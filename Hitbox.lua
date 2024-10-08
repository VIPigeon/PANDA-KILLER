--[[

Хитбокс -- коробка 📦, которая обязательно прикрепляется к чему-то другому, у чего
есть позиция. Например:

player = {
    x = 10,
    y = 20,
    hitbox = Hitbox:new(2, 0, 8, 8),
}

Хитбокс описывается как отступ от левого верхнего края какого-то объекта (в примере
выше этот объект -- игрок) с каким-то размером. Чтобы использовать хитбокс для
проверки коллизии, нужно сделать из него прямоугольник с помощью to_rect или
rect_of.

Всё так сложно потому что Hitbox -- для локальных координат, а
Rect -- для глобальных координат. Локальные координаты удобнее, но у них
нельзя проверять коллизии, поэтому перед любой физикой мы переводим локальные
координаты в глобальные, или же Hitbox -> Rect

Объясню с помощью рисунка ✏:

Картинка 1
    (x = 240, y = 15)
        +-----------+
        |           |
        |           |
        |           |
        |           |
        +-----------+

        ^^^^^^^^^^^^^ Игрок

Картинка 2
    (x = 240, y = 15)
        +-----------+
        |  +-----+  |
        |  |     |  |
        |  |     |  |
        |  |     |  |
        +--+-----+--+

            ^^^^^ Хитбокс игрока (слегка меньше чем сам спрайт).
                  У него offset_x = 2, offset_y = 1 -- локальные координаты.

Картинка 3
  (x = 240 + offset_x, y = 15 + offset_y)
           +-----+
           |     |
           |     |
           |     |
           +-----+
           ^^^^^^^ Прямоугольник! До этого у нас были локальные координаты, начало
                   которых было в левом верхнем углу игрока (offset_x, offset_y),
                   а теперь мы преобразовали их в глобальные координаты.

Предыстория такого решения:
@kawaii-Code, где-то в далёком сентябре 2024:
-- Дуальность хитбоксов с оффсетом и без меня подбешивает 🤬
-- Есть хитбокс с offset_x, offset_y, который нужно прицеплять к другому
-- игровому объекту, а есть самостоятельный хитбокс (просто прямоугольник)
-- у которого есть x, y -- мировые координаты. И с ними
-- немного путаница. Вот бы строго типизированный язык 😋
--
-- Эта функция переводит из оффсетного в самостоятельный прямоугольник

--]]

Hitbox = {}

function Hitbox:new(offset_x, offset_y, width, height)
    local object = {
        offset_x = offset_x,
        offset_y = offset_y,
        width = width,
        height = height,
    }

    setmetatable(object, self)
    return object
end

function Hitbox:to_rect(x, y)
    return Rect:new(x + self.offset_x, y + self.offset_y, self.width, self.height)
end

function Hitbox.rect_of(object)
    if (object.x == nil or object.y == nil) then
        error('mistake in hitbox argument: object.x and object.y are missing')
    end
    if (object.hitbox == nil) then
        error('mistake in hitbox argument: object.hitbox is missing')
    end
    if (object.hitbox.to_rect == nil) then
        error('mistake in hitbox argument: object.hitbox is not of class Hitbox')
    end
    return object.hitbox:to_rect(object.x, object.y)
end

Hitbox.__index = Hitbox
