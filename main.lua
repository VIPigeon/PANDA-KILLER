
require 'Localization'
require 'DialogWindow'
require 'Game'
-- require 'Body'

require 'Table'
require 'Math'
Time = require 'Time'

require 'Constants'

require 'Sprite'
require 'AnimeParticlesBackup'
require 'Blood'
require 'Hitbox'
require 'Body'

require 'Data'

require 'ThePanda'
require 'Entities'

game.player = require 'Player'
game.pandas = {Panda:new(20,20), Panda:new(10,10), Panda:new(20,10)}

--и моё барахлишко тут тоже полежит



function TIC()
    game.update()
end
