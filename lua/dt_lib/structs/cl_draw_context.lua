local WHITE = Color(255, 255, 255)
local BLUR = Material("pp/blurscreen")

--- @class DT_Lib.DrawContext
DT_Lib.DRAW_CONTEXT = {}

--- Creates a new DrawContext
--- @param width? number @The width of the context
--- @param height? number @The height of the context
--- @return DT_Lib.DrawContext
function DT_Lib.DrawContext(width, height)
  local ctx = setmetatable({}, {__index = DT_Lib.DRAW_CONTEXT})
  ctx.Width = width or ScrW()
  ctx.Height = height or ScrH()
  ctx.Origin = {x = 0, y = 0}
  ctx.Offset = {x = 0, y = 0}
  ctx.Scale = 1
  ctx.WrapAround = true
  ctx.Font = "DermaDefault"
  ctx.TextColor = WHITE
  ctx.Polygons = {}
  return ctx
end

--- Converts a local value to a screen value.
--- @param v number @The value to convert
function DT_Lib.DRAW_CONTEXT:LocalToScreen(v)
  return v/100*self.Height*self.Scale
end

--- Converts a screen value to a local value.
--- @param v number @The value to convert
function DT_Lib.DRAW_CONTEXT:ScreenToLocal(v)
  return v/self.Height/self.Scale*100
end

--- Returns the x and y values of the top left corner.
--- @return number, number
function DT_Lib.DRAW_CONTEXT:GetTopLeft()
  return 0, 0
end

--- Returns the x and y values of the bottom right corner.
--- @return number, number
function DT_Lib.DRAW_CONTEXT:GetBottomRight()
  local x = self:ScreenToLocal(self.Width)
  local y = self:ScreenToLocal(self.Height)
  return x, y
end

--- Returns the x and y values of the center.
--- @return number, number
function DT_Lib.DRAW_CONTEXT:GetCenter()
  local x, y = self:GetBottomRight()
  return x/2, y/2
end

--- Converts a world pos to a local value.
--- @param pos Vector @The position to convert
--- @return number?, number?
function DT_Lib.DRAW_CONTEXT:FromWorldPos(pos)
  local res = pos:ToScreen()
  if res.x < 0 or res.x >= self.Width then return end
  if res.y < 0 or res.y >= self.Height then return end
  local x = self:ScreenToLocal(res.x)
  local y = self:ScreenToLocal(res.y)
  return x, y
end

--- Translates a local coordinate on the X axis to a screen coordinate.
--- @param x number @The value to convert
function DT_Lib.DRAW_CONTEXT:TranslateX(x)
  local x = self:LocalToScreen(x + self.Origin.x)
  if self:GetWrapAround() then x = x % self.Width end
  return x + self:LocalToScreen(self.Offset.x)
end

--- Translates a local coordinate on the Y axis to a screen coordinate.
--- @param y number @The value to convert
function DT_Lib.DRAW_CONTEXT:TranslateY(y)
  local y = self:LocalToScreen(y + self.Origin.y)
  if self:GetWrapAround() then y = y % self.Height end
  return y + self:LocalToScreen(self.Offset.y)
end

--- Get the width of this context.
--- @return number
function DT_Lib.DRAW_CONTEXT:GetWidth()
  return self.Width
end

--- Set the width of this context.
--- @param width number @The new width
function DT_Lib.DRAW_CONTEXT:SetWidth(width)
  self.Width = width
end

--- Get the height of this context.
--- @return number
function DT_Lib.DRAW_CONTEXT:GetHeight()
  return self.Height
end

--- Set the height of this context.
--- @param height number @The new height
function DT_Lib.DRAW_CONTEXT:SetHeight(height)
  self.Height = height
end

--- Get the origin of this context.
--- @return number, number
function DT_Lib.DRAW_CONTEXT:GetOrigin()
  return self.Origin.x, self.Origin.y
end

