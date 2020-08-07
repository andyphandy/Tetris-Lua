Object = require "classic"
require "title"
require "blocks"
require "map"
require "sounds"
lume = require "lume"

--[[
  Main.lua controls the the game's load, update, and draw. It connects blocks.lua,
  map.lua, sounds.lua, and title.lua to each other.
]]--


WINDOW_WIDTH = 525
WINDOW_HEIGHT = 720

LENGTH = 25
DRAW_LENGTH = 23

MAP_WIDTH = 10
MAP_LENGTH = 26
MAP_PLAY_LENGTH = 20

NUM_BLOCKS = 7
NEXT_DISPLAY = 5
LVL_INTERVAL = 10
NUM_LEVELS = 25

BLOCK_FORMATIONS = {
  --SQUARE FORMATIONS
  {
    { {0, 0, 0},
      {0, 1, 1},
      {0, 1, 1},
    }
  },
  -- LINE FORMATIONS
  {
    { {0, 0, 0, 0},
      {2, 2, 2, 2}
    },
    { {0, 0, 2},
      {0, 0, 2},
      {0, 0, 2},
      {0, 0, 2}
    },
    { {0, 0, 0, 0},
      {0, 0, 0, 0},
      {2, 2, 2, 2}
    },
    { {0, 2},
      {0, 2},
      {0, 2},
      {0, 2}
    }
  },
  -- L FORMATIONS
  {
    { {0, 0, 0},
      {3, 0, 0},
      {3, 3, 3},
    },
    { {0, 0, 0},
      {0, 3, 3},
      {0, 3, 0},
      {0, 3, 0}
    },
    { {0, 0, 0},
      {0, 0, 0},
      {3, 3, 3},
      {0, 0, 3}
    },
    { {0, 0},
      {0, 3},
      {0, 3},
      {3, 3}
    }
  },
  -- BACKWARDS L FORMATIONS
  {
    { {0, 0, 0},
      {0, 0, 4},
      {4, 4, 4}
    },
    { {0, 0, 0},
      {0, 4, 0},
      {0, 4, 0},
      {0, 4, 4}
    },
    { {0, 0, 0},
      {0, 0, 0},
      {4, 4, 4},
      {4, 0, 0}
    },
    { {0, 0},
      {4, 4},
      {0, 4},
      {0, 4}
    }
  },
  -- S FORMATIONS
  {
    { {0, 0, 0},
      {0, 5, 5},
      {5, 5, 0}
    },
    { {0, 0, 0},
      {0, 5, 0},
      {0, 5, 5},
      {0, 0, 5}
    },
    { {0, 0, 0},
      {0, 0, 0},
      {0, 5, 5},
      {5, 5, 0}
    },
    { {0, 0, 0},
      {5, 0, 0},
      {5, 5, 0},
      {0, 5, 0}
    }
  },
  -- BACKWARDS S FORMATIONS
  {
    { {0, 0, 0},
      {6, 6, 0},
      {0, 6, 6},
    },
    { {0, 0, 0},
      {0, 0, 6},
      {0, 6, 6},
      {0, 6, 0}
    },
    { {0, 0, 0},
      {0, 0, 0},
      {6, 6, 0},
      {0, 6, 6}
    },
    { {0, 0, 0},
      {0, 6, 0},
      {6, 6, 0},
      {6, 0, 0}
    }
  },
  -- T FORMATIONS
  {
    { 
      {0, 0, 0},
      {0, 7, 0},
      {7, 7, 7},
    },
    { {0, 0, 0},
      {0, 7, 0},
      {0, 7, 7},
      {0, 7, 0}
    },
    { {0, 0, 0},
      {0, 0, 0},
      {7, 7, 7},
      {0, 7, 0}
    },
    { {0, 0},
      {0, 7},
      {7, 7},
      {0, 7}
    }
  }
}

COLORS = {
  {1, 1, 0},
  {0, 1, 1},
  {0, 102/255, 204/255},
  {1, 128/255, 0}, 
  {0, 1, 0}, 
  {1, 0, 0},
  {1, 0, 1}
}

LVL_SPEED = {
  {1.04, 1.028, 5.12}, -- Block place delay base
  {0, .3, .5} -- Max block place delay
}

