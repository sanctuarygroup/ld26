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
  level     = 0,
}
Tile_mt = { __index = Tile }

function Tile:new(x, y, gx, gy, level)
  -- Create a new tile and determine what cost it should have.
  level = level or 0
  local costTemp = math.random(101)
  if costTemp < (45-(level * 5)) then
    costValue = 1
  elseif costTemp > (46-(level * 5)) and costTemp < (85-(level * 5)) then
    costValue = 7
  elseif costTemp > (86-(level * 5)) and costTemp < (95-(level * 5)) then
    costValue = 10
  elseif costTemp > (96-(level * 5))  and costTemp == 101 then
    costValue = 20
  end

  return setmetatable({
    x         = x,
    y         = y,
    gx        = gx,
    gy        = gy,
    costValue = costValue,
    visible   = visible,
    level     = level,
  }, Tile_mt)
end


function Tile:draw()
  -- Rendering loop for each tile.

  -- Draw the target tile in red so we know what's up.
  if game.level.target == self then
    self:box(0, 255, 255, 255)
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

  xPos = self.x+8
  if self.costValue == 7 then
    love.graphics.draw(game.images.asteroidBelt, self.x, self.y)
  elseif self.costValue == 10 then
   love.graphics.draw(game.images.spaceStation, self.x, self.y)
   xPos = self.x-2
  elseif self.costValue == 20 then
    love.graphics.draw(game.images.sun, self.x, self.y)
    xPos = self.x-2

    -- Make costs shown of these suns black for readability.
    love.graphics.setColor(0, 0, 0, 255)
  elseif game.level.start == self then
    love.graphics.draw(game.images.wormhole, self.x, self.y)
  elseif game.level.target == self then
    love.graphics.draw(game.images.wormhole_in, self.x, self.y)
  end

  if self:is_inside(mousex, mousey) and self:is_legal_move() then
    -- Use a larger font to make things clearer.
    love.graphics.setFont(game.fonts.large)
    love.graphics.print(self.costValue, xPos, self.y-6)
    love.graphics.setFont(game.fonts.normal)
  end

  love.graphics.setColor(oldr, oldg, oldb, olda)

  -- Show tiles that the player has passed through.
  if self.visible == true and self~=player.tile then
    game.animations.s_path:draw(self.x, self.y)
  end

  -- Do not show the tile underlying the player as it can confuse.
  if player.tile == self then player:draw(self.x, self.y) end
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
      or (game.level.target == self)
      or (game.level.start == self)
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

function Tile:click(x, y)
  -- Click handler for each tile.
  if self:is_inside(x, y) and self:is_legal_move() then
    player.tile.visible = true

    -- Set up the next level if we've reached the target.
    if self == game.level.target then
      game.level  = Level:new(game.level.number + 1, (self.gx+1), (self.gy+1))
      player.tile = game.level.start
      player.tile.costValue = 0
    else
      player.tile = self
    end

    -- Do the normal cost accounting for the move.
    if player.tile.costValue >= player.energy then
      player:updateEnergy(0)
    else
      player:updateEnergy(player.energy - player.tile.costValue)
    end
    return true
  end
end
