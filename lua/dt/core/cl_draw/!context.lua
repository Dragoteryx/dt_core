DT_Core.DrawContext = DT_Core.Struct()

-- DrawContext constructor
-- Used as DT_Core.DrawContext(width, height)
function DT_Core.DrawContext:__new(width, height)
  self.__Width = tonumber(width or ScrW())
  self.__Height = tonumber(height or ScrH())
  self.__OriginX = 0
  self.__OriginY = 0
  self.__Scale = 1
  self.__Font = "DermaDefault"
  self.__Color = Color(255, 255, 255)
  self.__OutlineColor = Color(0, 0, 0)
  self.__OutlineWidth = 0.1
end

-- Get the width of this context
function DT_Core.DrawContext.__index:GetWidth()
  return self.__Width
end

-- Get the height of this context
function DT_Core.DrawContext.__index:GetHeight()
  return self.__Height
end

-- Get the origin of this context
function DT_Core.DrawContext.__index:GetOrigin()
  return self.__OriginX, self.__OriginY
end

-- Set the origin of this context
function DT_Core.DrawContext.__index:SetOrigin(x, y)
  self.__OriginX = tonumber(x)
  self.__OriginY = tonumber(y)
end

-- Set the origin of this context
-- Negative values wrap around the screen
function DT_Core.DrawContext.__index:SetOriginWrapping(x, y)
  local width, height = self:GetBottomRight()
  self.__OriginX = tonumber(x) % width
  self.__OriginY = tonumber(y) % height
end

-- Moves the origin relative to its current position
function DT_Core.DrawContext.__index:MoveOrigin(x, y)
  self.__OriginX = self.__OriginX + tonumber(x)
  self.__OriginY = self.__OriginY + tonumber(y)
end

-- Moves the origin relative to its current position
-- Negative values wrap around the screen
function DT_Core.DrawContext.__index:MoveOriginWrapping(x, y)
  local width, height = self:GetBottomRight()
  self.__OriginX = (self.__OriginX + tonumber(x)) % width
  self.__OriginY = (self.__OriginY + tonumber(y)) % height
end

-- Get the scale of this context
function DT_Core.DrawContext.__index:GetScale()
  return self.__Scale
end

-- Set the scale of this context
function DT_Core.DrawContext.__index:SetScale(scale)
  self.__Scale = tonumber(scale)
end

function DT_Core.DrawContext.__index:GetDefaultFont()
  return self.__Font
end

function DT_Core.DrawContext.__index:SetDefaultFont(font)
  self.__Font = tostring(font)
end

function DT_Core.DrawContext.__index:GetDefaultColor()
  return self.__Color
end

function DT_Core.DrawContext.__index:SetDefaultColor(color)
  self.__Color = color
end

function DT_Core.DrawContext.__index:GetDefaultOutlineColor()
  return self.__OutlineColor
end

function DT_Core.DrawContext.__index:SetDefaultOutlineColor(color)
  self.__OutlineColor = color
end

function DT_Core.DrawContext.__index:GetDefaultOutlineWidth()
  return self.__OutlineWidth
end

function DT_Core.DrawContext.__index:SetDefaultOutlineWidth(width)
  self.__OutlineWidth = tonumber(width)
end

-- Converts a screen value to a local value
function DT_Core.DrawContext.__index:ScreenToLocal(v)
  return v / ScrH() / self:GetScale() * 100
end

-- Converts a local value to a screen value
function DT_Core.DrawContext.__index:LocalToScreen(v)
  return v / 100 * ScrH() * self:GetScale()
end

-- Translates a local coordinate on the x axis to a screen coordinate
function DT_Core.DrawContext.__index:TranslateX(x)
  return self:LocalToScreen(self.__OriginX + x)
end

-- Translates a local coordinate on the y axis to a screen coordinate
function DT_Core.DrawContext.__index:TranslateY(y)
  return self:LocalToScreen(self.__OriginY + y)
end

-- Converts a world pos to a local value
function DT_Core.DrawContext.__index:FromWorldPos(pos)
  local res = pos:ToScreen()
  if res.x < 0 or res.x >= self.__Width then return end
  if res.y < 0 or res.y >= self.__Height then return end
  local x = self:ScreenToLocal(res.x)
  local y = self:ScreenToLocal(res.y)
  return x, y
end

-- Returns the x and y values of the top left corner
function DT_Core.DrawContext.__index:GetTopLeft()
  return 0, 0
end

-- Returns the x and y values of the bottom right corner
function DT_Core.DrawContext.__index:GetBottomRight()
  local width = self:ScreenToLocal(self.__Width)
  local height = self:ScreenToLocal(self.__Height)
  return width, height
end

-- Returns the x and y values of the center
function DT_Core.DrawContext.__index:GetCenter()
  local x, y = self:GetBottomRight()
  return x / 2, y / 2
end

-- Draw simple things --

function DT_Core.DrawContext.__index:DrawLine(x1, y1, x2, y2, color)
  surface.SetDrawColor(color or self:GetDefaultColor())
  surface.DrawLine(
    self:TranslateX(x1), self:TranslateY(y1),
    self:TranslateX(x2), self:TranslateY(y2)
  )
end

function DT_Core.DrawContext.__index:DrawMaterial(x, y, size, material, options)
  if IsColor(options) then return self:DrawMaterial(x, y, size, material, {color = options}) end
  if isbool(options) then return self:DrawMaterial(x, y, size, material, {outline = options}) end
  if options == nil then options = {} end
  local poly = self:CreateSquare(x, y, size)
  if options.outline then
    poly:Outline(options.outlineWidth, options.outlineColor, material)
  end
  poly:Fill(options.color, material)
end

function DT_Core.DrawContext.__index:GetTextSize(text, font)
  surface.SetFont(font or self:GetDefaultFont())
  local length, height = surface.GetTextSize(text)
  return self:ScreenToLocal(length), self:ScreenToLocal(height)
end

function DT_Core.DrawContext.__index:ShortenText(text, font, maxLength)
  while self:GetTextSize(text, font) > maxLength do
    text = string.Left(text, #text-1)
  end
  return text
end

function DT_Core.DrawContext.__index:DrawText(x, y, text, options)
  if isbool(options) then return self:DrawText(x, y, text, {outline = options}) end
  if options == nil then options = {} end
  local font = options.font or self:GetDefaultFont()
  local color = options.color or self:GetDefaultColor()
  local xAlign = options.xAlign or TEXT_ALIGN_LEFT
  local yAlign = options.yAlign or TEXT_ALIGN_TOP
  if options.maxLength then
    text = self:ShortenText(text, font, options.maxLength)
  end
  if options.outline then
    local outlineColor = options.outlineColor or self:GetDefaultOutlineColor()
    local outlineWidth = options.outlineWidth or self:GetDefaultOutlineWidth()
    return draw.SimpleTextOutlined(text, font, self:TranslateX(x), self:TranslateY(y), color, xAlign, yAlign, self:LocalToScreen(outlineWidth), outlineColor)
  else
    return draw.SimpleText(text, font, self:TranslateX(x), self:TranslateY(y), color, xAlign, yAlign)
  end
end