-- Bisaikō: float its 80x24 terminal beneath the pointer that opened it.
-- The helper clamps the final position to the active monitor after mapping.
o.window("^org\\.omarchy\\.bisaiko$", {
  float = true,
  move = { "cursor_x-(window_w*0.5)", "cursor_y+20" },
  animation = "popin 80%",
})
