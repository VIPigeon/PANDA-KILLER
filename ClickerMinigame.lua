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

MAX_PLAYER_FORCE = 2
MIN_PLAYER_FORCE = 0

CONSTANT_PANDA_FORCE = 1
MAX_PROGRESS = 100
MIN_PROGRESS = 0
START_PROGRESS = 50

current_player_force = MIN_PLAYER_FORCE
current_panda_force = CONSTANT_PANDA_FORCE
progress = START_PROGRESS
is_game_over = false
is_player_win = false

function ClickerMinigame:init(panda)
    -- наверное придётся поменять у панды её выражение лица, жесты, позу, самочувствие.
    -- TODO so

    game.status = false
    -- я сделаю обёртку триггером, чтобы работало медленнее. Не люблю, когда больше 60 fps.
    trigger = {panda= panda, text_progress= ClickerMinigame:update_progress_for_visual()}
    trace(trigger)
    DialogWindow:draw_tugologue(trigger)

    ClickerMinigame:reset_local_var()

end

function ClickerMinigame:gameover()
    -- надо выйти в игру нормально и все следы миниигры уничтожить
    --game.status = true
end

function ClickerMinigame:update_progress_for_visual()
    res = ''
    
    -- haha мне лень гуглить, как умножать строки или сделать проще
    for i = 1, progress / 10 do
        res = res..'A'
    end

    return res
end

function ClickerMinigame:update()
    if not is_game_over then

        -- сделаем проверку на нажатие буквы Х
        if BUTTON_X then
            -- или добавим более сложную логику(не добавим, это никому не будет интересно)
            current_player_force = MAX_PLAYER_FORCE
        end

        -- Обновление прогресса - спасибо, я бы не понял сам
        progress = progress + (current_player_force - current_panda_force) * Time.dt()
        trace(progress)
        trace(current_player_force)
        trace(current_panda_force)

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

    -- тут стоит подумать, может стоит символично оставить только одну панду
    Pandas.draw()
    player:draw()



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