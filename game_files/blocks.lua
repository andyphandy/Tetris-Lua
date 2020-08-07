blocks = Object.extend(Object)

function blocks:new(formation)
  self.arrangements = BLOCK_FORMATIONS[formation]
  self.formation = formation
  self.x = MAP_WIDTH / 2 - 2
  self.y = MAP_LENGTH - MAP_PLAY_LENGTH - 3
  self.placed = false
  self.rotation = 1
  self.ghost = BLOCK_FORMATIONS[formation]
  self.ghostX = self.x
  self.ghostY = self.y
  
  self.moveTimer = 0
  self.moveTimer2 = 0
  self.moveDelay = .17
  self.moveAfterInterval = .05
  
  self.timer = 0
  self.interval = LVL_SPEED[1][1]
  
  self.placeTimer = 0
  self.placeTimer2 = 0
  self.placeDelay = LVL_SPEED[1][2]
  self.placeMax = LVL_SPEED[1][3]
end

function blocks:update(dt)
  blocks.updateGhost(self)
  
  if level < NUM_LEVELS then
    self.interval = LVL_SPEED[1][1] - .09 * level
    self.placeDelay = LVL_SPEED[1][2] - .028 * level
    self.placeMax = LVL_SPEED[1][3] - .15 * level
  else
    self.interval = LVL_SPEED[2][1]
    self.placeDelay = LVL_SPEED[2][2]
    self.placeMax = LVL_SPEED[2][3]
  end
  
  self.timer = self.timer + dt
  self.placeTimer = self.placeTimer + dt
  if self.timer >= self.interval then
    blocks.translate(self, 0, -1)
    if blocks.collision(self, map) then
      blocks.translate(self, 0, 1)
      if self.placeTimer >= self.placeDelay or self.placeTimer2 >= self.placeMax then
        self.placed = true
        sounds.softDrop:play()
      end
    else
      self.timer = 0
    end
  end
  
  blocks.translate(self, 0, -1)
  if blocks.collision(self, map) then
    self.placeTimer2 = self.placeTimer2 + dt
  end
  blocks.translate(self, 0, 1)
  
  self.moveTimer = self.moveTimer + dt
  self.moveTimer2 = self.moveTimer2 + dt
  if self.moveTimer >= self.moveDelay then
    if self.moveTimer2 >= self.moveAfterInterval then
      if love.keyboard.isDown(left) then
        sounds.move:play()
        blocks.translate(self, -1, 0)
        if blocks.collision(self, map) then blocks.translate(self, 1, 0) end
        self.placeTimer = 0
        self.moveTimer2 = 0
      elseif love.keyboard.isDown(right) then
        sounds.move:play()
        blocks.translate(self, 1, 0)
        if blocks.collision(self, map) then blocks.translate(self, -1, 0) end
        self.placeTimer = 0
        self.moveTimer2 = 0
      elseif love.keyboard.isDown(soft) then
        sounds.move:play()
        blocks.translate(self, 0, -1)
        if blocks.collision(self, map) then blocks.translate(self, 0, 1) end
        self.moveTimer2 = 0
      end
    end
  end
end

function blocks:updateGhost()
  self.ghostX = self.x
  while not blocks.collisionGhost(self, map) do
    self.ghostY = self.ghostY + 1
  end
  self.ghostY = self.ghostY - 1
end

function blocks:draw()
  love.graphics.setColor(COLORS[self.formation])
  for y, row in ipairs(self.arrangements[self.rotation]) do
    for x, column in ipairs(self.arrangements[self.rotation][y]) do
      if self.arrangements[self.rotation][y][x] ~= 0 then
        love.graphics.rectangle("fill", (self.x + x + 4) * LENGTH, (self.y + y) * LENGTH, DRAW_LENGTH, DRAW_LENGTH)
      end
    end
  end
  
  if not self.placed then
    for y, row in ipairs(self.ghost[self.rotation]) do
      for x, column in ipairs(self.ghost[self.rotation][y]) do
        if self.ghost[self.rotation][y][x] ~= 0 then
          love.graphics.rectangle("line", (self.ghostX + x + 4) * LENGTH, (self.ghostY + y) * LENGTH, DRAW_LENGTH, DRAW_LENGTH)
        end
      end
    end
  end
end