function love.load()
  -- Fonts
  love.graphics.setDefaultFilter("nearest", "nearest")
  smallFont = love.graphics.newFont("assets/font.ttf", 8)
  mediumFont = love.graphics.newFont("assets/font.ttf", 14)
  largeFont = love.graphics.newFont("assets/font.ttf", 16)
  clearFont = love.graphics.newFont("assets/font.ttf", 24)
  
  -- Window
  love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
      vsync = true,
      fullscreen = false,
      resizable = false
    })
  
  -- Save controls
  if love.filesystem.getInfo("savedata.txt") then
    file = love.filesystem.read("savedata.txt")
    data = lume.deserialize(file)
    left = data.left
    right = data.right
    hard = data.hard 
    soft = data.soft 
    clockwise = data.clockwise
    counterClock = data.counterClock
    hold = data.hold
    sounds.musicSelected = data.musicSelected
  else
    left = "a"
    right = "d"
    hard = "w"
    soft = "s"
    clockwise = "p"
    counterClock = "l"
    hold = "space"
  end
  
  gameState = "title"
  title = Title()
  sounds = sounds()
  map = map()
  level = 1
  setLevel = 1
  nextLevel = LVL_INTERVAL
  canHold = true
  heldBlock = nil
  
  next = Queue.new()
  addToNext()
  numPlaced = 0
  numCleared = 0
  isPerfect = false
  
  block = blocks(Queue.remove(next))
  
  minutes = 0
  seconds = 0
  secondTimer = 0
end

function love.update(dt)
  if gameState == "title" then
    title:update(dt)
  elseif gameState == "play" then
    secondTimer = secondTimer + dt
    if secondTimer >= 1 then
      secondTimer = 0
      seconds = seconds + 1
    end
    if seconds == 60 then
      minutes = minutes + 1
      seconds = 0
    end
    block.update(block, dt)
    if block.placed then
      map.place(map, block)
      canHold = true
      block = blocks(Queue.remove(next))
      checkGameOver()
      if Queue.size(next) <= NEXT_DISPLAY then
        addToNext()
      end
    end
    if level < NUM_LEVELS and numCleared >= nextLevel then
      level = level + 1
      nextLevel = nextLevel + LVL_INTERVAL
      map:levelUp()
    end
  end
end

function love.keypressed(key)
  if gameState == "title" then
    title:select(key)
  elseif gameState == "play" then
    if key == hold and canHold then
      holdBlock()
    else
      block:keypressed(key, map)
    end
    if key == "escape" then
      gameState = "paused"
    end
  elseif gameState == "lose" then
    if key == "r" then
      map:restart()
      level = setLevel
      canHold = true
      heldBlock = nil
      sounds.musicTable[sounds.musicSelected]:play()
  
      next = Queue.new()
      addToNext()
      numPlaced = 0
      numCleared = 0
      minutes = 0
      seconds = 0
      
      gameState = "play"
      block = blocks(Queue.remove(next))
    end
  elseif gameState == "paused" then
    if key == "escape" then
      gameState = "play"
    end
  end
end

function holdBlock()
  sounds.hold:play()
  canHold = false
  if heldBlock == nil then
      heldBlock = block.formation
      block = blocks(Queue.remove(next))
  else
    replacement = heldBlock
    heldBlock = block.formation
    block = blocks(replacement)
  end
end

function love.draw()
  if gameState == "title" then
    title:draw()
  elseif gameState == "play" or gameState == "lose" then
    map:draw()
    block:draw()
    drawHold()
    drawNext()
    drawInfo()
  elseif gameState == "paused" then
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(clearFont)
    love.graphics.printf("PAUSED. PRESS ESC TO CONTINUE", 0, WINDOW_HEIGHT / 2 - 20, WINDOW_WIDTH, "center")
  end
end

function drawHold()
  love.graphics.setFont(mediumFont)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", LENGTH, LENGTH * 7, LENGTH * 3, LENGTH * 3)
  love.graphics.printf("Hold", LENGTH, LENGTH * 7 + 5, LENGTH * 3, "center")
  if heldBlock ~= nil then
    local drawHold = BLOCK_FORMATIONS[heldBlock]
    if canHold then
      love.graphics.setColor(COLORS[heldBlock])
    else
      love.graphics.setColor(192/255, 192/255, 192/255)
    end
    for y, row in ipairs(drawHold[1]) do
      for x, col in ipairs(drawHold[1][y]) do
        if drawHold[1][y][x] > 2 then 
          love.graphics.rectangle("fill", (1.2 + x) * LENGTH / 1.5, (4.5 + y + 6) * LENGTH / 1.5, DRAW_LENGTH / 1.5, DRAW_LENGTH / 1.5)
        elseif drawHold[1][y][x] == 1 then
          love.graphics.rectangle("fill", (.7 + x) * LENGTH / 1.5, (4.5 + y + 6) * LENGTH / 1.5, DRAW_LENGTH / 1.5, DRAW_LENGTH / 1.5)
        elseif drawHold[1][y][x] == 2 then
          love.graphics.rectangle("fill", (.7 + x) * LENGTH / 1.5, (5 + y + 6) * LENGTH / 1.5, DRAW_LENGTH / 1.5, DRAW_LENGTH / 1.5)
        end
      end
    end
  end
end

