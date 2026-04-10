-- Make shure you read the disclaimer

--⚠⚠ NO SINGLE OOP WILL BE USED HERE ⚠⚠

-- not Кавай-мир победил or монолит оказался сильней.


-- Consider you read the disclaimer

-- User Manual:
-- 
-- У панды появляется поле kantugging_friend_panda - обозначает, важна ли для неё её палка настолько,
--                             ^-- Неправда!!! 
--                                      ^-- Может быть и нет, но когда я это писал - было, я уже забыл, честно говоря, вы там наверное уже всё пофиксили
-- чтобы она за неё дралась.
-- Если да, то по функции активации σ(panda, player) запускается игра кликер.
-- Подробнее о σ(x,y) см. в приложении 2.
--
-- Принцип работы панда-кликера:
-- Используется простая система, двух сил, сдержек и неравных противовесов.
-- 
-- Основная игра останавливается, экран кинематографично приближается к действующим героям.
-- (это сделано через диалоговые окна)
-- 



ClickerMinigame = {}

MINIGAME_SCALING_CONST = 2
INITIAL_SCALE = 1

MAX_PLAYER_FORCE = 8
MIN_PLAYER_FORCE = 0
MAGIC_MULTIPLIER = 16

CONSTANT_PANDA_FORCE = 4
MAX_PROGRESS = 100
MIN_PROGRESS = 0
START_PROGRESS = 50

PROGRESS_BAR_POSITION_X = 20
PROGRESS_BAR_POSITION_Y = 8
PROGRESS_BAR_WIDTH = 200
PROGRESS_BAR_HEIGHT = 20
PROGRESS_BAR_BACKCOLOR = 3
PROGRESS_BAR_PLAYERCOLOR = 11
PROGRESS_BAR_PANDACOLOR = 14
PROGRESS_BAR_PADDING_X = 2
PROGRESS_BAR_PADDING_Y = 2

current_player_force = MIN_PLAYER_FORCE
current_panda_force = CONSTANT_PANDA_FORCE
progress = START_PROGRESS
is_game_over = false
is_player_win = false
trigger_panda = nil

trigger_flip_panda = 1
trigger_stick = false

function ClickerMinigame:init(panda)
    -- наверное придётся поменять у панды её выражение лица, жесты, позу, самочувствие.
    -- TODO so
    trigger_panda = panda
    trigger_panda:draw()
    
    --trace('init')
    --trace(panda)
    -- я сделаю обёртку триггером, чтобы работало медленнее. Не люблю, когда больше 60 fps.
    game.state = GAME_STATE_CLICKERMINIGAME
    --trigger = {panda= panda, text_progress= ClickerMinigame:update_progress_for_visual()}
    --local __dx_dw = DialogWindow:new(0, 0, 'hi')
    --__dx_dw.is_closed = false
    --__dx_dw:draw_tugologue(trigger)
    --table.insert(game.CRUTCH_dialog_window, __dx_dw)

    INITIAL_SCALE = game.scale

    animation_controller_player = AnimationController:new(SPRITES.cutscene.start_player)
    animation_controller_panda = AnimationController:new(SPRITES.cutscene.start_panda)

    ClickerMinigame:rescale_game(true)

    ClickerMinigame:reset_local_var()

end

function ClickerMinigame:rescale_game(upscale)
    local scale = MINIGAME_SCALING_CONST
    if not upscale then
        scale = INITIAL_SCALE
    end

    game.scale = scale

    -- game.camera.scale = scale
    -- game.camera:rescale(scale)
end

function ClickerMinigame:gameover()
    game.state = GAME_STATE_GAMEPLAY

    -- надо выйти в игру нормально и все следы миниигры уничтожить
    if is_player_win then
        trigger_panda:take_damage()
        -- trigger_panda:take_damage()

        -- viewership awkward or other gift for player
    else
        game.player:die()
    end
    
    ClickerMinigame:rescale_game(false)
    -- may be some animations

end

-- Аварийная функция будет удалена 12.03.25
function ClickerMinigame:update_progress_for_visual()
    res = ''
    
    -- haha мне лень гуглить, как умножать строки или сделать проще
    for i = 0, progress / 10 do
        res = res..'A'
    end

    return res..'\n'
end