function blocks:keypressed(key, map)
  --LEFT
  if key == left then
    sounds.move:play()
    self.moveTimer = 0
    blocks.translate(self, -1, 0)
    if blocks.collision(self, map) then 
      blocks.translate(self, 1, 0) 
    else
      self.placeTimer = 0
    end
    
  --RIGHT
  elseif key == right then
    sounds.move:play()
    self.placeTimer = 0
    self.moveTimer = 0
    blocks.translate(self, 1, 0)
    if blocks.collision(self, map) then
      blocks.translate(self, -1, 0)
    else
      self.placeTimer = 0
    end
    
  -- HARD
  elseif key == hard then
    sounds.hardDrop:play()
    self.placed = true
    while not blocks.collision(self, map) do
      blocks.translate(self, 0, -1)
    end
    blocks.translate(self, 0, 1)
  
  -- SOFT
  elseif key == soft then
    sounds.move:play()
    self.moveTimer = 0
    blocks.translate(self, 0, -1)
    if blocks.collision(self, map) then
      blocks.translate(self, 0, 1)
    else
      self.placeTimer = 0
    end
    self.timer = 0
    
  -- CLOCKWISE
  elseif key == counterClock then
    local currentRotation = self.rotation
    sounds.rotate:play()
    self.placeTimer = 0
    if self.rotation == 1 then
      self.rotation = #self.arrangements
    else
      self.rotation = self.rotation - 1
    end 
    if not blocks.rotateTests(self, "left") then
      self.rotation = currentRotation
    end
    
  -- COUNTER CLOCKWISE
  elseif key == clockwise then
    local currentRotation = self.rotation
    sounds.rotate:play()
    self.placeTimer = 0
    if self.rotation == #self.arrangements then
      self.rotation = 1
    else
      self.rotation = self.rotation + 1
    end
    if not blocks.rotateTests(self, "right") then
      self.rotation = currentRotation
    end
  end
end

function blocks:rotateTests(direction)
  if blocks.collision(self, map) then -- (0, 0)
        -- NON-LINE BLOCKS
        if self.formation ~= 2 then
          if self.rotation == 2 then
            blocks.translate(self, -1, 0)
            if blocks.collision(self, map) then -- (-1, 0)
              blocks.translate(self, 0, 1)
              if blocks.collision(self, map) then -- (-1, 1)
                blocks.translate(self, 1, -3)
                if blocks.collision(self, map) then -- (0, -2)
                  blocks.translate(self, -1, 0)
                  if blocks.collision(self, map) then -- (-1, -2)
                    blocks.translate(self, 1, 2)
                    return false
                  end
                end
              end
            end
          elseif (self.rotation == 1 and direction == "left") or (self.rotation == 3 and direction == "right") then
            blocks.translate(self, 1, 0)
            if blocks.collision(self, map) then -- (1, 0)
              blocks.translate(self, 0, -1)
              if blocks.collision(self, map) then -- (1, -1)
                blocks.translate(self, -1, 3)
                if blocks.collision(self, map) then -- (0, 2)
                  blocks.translate(self, 1, 0)
                  if blocks.collision(self, map) then -- (1, 2)
                    blocks.translate(self, -1, -2)
                    return false
                  end
                end
              end
            end
          elseif (self.rotation == 3 and direction == "left") or (self.rotation == 1 and direction == "right") then
            blocks.translate(self, -1, 0)
            if blocks.collision(self, map) then -- (-1, 0)
              blocks.translate(self, 0, -1)
              if blocks.collision(self, map) then -- (-1, -1)
                blocks.translate(self, 1, 3)
                if blocks.collision(self, map) then -- (0, 2)
                  blocks.translate(self, -1, 0)
                  if blocks.collision(self, map) then -- (-1, 2)
                    blocks.translate(self, 1, -2)
                    return false
                  end
                end
              end
            end
          elseif self.rotation == 4 then 
            blocks.translate(self, 1, 0)
            if blocks.collision(self, map) then -- (1, 0)
              blocks.translate(self, 0, 1)
              if blocks.collision(self, map) then -- (1, 1)
                blocks.translate(self, -1, -3)
                if blocks.collision(self, map) then -- (0, -2)
                  blocks.translate(self, 1, 0)
                  if blocks.collision(self, map) then -- (1, -2)
                    blocks.translate(self, -1, 2)
                    return false
                  end
                end
              end
            end
          end
        -- LINE BLOCK
        else 
          if (self.rotation == 2 and direction == "right") or (self.rotation == 3 and direction == "left") then
            blocks.translate(self, -2, 0)
            if blocks.collision(self, map) then -- (-2, 0)
              blocks.translate(self, 3, 0)
              if blocks.collision(self, map) then -- (1, 0)
                blocks.translate(self, -3, -1)
                if blocks.collision(self, map) then -- (-2, -1)
                  blocks.translate(self, 3, 3)
                  if blocks.collision(self, map) then -- (1, 2)
                    blocks.translate(self, -1, -2)
                    return false
                  end
                end
              end
            end
           elseif (self.rotation == 4 and direction == "right") or (self.rotation == 1 and direction == "left") then
            blocks.translate(self, 2, 0)
            if blocks.collision(self, map) then -- (2, 0)
              blocks.translate(self, -3, 0)
              if blocks.collision(self, map) then -- (-1, 0)
                blocks.translate(self, 3, 1)
                if blocks.collision(self, map) then -- (2, 1)
                  blocks.translate(self, -3, -3)
                  if blocks.collision(self, map) then -- (-1, -2)
                    blocks.translate(self, 1, 2)
                    return false
                  end
                end
              end
            end
          elseif (self.rotation == 3 and direction == "right") or (self.rotation == 4 and direction == "left") then
            blocks.translate(self, -1, 0)
            if blocks.collision(self, map) then -- (-1, 0)
              blocks.translate(self, 3, 0)
              if blocks.collision(self, map) then -- (2, 0)
                blocks.translate(self, -3, 2)
                if blocks.collision(self, map) then -- (-1, 2)
                  blocks.translate(self, 3, -3)
                  if blocks.collision(self, map) then -- (2, -1)
                    blocks.translate(self, -2, 1)
                    return false
                  end
                end
              end
            end
          elseif (self.rotation == 1 and direction == "right") or (self.rotation == 2 and direction == "left") then
            blocks.translate(self, 1, 0)
            if blocks.collision(self, map) then -- (1, 0)
              blocks.translate(self, -3, 0)
              if blocks.collision(self, map) then -- (-2, 0)
                blocks.translate(self, 3, -2)
                if blocks.collision(self, map) then -- (1, -2)
                  blocks.translate(self, -3, 3)
                  if blocks.collision(self, map) then -- (-2, 1)
                    blocks.translate(self, 2, -1)
                    return false
                  end
                end
              end
            end
          end
        end
  end
  return true
