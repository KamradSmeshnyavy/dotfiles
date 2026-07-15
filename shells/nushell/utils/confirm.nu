export def confirm_action [prompt: string] {
  let input = (input $prompt) | str lowercase | str trim
  return ($input in ["y", "yes"])
}
