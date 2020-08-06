Title = Object.extend(Object)

function Title:new()
  self.timer = 0
  
  -- FONT
  self.descFont = love.graphics.newFont("font.ttf", 12)
  self.optionsFont = love.graphics.newFont("font.ttf", 30)
  self.titleFont = love.graphics.newFont("font.ttf", 50)
  self.height = WINDOW_HEIGHT
  
  -- SELECTION
  self.selected = 1
  self.options = 1
  self.options1 = {"PLAY", "SETTINGS", "EXIT"}
  self.options2 = {"MUSIC", "CONTROLS", "LEVEL 1", "BACK"}
  self.options3 = {"LEFT MOVE KEY: " .. left, "RIGHT MOVE KEY: " .. right, "HARD DROP: " .. hard, "SOFT DROP: " .. soft, "HOLD: " .. hold, "ROTATE LEFT: " .. counterClock, "ROTATE RIGHT: " .. clockwise, "BACK"}
  
  change = false
end

function Title:update(dt)
  self.timer = self.timer + dt
  self.options2 = {"MUSIC", "CONTROLS", "LEVEL " .. level .. "/25", "BACK"}
  self.options3 = {"LEFT MOVE KEY: " .. left, "RIGHT MOVE KEY: " .. right, "HARD DROP: " .. hard, "SOFT DROP: " .. soft, "HOLD: " .. hold, "ROTATE LEFT: " .. counterClock, "ROTATE RIGHT: " .. clockwise, "BACK"}
    
  -- FONT
  if self.timer > 3 and self.height ~= 200 then
    self.height = self.height - 10
  end
    
  -- MUSIC / SFX
  if self.timer > 1 and self.timer < 1.1 then
    sounds.sfxOver = true
    sounds.explosion:play()
  end
  if self.timer > 4 then
    sounds.musicTable[sounds.musicSelected]:play()
  end
end

function Title:draw()
  love.graphics.setColor(1, 1, 1)
  if self.timer > 1 then
    love.graphics.setFont(self.titleFont)
    love.graphics.printf("LUA TETRIS", 0, self.height / 2 - 50, WINDOW_WIDTH, "center") 
  end
  if self.timer > 4 then
    love.graphics.setFont(self.descFont)
    love.graphics.printf("Andy Phan", 0, WINDOW_HEIGHT - 20, WINDOW_WIDTH - 10, "right") 
    if self.options == 1 then
      for i, options in ipairs(self.options1) do
        love.graphics.setFont(self.optionsFont)
        if options == self.options1[self.selected] then
          love.graphics.setColor(255/255, 255/255, 0)
        else
          love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(options, 0, 200 + 40 * i, WINDOW_WIDTH, "center")
      end
    elseif self.options == 2 then
      for i, options in ipairs(self.options2) do
        love.graphics.setFont(self.optionsFont)
        if options == self.options2[self.selected] then
          love.graphics.setColor(255/255, 255/255, 0)
        else
          love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(options, 0, 200 + 40 * i, WINDOW_WIDTH, "center")
      end
    elseif self.options == 3 then
      for i, options in ipairs(self.options3) do
        love.graphics.setFont(self.optionsFont)
        if options == self.options3[self.selected] then
          love.graphics.setColor(255/255, 255/255, 0)
        else
          love.graphics.setColor(1, 1, 1)
        end
        love.graphics.printf(options, 0, 200 + 40 * i, WINDOW_WIDTH, "center")
      end
    end
  end
  if change then
    love.graphics.printf("PRESS KEY TO CHANGE", 0, 100, WINDOW_WIDTH, "center")
  end
end

function Title:select(key)
  if change then
    if self.selected == 1 then
      left = key
    elseif self.selected == 2 then
      right = key
    elseif self.selected == 3 then
      hard = key
    elseif self.selected == 4 then
      soft = key
    elseif self.selected == 5 then
      hold = key
    elseif self.selected == 6 then
      counterClock = key
    elseif self.selected == 7 then
      clockwise = key
    end
    change = false
    saveControls()
  elseif self.timer > 4 then
    if key == "s" or key == "down" then
      sounds.move:play()
      if self.options == 1 then
        if self.selected == #self.options1 then
          self.selected = 1
        else
          self.selected = self.selected + 1
        end
      elseif self.options == 2 then
        if self.selected == #self.options2 then
          self.selected = 1
        else
          self.selected = self.selected + 1
        end
      elseif self.options == 3 then
        if self.selected == #self.options3 then
          self.selected = 1
        else
          self.selected = self.selected + 1
        end
      end
    end
    if key == "w" or key == "up" then
        sounds.move:play()
        if self.options == 1 then
          if self.selected == 1 then
            self.selected = #self.options1
          else
            self.selected = self.selected - 1
          end
        elseif self.options == 2 then
          if self.selected == 1 then
            self.selected = #self.options2
          else
            self.selected = self.selected - 1
          end
        elseif self.options == 3 then
          if self.selected == 1 then
            self.selected = #self.options3
          else
            self.selected = self.selected - 1
          end
        end
      end
      if key == "space" or key == "enter" then
        sounds.select:play()
        if self.options == 1 then
          if self.options1[self.selected] == "PLAY" then
            gameState = "play"
            setLevel = level
          elseif self.options1[self.selected] == "SETTINGS" then
            self.options = 2
            self.selected = 1
          elseif self.options1[self.selected] == "EXIT" then
            love.event.quit()
          end
        elseif self.options == 2 then
          if self.options2[self.selected] == "MUSIC" then
            love.audio.stop()
            if sounds.musicSelected == #sounds.musicTable then
              sounds.musicSelected = 1
            else
              sounds.musicSelected = sounds.musicSelected + 1
            end
            saveControls()
          elseif self.options2[self.selected] == "CONTROLS" then
            self.options = 3
            self.selected = 1
          elseif self.options2[self.selected] == "LEVEL " .. level .. "/25" then
            level = level + 1
            if level == 26 then
              level = 1
            end
          elseif self.options2[self.selected] == "BACK" then
            self.options = 1
            self.selected = 2
          end
        elseif self.options == 3 then
          if self.selected == 8 then
            self.options = 2
            self.selected = 2
          else
            change = true
          end
        end
      end
  end
end