--- Set the origin of this context.
--- @param x number @The new origin on the X axis
--- @param y number @The new origin on the Y axis
function DT_Lib.DRAW_CONTEXT:SetOrigin(x, y)
  self.Origin.x = x
  self.Origin.y = y
end

--- Get the offset of this context.
--- @return number, number
function DT_Lib.DRAW_CONTEXT:GetOffset()
  return self.Offset.x, self.Offset.y
end

--- Set the offset of this context.
--- @param x number @The new offset on the X axis
--- @param y number @The new offset on the Y axis
function DT_Lib.DRAW_CONTEXT:SetOffset(x, y)
  self.Offset.x = x
  self.Offset.y = y
end

--- Get the scale of this context.
--- @return number
function DT_Lib.DRAW_CONTEXT:GetScale()
  return self.Scale
end

--- Set the scale of this context.
--- @param scale number @The new scale
function DT_Lib.DRAW_CONTEXT:SetScale(scale)
  self.Scale = scale
end

--- @return boolean
function DT_Lib.DRAW_CONTEXT:GetWrapAround()
  return self.WrapAround
end

--- @param wrap boolean @Whether to wrap around the screen
function DT_Lib.DRAW_CONTEXT:SetWrapAround(wrap)
  self.WrapAround = wrap
end

--- @return string
function DT_Lib.DRAW_CONTEXT:GetDefaultFont()
  return self.Font
end

--- @param font string @The new default font
function DT_Lib.DRAW_CONTEXT:SetDefaultFont(font)
  self.Font = font
end

--- @return Color
function DT_Lib.DRAW_CONTEXT:GetDefaultTextColor()
  return self.TextColor
end

--- @param color Color @The new default text color
function DT_Lib.DRAW_CONTEXT:SetDefaultTextColor(color)
  self.TextColor = color
end

-- Draw simple things --

