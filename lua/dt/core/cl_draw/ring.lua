DT_Core.DrawRing = DT_Core.CreateStruct()

local WHITE = Color(255, 255, 255)

function DT_Core.DrawContext.__index:CreateRing(x, y, outerRadius, innerRadius, lines, angle)
  local ring = DT_Core.DrawRing.__raw()
  ring.__OuterCircle = self:CreateCircle(x, y, outerRadius, lines, angle)
  ring.__InnerCircle = self:CreateCircle(x, y, innerRadius, lines, angle)
  return ring
end

-- Draws the outlines of this ring
function DT_Core.DrawRing.__index:Stroke(color)
  self.__OuterCircle:Stroke(color)
  self.__InnerCircle:Stroke(color)
  return self
end

-- Draws the inside of this ring
function DT_Core.DrawRing.__index:Fill(color, material)
  DT_Core.LockStencil(function()
    render.SetStencilEnable(true)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCILOPERATION_INCR)
    self.InnerCircle:Fill(WHITE)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    self.OuterCircle:Fill(color, material)
    render.SetStencilEnable(false)
  end)
  return self
end

-- Draws a blur effect on this ring
function DT_Core.DrawRing.__index:Blur(passes)
  DT_Core.LockStencil(function()
    render.SetStencilEnable(true)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCILOPERATION_INCR)
    self.InnerCircle:Fill(WHITE)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    self.OuterCircle:Blur(passes)
    render.SetStencilEnable(false)
  end)
  return self
end