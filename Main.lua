-- Когда добавляете новый файл, сортируйте по алфавиту, пожалуйста 😇
require 'Base/Animation'
require 'Base/AnimationController'
require 'Base/Basic'
require 'Base/Body'
require 'Base/ChildBody'
require 'Base/Controls'
require 'Base/Hitbox'
require 'Base/Localization'
require 'Base/Math'
require 'Base/Physics'
require 'Base/Queue'
require 'Base/Rect'
require 'Base/Shape'
require 'Base/Sprite'
require 'Base/Table'
require 'Base/TheTrigger'
require 'Base/Time'
require 'Base/Palette'

require 'Game/Bike'
require 'Game/Blood'
require 'Game/Leaves'
require 'Game/Camera'
require 'Game/ClickerMinigame'
-- перфекционизм разрушает gjrjq
require 'Game/Data'
require 'Game/Debug'
require 'Game/DialogWindow'
require 'Game/Effects'
require 'Game/Game'
require 'Game/Hat'
require 'Game/House'
require 'Game/LanguageSelection'
require 'Game/Menu'
require 'Game/Panda'
require 'Game/ParallaxScrolling'
require 'Game/Player'

require 'Game/Cutscenario'  -- почему не в алфавитном порядке? 😠

require 'Libraries/pslib'

game.init()

-- TIC-80 🤖 обязывает нас объявлять функцию TIC, которую он будет
-- вызывать каждый кадр.
function TIC()
    game.update()
end
