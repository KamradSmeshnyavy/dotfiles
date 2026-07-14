# 通用工具函数：处理 y/N 确认输入
export def confirm_action [prompt: string] {
  let input = (input $prompt) | str lowercase | str trim
  return ($input in ["y", "yes"])
}
