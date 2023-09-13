local STENCIL_LOCK = DT_Core.Lock("DT/Stencil")

-- Resets and locks the stencil for use
-- Don't forget to enable the stencil
function DT_Core.LockStencil(stencilFunc, ...)
  STENCIL_LOCK:Acquire()
  DT_Core.ResetStencil()
  stencilFunc(...)
  STENCIL_LOCK:Release()
end

-- Resets the stencil to known good
function DT_Core.ResetStencil()
  render.SetStencilWriteMask(0xFF)
  render.SetStencilTestMask(0xFF)
  render.SetStencilReferenceValue(0)
  render.SetStencilCompareFunction(STENCIL_ALWAYS)
  render.SetStencilPassOperation(STENCIL_KEEP)
  render.SetStencilFailOperation(STENCIL_KEEP)
  render.SetStencilZFailOperation(STENCIL_KEEP)
  render.ClearStencil()
end