end

function blocks:translate(x, y)
  self.x = self.x + x
  self.y = self.y - y
end

function blocks:highestY()
  for y=#self.arrangements[self.rotation], 1, -1 do
    for x, column in ipairs(self.arrangements[self.rotation][y]) do
        if self.arrangements[self.rotation][y][x] ~= 0 then
          return self.y + y
        end
    end
  end
end

function blocks:lowestX()
  for y, row in ipairs(self.arrangements[self.rotation]) do
    for x, column in ipairs(self.arrangements[self.rotation][y]) do
        if self.arrangements[self.rotation][y][x] ~= 0 then
          return self.x + x
        end
    end
  end
end

function blocks:highestX()
  for x=#self.arrangements[self.rotation][1], 1, -1 do
    for y, row in ipairs(self.arrangements[self.rotation]) do
      if self.arrangements[self.rotation][y][x] ~= 0 then
        return self.x + x
      end
    end
  end
end

function blocks:collision(map)
  for y, row in ipairs(self.arrangements[self.rotation]) do
    for x, column in ipairs(self.arrangements[self.rotation][y]) do
      if blocks.lowestX(self) < 1 or blocks.highestX(self) > MAP_WIDTH then
        return true
      end
      if blocks.highestY(self) < MAP_LENGTH + 1 then
        if self.arrangements[self.rotation][y][x] == self.formation and map.tileMap[self.y + y][self.x + x] ~= 0 then
          return true
        end
      else
        return true
      end
    end
  end
  return false
end

function blocks:highestGhostY()
  for y=#self.ghost[self.rotation], 1, -1 do
    for x, column in ipairs(self.ghost[self.rotation][y]) do
        if self.ghost[self.rotation][y][x] ~= 0 then
          return self.ghostY + y
        end
    end
  end
end

function blocks:collisionGhost(map)
  for y, row in ipairs(self.ghost[self.rotation]) do
    for x, column in ipairs(self.ghost[self.rotation][y]) do
      if blocks.highestGhostY(self) < MAP_LENGTH + 1 then
        if self.ghost[self.rotation][y][x] == self.formation and map.tileMap[self.ghostY + y][self.ghostX + x] ~= 0 then
          return true
        end
      else
        return true
      end
    end
  end
  return false
end