function drawNext()
  love.graphics.setFont(mediumFont)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", LENGTH * 16, LENGTH * 7, LENGTH * 3, LENGTH * 14)
  love.graphics.printf("Next", LENGTH * 16, LENGTH * 7 + 5, LENGTH * 3, "center")
  
  for n=1, NEXT_DISPLAY do
    local nextBlock = BLOCK_FORMATIONS[Queue.peek(next, n)]
    love.graphics.setColor(COLORS[Queue.peek(next, n)])
    for y, row in ipairs(nextBlock[1]) do
      for x, col in ipairs(nextBlock[1][y]) do
        if nextBlock[1][y][x] > 2 then 
          love.graphics.rectangle("fill", (1.2 + x + 22.5) * LENGTH / 1.5, (4.5 + y + 2 + (4 * n)) * LENGTH / 1.5, DRAW_LENGTH / 1.5, DRAW_LENGTH / 1.5)
        elseif nextBlock[1][y][x] == 1 then
          love.graphics.rectangle("fill", (.7 + x + 22.5) * LENGTH / 1.5, (4.5 + y + 2 + (4 * n)) * LENGTH / 1.5, DRAW_LENGTH / 1.5, DRAW_LENGTH / 1.5)
        elseif nextBlock[1][y][x] == 2 then
          love.graphics.rectangle("fill", (.7 + x + 22.5) * LENGTH / 1.5, (5 + y + 2 + (4 * n)) * LENGTH / 1.5, DRAW_LENGTH / 1.5, DRAW_LENGTH / 1.5)
        end
      end
    end
  end
end

function drawInfo()
  love.graphics.setFont(mediumFont)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", LENGTH, LENGTH * 11, LENGTH * 3, LENGTH * 2)
  love.graphics.printf("LEVEL", LENGTH, LENGTH * 11 + 5, LENGTH * 3, "center")
  love.graphics.setFont(largeFont)
  love.graphics.printf(level .. "/" .. NUM_LEVELS, LENGTH, LENGTH * 12, LENGTH * 3, "center")
  
  love.graphics.setFont(mediumFont)
  love.graphics.rectangle("line", LENGTH, LENGTH * 14, LENGTH * 3, LENGTH * 2.5)
  love.graphics.printf("LINES CLEARED", LENGTH, LENGTH * 14 + 5, LENGTH * 3, "center")
  love.graphics.setFont(largeFont)
  love.graphics.printf(numCleared, LENGTH, LENGTH * 15 + 10, LENGTH * 3, "center")
  
  love.graphics.setFont(mediumFont)
  love.graphics.rectangle("line", LENGTH, LENGTH * 17, LENGTH * 3, LENGTH * 2.5)
  love.graphics.printf("BLOCKS PLACED", LENGTH, LENGTH * 17 + 5, LENGTH * 3, "center")
  love.graphics.setFont(largeFont)
  love.graphics.printf(numPlaced, LENGTH, LENGTH * 18 + 10, LENGTH * 3, "center")
  
  love.graphics.setFont(mediumFont)
  love.graphics.rectangle("line", LENGTH, LENGTH * 20, LENGTH * 3, LENGTH * 2)
  love.graphics.printf("TIME", LENGTH, LENGTH * 20 + 5, LENGTH * 3, "center")
  love.graphics.setFont(largeFont)
  love.graphics.printf(minutes .. ":" .. string.format("%02d", seconds), LENGTH, LENGTH * 21, LENGTH * 3, "center")
end

function checkGameOver()
  if block:collision(map) then
    gameState = "lose"
    love.audio.stop()
    sounds.gameOver:play()
    case = "GAME OVER. PRESS R TO REPLAY"
  end
end

function addToNext()
  local list = {}
  local i = 1
  while #list ~= NUM_BLOCKS do
    local randomNum = love.math.random(NUM_BLOCKS)
    if not table.contains(list, randomNum) then
      list[i] = randomNum
      Queue.add(next, randomNum)
      i = i + 1
    end
  end
end

function table.contains(table, element)
  for i, v in ipairs(table) do
    if table[i] == element then
      return true
    end
  end
  return false
end

Queue = {}
function Queue.new()
  return {first = 1, last = 0}
end
function Queue.add(list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
end
function Queue.remove(list)
  local first = list.first
  local value = list[first]
  list[first] = nil
  list.first = first + 1
  return value
end
function Queue.peek(list, index)
  return list[list.first + index - 1]
end
function Queue.size(list)
  return math.abs(list.first - list.last)
end

function saveControls()
  data = {}
  data.left = left
  data.right = right
  data.hard = hard
  data.soft = soft
  data.clockwise = clockwise
  data.counterClock = counterClock
  data.hold = hold
  data.musicSelected = sounds.musicSelected
  serialized = lume.serialize(data)
   love.filesystem.write("savedata.txt", serialized)
end