function ClickerMinigame:draw_progress_bar()
    -- let bar separation be equal for both sides, then

    -- ФОН (phone)
    rect(PROGRESS_BAR_POSITION_X - PROGRESS_BAR_PADDING_X, PROGRESS_BAR_POSITION_Y, 
        PROGRESS_BAR_WIDTH + PROGRESS_BAR_PADDING_X, PROGRESS_BAR_HEIGHT, 
        PROGRESS_BAR_BACKCOLOR)

    half_width = math.floor(PROGRESS_BAR_WIDTH / 2)

    -- ЗАПОЛНЕНИЕ (filling)
    if progress > START_PROGRESS then
        local fill_width = math.floor((progress - START_PROGRESS) / MAX_PROGRESS * PROGRESS_BAR_WIDTH)

        rect(PROGRESS_BAR_POSITION_X + half_width, PROGRESS_BAR_POSITION_Y + PROGRESS_BAR_PADDING_Y, 
            fill_width, PROGRESS_BAR_HEIGHT - 2 * PROGRESS_BAR_PADDING_Y, 
            PROGRESS_BAR_PLAYERCOLOR)
    end
    -- let case progress == START_PROGRESS be useless

    local fill_width = math.floor((START_PROGRESS - progress) / MAX_PROGRESS * PROGRESS_BAR_WIDTH)

        rect(PROGRESS_BAR_POSITION_X + half_width - fill_width, PROGRESS_BAR_POSITION_Y + PROGRESS_BAR_PADDING_Y, 
            fill_width, PROGRESS_BAR_HEIGHT - 2 * PROGRESS_BAR_PADDING_Y, 
            PROGRESS_BAR_PANDACOLOR)

end

function ClickerMinigame:update()
    if not is_game_over then

        -- сделаем проверку на нажатие буквы Х
        if btnp(BUTTON_X) then
            -- или добавим более сложную логику(не добавим, это никому не будет интересно)
            current_player_force = MAX_PLAYER_FORCE
        end

        -- Обновление прогресса - спасибо, я бы не понял сам
        progress = progress + (MAGIC_MULTIPLIER*current_player_force - current_panda_force) * Time.dt()

        -- Ограничение прогресса - прямо best practices массонов.
        if progress <= MIN_PROGRESS then
            progress = MIN_PROGRESS
            is_game_over = true
            is_player_win = false
        elseif progress >= MAX_PROGRESS then
            progress = MAX_PROGRESS
            is_game_over = true
            is_player_win = true
        end

        if animation_controller_player:animation_ended() then
            animation_controller_player:set_sprite(SPRITES.cutscene.run_player)
            trigger_stick = true
        end

        if animation_controller_panda:animation_ended() then
            animation_controller_panda:set_sprite(SPRITES.cutscene.run_panda)
            trigger_flip_panda = 0
        end

        animation_controller_player:next_frame()
        animation_controller_panda:next_frame()

        -- Сброс силы игрока написал, а return забыл.
        current_player_force = MIN_PLAYER_FORCE
        return
    end
    
    ClickerMinigame:gameover()
end

