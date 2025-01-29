require 'Base/Animation'
require 'Base/Hitbox'
require 'Base/Localization'
require 'Base/Math'
require 'Base/Physics'
require 'Base/Rect'
require 'Base/Shape'
require 'Base/Sprite'
require 'Base/Table'
require 'Base/Time'

require 'Libraries/pslib'

require 'Blood'
require 'Body'
require 'Camera'
require 'ChildBody'
require 'Data'
require 'DialogWindow'
require 'Effects'
require 'Game'
require 'LanguageSelection'
require 'Panda'
require 'Player'

game.init()

function TIC()
    game.update()
end
