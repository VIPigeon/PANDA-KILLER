-- Make shure you read the disclaimer

--⚠⚠ NO SINGLE OOP WILL BE USED HERE ⚠⚠

-- not Кавай-мир победил or монолит оказался сильней.


-- Consider you read the disclaimer

-- User Manual:
-- 
-- У панды появляется поле kantugging_friend_panda - обозначает, важна ли для неё её палка настолько,
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

MINIGAME_SCALING_CONST = 5
INITIAL_SCALE = 1

MAX_PLAYER_FORCE = 8
MIN_PLAYER_FORCE = 0
MAGIC_MULTIPLIER = 16

CONSTANT_PANDA_FORCE = 4
MAX_PROGRESS = 100
MIN_PROGRESS = 0
START_PROGRESS = 50

current_player_force = MIN_PLAYER_FORCE
current_panda_force = CONSTANT_PANDA_FORCE
progress = START_PROGRESS
is_game_over = false
is_player_win = false
trigger_panda = nil

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

    ClickerMinigame:rescale_game(true)

    ClickerMinigame:reset_local_var()

end

function ClickerMinigame:rescale_game(upscale)
    local scale = MINIGAME_SCALING_CONST
    if not upscale then
        scale = INITIAL_SCALE
    end

    game.scale = scale

    game.camera.scale = scale
    game.camera:rescale(scale)
end

function ClickerMinigame:gameover()
    -- надо выйти в игру нормально и все следы миниигры уничтожить
    if is_player_win then
        trace('you win')
        trigger_panda:set_dieable_state()
        trigger_panda.kantugging_friend_panda = false
        -- trigger_panda:take_damage()

        -- viewership awkward or other gift for player
    else
        game.player:die()
    end
    
    -- may be some animations

    ClickerMinigame:rescale_game(false)

    game.state = GAME_STATE_GAMEPLAY
end

function ClickerMinigame:update_progress_for_visual()
    res = ''
    
    -- haha мне лень гуглить, как умножать строки или сделать проще
    for i = 0, progress / 10 do
        res = res..'A'
    end

    return res..'\n'
end

function ClickerMinigame:update()
    if not is_game_over then

        -- сделаем проверку на нажатие буквы Х
        if btnp(BUTTON_X) then
            -- или добавим более сложную логику(не добавим, это никому не будет интересно)
            trace('button pressed')
            current_player_force = MAX_PLAYER_FORCE
        end

        -- Обновление прогресса - спасибо, я бы не понял сам
        progress = progress + (MAGIC_MULTIPLIER*current_player_force - current_panda_force) * Time.dt()
        trace(progress)

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
    
    DialogWindow:draw_tugologue()

    -- тут стоит подумать, может стоит символично оставить только одну панду
    for _, panda in ipairs(game.current_level.pandas) do
        panda:draw()
    end
    game.player:draw()



    -- это вообще совсем мусор
    if is_game_over and not is_player_win then
        --game.player.is_dead = true
    end

    if is_game_over and is_player_win then
        -- Завершение(убрать весь визуал)
    end
end

function ClickerMinigame:reset_local_var()
    current_player_force = MIN_PLAYER_FORCE
    current_panda_force = CONSTANT_PANDA_FORCE
    progress = START_PROGRESS
    is_game_over = false
    is_player_win = false
end