function ClickerMinigame:draw()

    -- Сдесь должа быть отрисовка игры
    -- Именно так сказал предыдущему разработчику миниигры chatgpt 4 mini.
    -- Эта небольшая деталь ещё много раз заставит меня переназывать переменные,
    -- переписывать комментарии, передумывать логику.
    -- Мне не нравится pascalCase, в котором пишут нейросети.
    -- Мы с ними разные
    -- Такова была моя цена этого легаси.
    -- Можно было бы беспрекословно согласиться с best практиками Кавай-грота.
    -- Но моё мнение такое:
    -- Стоит ли переписывать проект с нуля, используя модные в этом сезоне best practices?
    -- Clean code is important.
    -- Монолит очень моден. Но всё зависит от architecture, проще говоря: смотря какие details:
    -- dirty code, functional programming, OOP - могут требовать переработки,
    -- но это всё зависит on design of a project.
    -- Поэтому я бы не сказал, что всегда better to rewrite код с full confidence.
    --
    --
    -- 📨 Ответ от kawaii@sisyphus.jam (2025-02-19):
    --
    -- Да, вы правы, не стоит слепо следовать за тем, что в моде. Но несомненно
    -- есть, so to speak, некоторые преимущества этого rewrite. Legacy из прошлого
    -- проекта (codename BOOMERANG) никуда не годится, из-за присутсвия overengineering
    -- и также значительных performance issues, проще говоря, bottlenecks.
    --
    -- Кроме того, похдод монолит хорош своим simplicity. Быть может он и не выглядит
    -- как best practice, однако его преимущество в flexibility. Simple code можно
    -- легко конвертировать в любой другой стиль, будь на то requirements, чего нельзя
    -- сказать об обратном. Помимо того, такой код повышает developer productivity,
    -- ведь не нужно слишком париться об architecture и других details, присутствующих
    -- в других paradigms. А если requirements не будет, то такой код самый простой и
    -- самый performant, и таким образом позволяет значительно быстрее закончить
    -- игру, make the deadline.
    --
    -- А если сказать проще, best code = simple code.
    --
    -- Best wishes,
    -- код-каваи
    --


    --dayly routine
    game.draw_map()
    -- for _, dialog_window in ipairs(game.CRUTCH_dialog_window) do
    --         dialog_window:update()
    -- end
    -- for _, dialog_window in ipairs(game.CRUTCH_dialog_window) do
    --         dialog_window:draw()
    -- end

    -- self.tugologue = true
    -- да, если у dialogwindow не будет синглтоном или что-то будет происходить с triggerом,
    -- то возможно не unопределённое behaveдение
    -- self.trigger = trigger
    
    -- аварийная функция. Просьба не использовать
    -- DialogWindow:draw_tugologue()
    ClickerMinigame:draw_progress_bar()

    -- тут стоит подумать, может стоит символично оставить только одну панду
    
    -- game.player:draw()
    
    id_frame_player = animation_controller_player:current_frame()

    local x = 40
    local y = 96
    local stick_x = x + 10
    local stick_y = y + 6
    local panda_x = x + 22

    if id_frame_player == 484 then
        animation_controller_player:draw_at_screen_coordinates(x - 2, y)
        if trigger_stick then
            draw_stick(stick_x + 1, stick_y, 11, animation_controller_player)
        end
    elseif id_frame_player == 485 then
        animation_controller_player:draw_at_screen_coordinates(x - 4, y)
        if trigger_stick then
            draw_stick(stick_x, stick_y, 11, animation_controller_player)
        end
    elseif id_frame_player == 483 then
        animation_controller_player:draw_at_screen_coordinates(x + 2, y)
        if trigger_stick then
            draw_stick(stick_x + 3, stick_y, 11, animation_controller_player)
        end
    else
        animation_controller_player:draw_at_screen_coordinates(x, y)
        if trigger_stick then
            draw_stick(stick_x + 2, stick_y, 11, animation_controller_player)
        end
    end

    for _, panda in ipairs(game.current_level.pandas) do
        animation_controller_panda:draw_at_screen_coordinates(panda_x, y)
    end

    -- -- это вообще совсем мусор
    -- if is_game_over and not is_player_win then
    --     --game.player.is_dead = true
    -- end

    -- if is_game_over and is_player_win then
    --     -- Завершение(убрать весь визуал)
    -- end
end

-- Да, хардкод, но... Будет так! 
function draw_stick(x, y, color, animation_controller)
    current_scale = game.scale
    -- А вот это вообще ужас, с каких соображений x и y такие? Но разработчику, 
    -- который данный код писал в AnimationController, виднее...
    --x = x - (current_scale - 1) * 48
    --y = y + 24 * (current_scale - 1) - 8 * current_scale * (animation_controller:current_animation().height - 1)
    rect(x-current_scale, y,current_scale, current_scale, color)
    rect(x, y,current_scale, current_scale, color)
    for i = 0, 4 do
        rect(x+i*current_scale+current_scale, y+current_scale,current_scale, current_scale, color)    
    end
    for i = 1, 2 do
        rect(x+i*current_scale+5*current_scale, y+2*current_scale,current_scale, current_scale, color)
    end
end

function ClickerMinigame:reset_local_var()
    current_player_force = MIN_PLAYER_FORCE
    current_panda_force = CONSTANT_PANDA_FORCE
    progress = START_PROGRESS
    is_game_over = false
    is_player_win = false
end
