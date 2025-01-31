-- Когда добавляете новый файл, сортируйте по алфавиту, пожалуйста 😇
require 'Base/Animation'
require 'Base/Basic'
require 'Base/Body'
require 'Base/ChildBody'
require 'Base/Hitbox'
require 'Base/Localization'
require 'Base/Math'
require 'Base/Physics'
require 'Base/Rect'
require 'Base/Shape'
require 'Base/Sprite'
require 'Base/Table'
require 'Base/Time'

require 'Game/Blood'
require 'Game/Camera'
require 'Game/Data'
require 'Game/Debug'
require 'Game/DialogWindow'
require 'Game/Effects'
require 'Game/Game'
require 'Game/LanguageSelection'
require 'Game/Panda'
require 'Game/Player'

require 'Libraries/pslib'

game.init()

-- TIC-80 🤖 обязывает нас объявлять функцию TIC, которую он будет
-- вызывать каждый кадр.
function TIC()
    game.update()
end
