-- Tile class.
-- Handle processing for each of the game tiles.
Tile = {
  x         = 0,
  y         = 0,
  cost      = 1,
  sx        = 32,
  sy        = 32,
  costValue = 1,
  visible   = false,
}
Tile_mt = { __index = Tile }

function Tile:new(x, y, gx, gy)
  costValue   = math.random(5)
  return setmetatable({
    x         = x,
    y         = y,
    gx        = gx,
    gy        = gy,
    costValue = costValue,
    visible   = visible,
  }, Tile_mt)
end


function Tile:draw()
  -- Draw the target tile in red so we know what's up.
  if game.level.target == self then
    self:box(255, 0, 0, 255)
  end

  -- Draw the selection around an active tile.
  local mousex, mousey = love.mouse.getPosition()
  if self:is_inside(mousex, mousey) and self:is_legal_move() then
    self:box(255, 255, 255, 255)
  end

  -- Determine if we should show the cost value to the player.
  -- Also draw the cost sprite, if there is one.
  if not self:is_visible() then return end

  -- Restore the old colour when we're done.
  local oldr, oldg, oldb, olda = love.graphics.getColor()

  -- Light up legal moves and gray out illegal ones to give the
  -- player a better hint about where it's possible to move.
  if self:is_legal_move() then
    love.graphics.setColor(255, 255, 255, 255)
  else
    love.graphics.setColor(90, 90, 90, 255)
  end

  if self.costValue == 3 then
    love.graphics.draw(game.images.asteroidBelt, self.x, self.y)
  elseif self.costValue == 4 then
   love.graphics.draw(game.images.spaceStation, self.x, self.y)
  elseif self.costValue == 5 then
    love.graphics.draw(game.images.sun, self.x, self.y)

    -- Make costs shown of these suns black for readability.
    love.graphics.setColor(0, 0, 0, 255)
  end

  if self:is_inside(mousex, mousey) then
    love.graphics.print(self.costValue, self.x+13, self.y+9)
  end

  love.graphics.setColor(oldr, oldg, oldb, olda)

  --run the animation for the path the payer has traveled
  if self.visible == true and self ~= player.tile then
    game.animations.s_path:draw(self.x, self.y)
  end

  -- Do not show the tile underlying the player as it can confuse.
  if player.tile == self then
    player:draw(self.x, self.y)
  end
end

function Tile:box(r, g, b, a)
  -- Draw the actual box around a tile.
  local oldr, oldg, oldb, olda = love.graphics.getColor()

  love.graphics.setColor(r, g, b, a)
  love.graphics.line(self.x, self.y, (self.x+self.sx), self.y)
  love.graphics.line(self.x, self.y, self.x, (self.y+self.sy))
  love.graphics.line((self.x+self.sx), self.y, (self.x+self.sx), (self.y+self.sy))
  love.graphics.line(self.x, (self.y+self.sy), (self.x+self.sx), (self.y+self.sy))

  love.graphics.setColor(oldr, oldg, oldb, olda)
end

function Tile:is_inside(x, y)
  -- Returns if a given point is inside the square.
  -- Does not include the borders drawn around the tile.
  return (x >= (self.x + 1) and x <= (self.x + (self.sx - 1)) and
    y >= (self.y + 1) and y <= (self.y + (self.sy - 1)))
end

function Tile:is_legal_move()
  -- Returns if the tile is a legal move for the player's current pos.
  -- Does not allow diagonal motion. Might want to change that soon.
  return (self.x == (player.tile.x + self.sx) and self.y == player.tile.y)
    or (self.x == (player.tile.x - self.sx) and self.y == player.tile.y)
    or (self.y == (player.tile.y + self.sy) and self.x == player.tile.x)
    or (self.y == (player.tile.y - self.sy) and self.x == player.tile.x)
end

function Tile:is_visible()
  -- Returns whether the tile should be visible at all on-screen.
  -- Includes diagonal squares, which cannot be moved to but you
  -- might want to see what's up.
  return (self:is_legal_move())
      or (player.tile == self)
      or (self.x == player.tile.x+32 and self.y == player.tile.y+32)
      or (self.x == player.tile.x-32 and self.y == player.tile.y-32)
      or (self.x == player.tile.x+32 and self.y == player.tile.y-32)
      or (self.x == player.tile.x-32 and self.y == player.tile.y+32)
      or (self.x == player.tile.x+64 and self.y == player.tile.y)
      or (self.x == player.tile.x and self.y == player.tile.y+64)
      or (self.x == player.tile.x-64 and self.y == player.tile.y)
      or (self.x == player.tile.x and self.y == player.tile.y-64)
      or self.visible == true
end
