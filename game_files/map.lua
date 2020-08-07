map = Object.extend(Object)

function map:new()
  self.tileMap = {}
  for y=1, MAP_LENGTH do
    self.tileMap[y] = {}
    for x=1, MAP_WIDTH do
      self.tileMap[y][x] = 0
    end
  end
  case = ""
end

function map:draw()
    for y=#self.tileMap, #self.tileMap - MAP_PLAY_LENGTH + 1, -1 do
      for x, column in ipairs(self.tileMap[y]) do
        love.graphics.setColor(1, 1, 1, 50/255)
        love.graphics.rectangle("line", (x + 4) * LENGTH, y * LENGTH, LENGTH, LENGTH)
        if self.tileMap[y][x] == 0 then
          love.graphics.setColor(0, 0, 0)
        else
          love.graphics.setColor(COLORS[self.tileMap[y][x]])
        end
      love.graphics.rectangle("fill", (x + 4) * LENGTH, y * LENGTH, DRAW_LENGTH, DRAW_LENGTH)
        
      end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", LENGTH * 5, LENGTH * (MAP_LENGTH - MAP_PLAY_LENGTH + 1), LENGTH * MAP_WIDTH, LENGTH * MAP_PLAY_LENGTH)
  love.graphics.rectangle("line", LENGTH, LENGTH, LENGTH * 18, LENGTH * 3)
  if case == "LEVEL UP!" then
    love.graphics.setColor(1, 1, 0)
  else
    love.graphics.setColor(1, 1, 1)
  end
  
  love.graphics.setFont(clearFont)
  love.graphics.printf(case, LENGTH, LENGTH * 2, LENGTH * 18, "center")
end


function map:place(block)
  numPlaced = numPlaced + 1
  for y, row in ipairs(block.arrangements[block.rotation]) do
    for x, column in ipairs(block.arrangements[block.rotation][y]) do
      formation = block.arrangements[block.rotation][y][x]
      dy = block.y + y
      dx = block.x + x
      if formation ~= 0 and self.tileMap[dy][dx] == 0 then
        self.tileMap[dy][dx] = formation
      end
    end
  end
  map:checkClear(block)
end

function map:checkClear(block)
  local isPerfect = true
  local currCleared = 0
  for y=1, #self.tileMap do
    clear = true
    for x=1, #self.tileMap[y] do
      if self.tileMap[y][x] == 0 then
        clear = false
      else
        isPerfect = false
      end
    end
    if clear then
      currCleared = currCleared + 1
      local newLine = {}
      for i=1, MAP_WIDTH do
        newLine[i] = 0
      end
      table.remove(self.tileMap, y)
      table.insert(self.tileMap, 1, newLine)
    end
  end
  if isPerfect then
    sounds.perfect:play()
  end
  numCleared = numCleared + currCleared
  if currCleared == 4 then 
    case = "TETRIS!!!"
    sounds.tetris:play()
  elseif currCleared == 1 then
    case = "SINGLE"
    sounds.single:play()
  elseif currCleared == 3 then
    case = "TRIPLE"
    sounds.triple:play()
  elseif currCleared == 2 then
    case = "DOUBLE"
    sounds.double:play()
  end
end

function map:levelUp()
  case = "LEVEL UP!"
  sounds.lvl:play()
end

function map:restart()
  self.tileMap = {}
  for y=1, MAP_LENGTH do
    self.tileMap[y] = {}
    for x=1, MAP_WIDTH do
      self.tileMap[y][x] = 0
    end
  end
  case = ""
end