DT_Core.DrawPolygon = DT_Core.Struct()

local WHITE = Color(255, 255, 255)
local BLUR = Material("pp/blurscreen")

function DT_Core.DrawContext.__index:CreatePolygon(x, y, points)
  local polygon = DT_Core.DrawPolygon.__raw()
  polygon.__Pos = {x = tonumber(x), y = tonumber(y)}
  polygon.__Points = points
  polygon.__Context = self
  return polygon
end

function DT_Core.DrawContext.__index:CreateRectangle(x, y, length, height)
  return self:CreatePolygon(x, y, {
    {x = 0, y = 0, u = 0, v = 0},
    {x = length, y = 0, u = 1, v = 0},
    {x = length, y = height, u = 1, v = 1},
    {x = 0, y = height, u = 0, v = 1}
  })
end

function DT_Core.DrawContext.__index:CreateSquare(x, y, length)
  return self:CreateRectangle(x - length / 2, y - length / 2, length, length)
end

local function CalcCirclePoints(radius, lines, angle)
  local theta = math.rad(360 / lines)
  local points = {}
  for i = 0, lines - 1 do
    local a = theta * i + math.rad(angle or 0)
    local x = math.cos(a) * radius
    local y = math.sin(a) * radius
    local u = 0.5 + x / (radius * 2)
    local v = 0.5 + y / (radius * 2)
    table.insert(points, {
      x = x, y = y,
      u = u, v = v
    })
  end
  return points
end

function DT_Core.DrawContext.__index:CreateCircle(x, y, radius, lines, angle)
  local points = CalcCirclePoints(radius, lines, angle)
  return self:CreatePolygon(x, y, points)
end

function DT_Core.DrawContext.__index:CreateTriangle(x, y, size, angle)
  return self:CreateCircle(x, y, size, 3, angle)
end

function DT_Core.DrawContext.__index:CreateDiamond(x, y, size, angle)
  return self:CreateCircle(x, y, size, 4, angle)
end

function DT_Core.DrawContext.__index:CreateHexagon(x, y, size, angle)
  return self:CreateCircle(x, y, size, 6, angle)
end

function DT_Core.DrawContext.__index:CreateCirclePiece(x, y, radius, lines, angle, from, to)
  local points = CalcCirclePoints(radius, lines, angle)
  local piece = {{x = 0, y = 0, u = 0.5, v = 0.5}}
  for i = from, to do
    local point = points[i % #points + 1]
    table.insert(piece, point)
  end
  return self:CreatePolygon(x, y, piece)
end

function DT_Core.DrawPolygon.__index:Copy()
  local polygon = DT_Core.DrawPolygon.__raw()
  polygon.__Points = table.Copy(self.__Points)
  polygon.__Pos = table.Copy(self.__Pos)
  polygon.__Context = self.__Context
  return polygon
end

function DT_Core.DrawPolygon.__index:CalcPoints()
  local points = {}
  local ctx = self.__Context
  for _, point in ipairs(self.__Points) do
    table.insert(points, {
      x = ctx:TranslateX(self.__Pos.x) + ctx:LocalToScreen(point.x),
      y = ctx:TranslateY(self.__Pos.y) + ctx:LocalToScreen(point.y),
      u = point.u or 0, v = point.v or 0
    })
  end
  return points
end

-- Draws the outline of this polygon
function DT_Core.DrawPolygon.__index:Stroke(color)
  surface.SetDrawColor(color)
  local points = self:CalcPoints()
  for i = 1, #points do
    local j = i == #points and 1 or i + 1
    surface.DrawLine(
      points[i].x, points[i].y,
      points[j].x, points[j].y
    )
  end
  return self
end

-- Draws the inside of this polygon
function DT_Core.DrawPolygon.__index:Fill(color, material)
  if not color then
    surface.SetDrawColor(self.__Context:GetDefaultColor())
  else surface.SetDrawColor(color) end
  if material then
    surface.SetMaterial(material)
  else draw.NoTexture() end
  surface.DrawPoly(self:CalcPoints())
  return self
end

function DT_Core.DrawPolygon.__index:Outline(width, color, material)
  color = color or self.__Context:GetDefaultOutlineColor()
  width = width or self.__Context:GetDefaultOutlineWidth()
  for i = 1, 8 do
    local copy = self:Copy()
    if i == 1 or i == 2 or i == 8 then
      copy.__Pos.x = copy.__Pos.x - width
    elseif i >= 4 and i <= 6 then
      copy.__Pos.x = copy.__Pos.x + width
    end
    if i >= 2 and i <= 4 then
      copy.__Pos.y = copy.__Pos.y - width
    elseif i >= 6 and i <= 8 then
      copy.__Pos.y = copy.__Pos.y + width
    end
    copy:Fill(color, material)
  end
  return self
end

-- Draws a blur effect on this polygon
function DT_Core.DrawPolygon.__index:Blur(passes)
  local points = {}
  for _, point in pairs(self:CalcPoints()) do
    table.insert(points, {
      x = point.x, y = point.y,
      u = point.x / ScrW(),
      v = point.y / ScrH()
    })
  end
  surface.SetMaterial(BLUR)
  surface.SetDrawColor(WHITE)
  for i = 1, passes do
    BLUR:SetFloat("$blur", (i / 3) * (25 / passes))
    BLUR:Recompute()
    render.UpdateScreenEffectTexture()
    surface.DrawPoly(points)
  end
  return self
end