-- Game over screen, shown when the player runs out of energy.
gameOverScreen    = {}
gameOverScreen_mt = { __index = gameOverScreen }

function gameOverScreen:new()
  -- Load in necessary resources for the screen.
  local fonts = {
    large = love.graphics.newFont("assets/sourcesans.ttf", 32),
  }

  local displayTime = love.timer.getTime()

  local background = love.graphics.newImage("assets/gameover.png")

  return setmetatable({
    fonts       = fonts,
    displayTime = displayTime,
    background  = background,
  }, gameOverScreen_mt)
end

function gameOverScreen:update(dt)
  -- Update any animations in this screen.
  local nowTime = love.timer.getTime()
  if (nowTime - self.displayTime) >= 5 then
    love.event.push("quit")
  end
end

function gameOverScreen:click(x, y, button)
  -- Process mouse clicks on this screen.
end

function gameOverScreen:draw()
  -- Draw this screen for the current frame.
  love.graphics.draw(self.background, 0, 0)
end
