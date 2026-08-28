-- Bisaikō: float its 80x24 terminal beneath the pointer that opened it.
o.window("^org\\.omarchy\\.bisaiko$", {
  float = true,
  move = { "monitor_w-window_w-8", "cursor_y+20" },
  animation = "slide top",
})
