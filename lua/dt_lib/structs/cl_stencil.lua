--- Resets the stencil to known good.
function DT_Lib.ResetStencil()
  render.SetStencilWriteMask(0xFF)
  render.SetStencilTestMask(0xFF)
  render.SetStencilReferenceValue(0)
  render.SetStencilCompareFunction(STENCIL_ALWAYS)
  render.SetStencilPassOperation(STENCIL_KEEP)
  render.SetStencilFailOperation(STENCIL_KEEP)
  render.SetStencilZFailOperation(STENCIL_KEEP)
  render.ClearStencil()
end