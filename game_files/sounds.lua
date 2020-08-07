sounds = Object.extend(Object)

function sounds:new()
  self.musicSelected = 2
  self.music = love.audio.newSource("assets/sounds/tetris.mp3", "stream")
  self.music2 = love.audio.newSource("assets/sounds/gameTheme1.mp3", "stream")
  self.music3 = love.audio.newSource("assets/sounds/gameTheme2.mp3", "stream")
  self.music4 = love.audio.newSource("assets/sounds/gameTheme3.mp3", "stream")
  self.musicTable = {self.music, self.music2, self.music3, self.music4}
  for i, song in ipairs(self.musicTable) do
    self.musicTable[i]:setLooping(true)
  end
  
  self.explosion = love.audio.newSource("assets/sounds/explosion.mp3", "static")
  self.move = love.audio.newSource("assets/sounds/sfx_menu_move1.wav", "static")
  self.select = love.audio.newSource("assets/sounds/sfx_menu_select1.wav", "static")
  
  self.softDrop = love.audio.newSource("assets/sounds/softdrop.wav", "static")
  self.hardDrop = love.audio.newSource("assets/sounds/harddrop.wav", "static")
  self.move = love.audio.newSource("assets/sounds/move.wav", "static")
  self.rotate = love.audio.newSource("assets/sounds/rotate.wav", "static")
  self.hold = love.audio.newSource("assets/sounds/hold.wav", "static")
  
  self.tetris = love.audio.newSource("assets/sounds/clear4.wav", "static")
  self.triple = love.audio.newSource("assets/sounds/clear3.wav", "static")
  self.double = love.audio.newSource("assets/sounds/clear2.wav", "static")
  self.single = love.audio.newSource("assets/sounds/clear1.wav", "static")
  self.perfect = love.audio.newSource("assets/sounds/perfect.wav", "static")
  self.tSpin = love.audio.newSource("assets/sounds/tSpin.wav", "static")
  
  self.lvl = love.audio.newSource("assets/sounds/lvl.wav", "static")
  self.gameOver = love.audio.newSource("assets/sounds/gameOver.wav", "static")
end