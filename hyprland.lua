-- Bisaikō: float its 80x24 terminal beneath the pointer that opened it.
o.window("^org\\.omarchy\\.bisaiko$", {
  float = true,
  move = { "cursor_x-(window_w*0.5)", "cursor_y+20" },
  animation = "slide top",
})
