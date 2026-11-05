# Procs

[🇷🇺 Русский](procs.ru.md)

A modern `ps` replacement written in Rust.

## Paths

- **In the repo:** `tui/procs`
- **Linked to:** `~/.config/procs`

## What differs from the defaults

- **Columns:** Pid, UsageCpu, UsageMem, VmSize, VmRss, Slot, CpuTime, StartTime, Command, TcpPort, separated by
  `Separator`.
- **Style:** column colours (`BrightYellow|Yellow` for PID, `BrightCyan|Cyan` for CpuTime and TcpPort,
  `BrightMagenta|Magenta` for StartTime), green-yellow-red gradients for state and usage, tree symbols
  `│ ─ ┬ ├ └`.
- **Search:** numbers — `Exact`, text — `Partial`, combined with `And`.
- **Docker:** containers via `/var/run/docker.sock`.