--- @param text string
--- @param font string
--- @param maxLength number
--- @return string
local function ShortenText(text, font, maxLength)
  surface.SetFont(font)
  local length = surface.GetTextSize(text)
  if length <= maxLength then return text end
  local shortened
  repeat
    text = string.Left(text, #text-1)
    shortened = text.."..."
  until surface.GetTextSize(shortened) <= maxLength
  return shortened
end

--- @class DT_Lib.DrawTextOptions
--- @field font string?
--- @field color any?
--- @field xAlign number?
--- @field yAlign number?
--- @field outlineColor any?
--- @field outlineWidth number?
--- @field maxLength number?

--- @param x number
--- @param y number
--- @param text string
--- @param options? DT_Lib.DrawTextOptions
function DT_Lib.DRAW_CONTEXT:DrawText(x, y, text, options)
  if options == nil then options = {} end
  local font = options.font or self:GetDefaultFont()
  local color = options.color or self:GetDefaultTextColor()
  local xAlign = options.xAlign or TEXT_ALIGN_LEFT
  local yAlign = options.yAlign or TEXT_ALIGN_TOP
  if options.maxLength then
    text = ShortenText(text, font, self:LocalToScreen(options.maxLength))
  end
  if options.outlineColor then
    local outlineColor = options.outlineColor
    local outlineWidth = options.outlineWidth or 1
    return draw.SimpleTextOutlined(text, font, self:TranslateX(x), self:TranslateY(y), color, xAlign, yAlign, outlineWidth, outlineColor)
  else
    return draw.SimpleText(text, font, self:TranslateX(x), self:TranslateY(y), color, xAlign, yAlign)
  end
end

--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @param color any
function DT_Lib.DRAW_CONTEXT:DrawLine(x1, y1, x2, y2, color)
  surface.SetDrawColor(color)
  surface.DrawLine(
    self:TranslateX(x1), self:TranslateY(y1),
    self:TranslateX(x2), self:TranslateY(y2)
  )
end

-- Polygon --

--- @class DT_Lib.DrawPolygonPoint
--- @field x number
--- @field y number
--- @field u number?
--- @field v number?

--- @class DT_Lib.DrawPolygon
--- @field Points DT_Lib.DrawPolygonPoint[]
DT_Lib.DRAW_POLYGON = {}

--- @param x number
--- @param y number
--- @param points DT_Lib.DrawPolygonPoint[]
--- @return DT_Lib.DrawPolygon
function DT_Lib.DRAW_CONTEXT:CreatePolygon(x, y, points)
  local polygon = setmetatable({}, {__index = DT_Lib.DRAW_POLYGON})
  polygon.Points = {}
  for _, point in ipairs(points) do
    table.insert(polygon.Points, {
      x = self:TranslateX(x) + self:LocalToScreen(point.x),
      y = self:TranslateY(y) + self:LocalToScreen(point.y),
      u = point.u or 0, v = point.v or 0
    })
  end
  return polygon
end

--- @param x number
--- @param y number
--- @param length number
--- @param height number
--- @return DT_Lib.DrawPolygon
function DT_Lib.DRAW_CONTEXT:CreateRectangle(x, y, length, height)
  return self:CreatePolygon(x, y, {
    {x = 0, y = 0, u = 0, v = 0},
    {x = length, y = 0, u = 1, v = 0},
    {x = length, y = height, u = 1, v = 1},
    {x = 0, y = height, u = 0, v = 1}
  })
end

--- @param x number
--- @param y number
--- @param length number
--- @return DT_Lib.DrawPolygon
function DT_Lib.DRAW_CONTEXT:CreateSquare(x, y, length)
  return self:CreateRectangle(x, y, length, length)
end

--- @param radius number
--- @param lines number
--- @param angle? number
--- @return DT_Lib.DrawPolygonPoint[]
local function CalcCirclePoints(radius, lines, angle)
  local theta = math.rad(360/lines)
  local points = {}
  for i = 0, lines-1 do
    local a = theta*i+math.rad(angle or 0)
    local x = math.cos(a)*radius
    local y = math.sin(a)*radius
    local u = 0.5 + x/(radius*2)
    local v = 0.5 + y/(radius*2)
    table.insert(points, {
      x = x, y = y,
      u = u, v = v
    })
  end
  return points
end

--- @param x number
--- @param y number
--- @param radius number
--- @param lines number
--- @param angle? number
--- @return DT_Lib.DrawPolygon
function DT_Lib.DRAW_CONTEXT:CreateCircle(x, y, radius, lines, angle)
  local points = CalcCirclePoints(radius, lines, angle)
  return self:CreatePolygon(x, y, points)
end

--- @param x number
--- @param y number
--- @param size number
--- @param angle? number
--- @return DT_Lib.DrawPolygon
function DT_Lib.DRAW_CONTEXT:CreateTriangle(x, y, size, angle)
  return self:CreateCircle(x, y, size, 3, angle)
end

--- @param x number
--- @param y number
--- @param size number
--- @param angle? number
--- @return DT_Lib.DrawPolygon
function DT_Lib.DRAW_CONTEXT:CreateDiamond(x, y, size, angle)
  return self:CreateCircle(x, y, size, 4, angle)
end

--- @param x number
--- @param y number
--- @param size number
--- @param angle? number
--- @return DT_Lib.DrawPolygon
function DT_Lib.DRAW_CONTEXT:CreateHexagon(x, y, size, angle)
  return self:CreateCircle(x, y, size, 6, angle)
end

--- Draws the outline of this polygon.
--- @param color Color @Which color to use
--- @return DT_Lib.DrawPolygon self
function DT_Lib.DRAW_POLYGON:Stroke(color)
  surface.SetDrawColor(color)
  for i = 1, #self.Points do
    local j = i == #self.Points and 1 or i+1
    surface.DrawLine(
      self.Points[i].x, self.Points[i].y,
      self.Points[j].x, self.Points[j].y
    )
  end
  return self
end

--- Draws the body of this polygon.
--- @param color? Color @Which color to use
--- @param material? IMaterial @Which material to use
--- @return DT_Lib.DrawPolygon self
function DT_Lib.DRAW_POLYGON:Fill(color, material)
  if color or material then
    if color then
      surface.SetDrawColor(color)
    else surface.SetDrawColor(WHITE) end
    if material then
      surface.SetMaterial(material)
    else draw.NoTexture() end
    surface.DrawPoly(self.Points)
  end
  return self
end

--- Draws a blur effect on this polygon.
--- @param passes number
--- @return DT_Lib.DrawPolygon self
function DT_Lib.DRAW_POLYGON:Blur(passes)
  local points = {}
  for _, point in pairs(self.Points) do
    table.insert(points, {
      x = point.x, y = point.y,
      u = point.x/ScrW(),
      v = point.y/ScrH()
    })
  end
  surface.SetMaterial(BLUR)
  surface.SetDrawColor(WHITE)
  for i = 1, passes do
    BLUR:SetFloat("$blur", (i/3)*(25/passes))
    BLUR:Recompute()
    render.UpdateScreenEffectTexture()
    surface.DrawPoly(points)
  end
  return self
end

-- Complex shapes --

--- @param x number
--- @param y number
--- @param radius number
--- @param lines number
--- @param angle? number
--- @param from number
--- @param to number
--- @return DT_Lib.DrawPolygon
function DT_Lib.DRAW_CONTEXT:CreateCirclePiece(x, y, radius, lines, angle, from, to)
  local points = CalcCirclePoints(radius, lines, angle)
  local piece = {{x = 0, y = 0, u = 0.5, v = 0.5}}
  for i = from, to do
    local point = points[i % #points + 1]
    table.insert(piece, point)
  end
  return self:CreatePolygon(x, y, piece)
end

--- @class DT_Lib.DrawRing
--- @field OuterCircle DT_Lib.DrawPolygon
--- @field InnerCircle DT_Lib.DrawPolygon
DT_Lib.DRAW_RING = {}

--- @param x number
--- @param y number
--- @param outerRadius number
--- @param innerRadius number
--- @param lines number
--- @param angle? number
function DT_Lib.DRAW_CONTEXT:CreateRing(x, y, outerRadius, innerRadius, lines, angle)
  local ring = setmetatable({}, {__index = DT_Lib.DRAW_RING})
  ring.OuterCircle = self:CreateCircle(x, y, outerRadius, lines, angle)
  ring.InnerCircle = self:CreateCircle(x, y, innerRadius, lines, angle)
  return ring
end

--- Draws the outlines of this ring.
--- @param color Color @Which color to use
--- @return DT_Lib.DrawRing self
function DT_Lib.DRAW_RING:Stroke(color)
  self.OuterCircle:Stroke(color)
  self.InnerCircle:Stroke(color)
  return self
end

--- Draws the body of this ring.
--- @param color? Color @Which color to use
--- @param material? IMaterial @Which material to use
--- @return DT_Lib.DrawRing self
function DT_Lib.DRAW_RING:Fill(color, material)
  if color or material then
    DT_Lib.ResetStencil()
    render.SetStencilEnable(true)
      render.SetStencilCompareFunction(STENCIL_NEVER)
      render.SetStencilFailOperation(STENCILOPERATION_INCR)
      self.InnerCircle:Fill(WHITE)
      render.SetStencilCompareFunction(STENCIL_EQUAL)
      self.OuterCircle:Fill(color, material)
    render.SetStencilEnable(false)
  end
  return self
end

--- Draws a blur effect on this ring.
--- @param passes number
--- @return DT_Lib.DrawRing self
function DT_Lib.DRAW_RING:Blur(passes)
  DT_Lib.ResetStencil()
  render.SetStencilEnable(true)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCILOPERATION_INCR)
    self.InnerCircle:Fill(WHITE)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    self.OuterCircle:Blur(passes)
  render.SetStencilEnable(false)
  return self
end