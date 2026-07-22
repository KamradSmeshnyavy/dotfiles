vim.g.colors_name = "terminal-preview"
vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end

local C = {
  bg = "#0d0e1a",
  fg = "#dcd7e6",
  muted = "#4a4d6a",
  dark = "#151726",
  darker = "#0a0b14",
  selection = "#7dcea0",

  red = "#f1948a",
  green = "#7dcea0",
  yellow = "#f5cba7",
  cyan = "#8dd4cc",
  magenta = "#c9a0dc",
  white = "#ffffff",
}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

hl("Normal", { fg = C.fg, bg = C.bg })
hl("NormalNC", { fg = C.fg, bg = C.bg })
hl("NormalFloat", { fg = C.fg, bg = C.dark })
hl("FloatBorder", { fg = C.muted, bg = C.dark })
hl("Comment", { fg = C.muted, italic = true })
hl("NonText", { fg = C.muted })
hl("Whitespace", { fg = C.muted })
hl("EndOfBuffer", { fg = C.bg })
hl("Conceal", { fg = C.muted })

hl("Cursor", { fg = C.bg, bg = C.green })
hl("CursorLine", { bg = C.dark })
hl("CursorColumn", { bg = C.dark })
hl("CursorLineNr", { fg = C.green, bold = true })
hl("LineNr", { fg = C.muted })

hl("Visual", { bg = C.selection })
hl("VisualNOS", { bg = C.selection })
hl("Search", { fg = C.bg, bg = C.yellow })
hl("IncSearch", { fg = C.bg, bg = C.magenta })
hl("CurSearch", { link = "IncSearch" })
hl("MatchParen", { fg = C.bg, bg = C.cyan, bold = true })

hl("VertSplit", { fg = C.muted })
hl("WinSeparator", { fg = C.muted })
hl("WinBar", { fg = C.fg, bg = C.bg })
hl("WinBarNC", { fg = C.muted, bg = C.bg })

hl("StatusLine", { fg = C.fg, bg = C.dark })
hl("StatusLineNC", { fg = C.muted, bg = C.dark })
hl("StatusLineTerm", { fg = C.fg, bg = C.dark })
hl("StatusLineTermNC", { fg = C.muted, bg = C.dark })

hl("TabLine", { fg = C.fg, bg = C.muted })
hl("TabLineFill", { bg = C.darker })
hl("TabLineSel", { fg = C.bg, bg = C.white, bold = true })

hl("Pmenu", { fg = C.fg, bg = C.dark })
hl("PmenuSel", { fg = C.bg, bg = C.green })
hl("PmenuSbar", { bg = C.darker })
hl("PmenuThumb", { bg = C.muted })

hl("WildMenu", { fg = C.bg, bg = C.green })

hl("Title", { fg = C.cyan, bold = true })
hl("Directory", { fg = C.green })

hl("ErrorMsg", { fg = C.red, bold = true })
hl("WarningMsg", { fg = C.yellow, bold = true })
hl("MoreMsg", { fg = C.cyan })
hl("Question", { fg = C.cyan })
hl("ModeMsg", { fg = C.fg })

hl("SpellBad", { undercurl = true, sp = C.red })
hl("SpellCap", { undercurl = true, sp = C.yellow })
hl("SpellLocal", { undercurl = true, sp = C.cyan })
hl("SpellRare", { undercurl = true, sp = C.magenta })

hl("Constant", { fg = C.magenta })
hl("String", { fg = C.green })
hl("Character", { fg = C.green })
hl("Number", { fg = C.cyan })
hl("Float", { fg = C.cyan })
hl("Boolean", { fg = C.cyan, bold = true })

hl("Identifier", { fg = C.fg })
hl("Function", { fg = C.yellow, bold = true })

hl("Statement", { fg = C.magenta, bold = true })
hl("Conditional", { fg = C.magenta })
hl("Repeat", { fg = C.magenta })
hl("Label", { fg = C.magenta })
hl("Keyword", { fg = C.magenta, bold = true })
hl("Operator", { fg = C.yellow })
hl("Exception", { fg = C.red })

hl("Type", { fg = C.cyan, italic = true })
hl("StorageClass", { fg = C.red })
hl("Structure", { fg = C.cyan })
hl("Typedef", { fg = C.cyan })

hl("PreProc", { fg = C.cyan })
hl("Include", { fg = C.green })
hl("Define", { fg = C.green })
hl("Macro", { fg = C.yellow })
hl("PreCondit", { fg = C.cyan })

hl("Special", { fg = C.yellow })
hl("SpecialChar", { fg = C.yellow })
hl("Tag", { fg = C.green })
hl("Delimiter", { fg = C.fg })
hl("SpecialComment", { fg = C.muted })
hl("Debug", { fg = C.red })

hl("Underlined", { underline = true, sp = C.cyan })
hl("Ignore", { fg = C.muted })
hl("Error", { fg = C.red })
hl("Todo", { fg = C.bg, bg = C.yellow, bold = true })

hl("DiffAdd", { fg = C.green, bg = C.dark })
hl("DiffChange", { fg = C.yellow, bg = C.dark })
hl("DiffDelete", { fg = C.red, bg = C.dark })
hl("DiffText", { fg = C.cyan, bg = C.dark })

hl("DiagnosticError", { fg = C.red })
hl("DiagnosticWarn", { fg = C.yellow })
hl("DiagnosticInfo", { fg = C.cyan })
hl("DiagnosticHint", { fg = C.muted })
hl("DiagnosticOk", { fg = C.green })
hl("DiagnosticUnderlineError", { undercurl = true, sp = C.red })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = C.yellow })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = C.cyan })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = C.muted })
hl("DiagnosticUnderlineOk", { undercurl = true, sp = C.green })

hl("DiagnosticVirtualTextError", { fg = C.red, bg = C.dark })
hl("DiagnosticVirtualTextWarn", { fg = C.yellow, bg = C.dark })
hl("DiagnosticVirtualTextInfo", { fg = C.cyan, bg = C.dark })
hl("DiagnosticVirtualTextHint", { fg = C.muted, bg = C.dark })
hl("DiagnosticVirtualTextOk", { fg = C.green, bg = C.dark })

hl("@error", { fg = C.red })
hl("@comment", { link = "Comment" })
hl("@none", { fg = C.fg })

hl("@string", { link = "String" })
hl("@string.regex", { fg = C.cyan })
hl("@string.escape", { fg = C.yellow })

hl("@number", { link = "Number" })
hl("@float", { link = "Float" })
hl("@boolean", { link = "Boolean" })

hl("@constant", { link = "Constant" })
hl("@constant.builtin", { fg = C.cyan, bold = true })
hl("@constant.macro", { link = "Macro" })

hl("@function", { link = "Function" })
hl("@function.builtin", { fg = C.magenta, bold = true })
hl("@function.call", { link = "Function" })
hl("@function.macro", { link = "Macro" })
hl("@method", { link = "Function" })
hl("@method.call", { link = "Function" })
hl("@constructor", { fg = C.yellow })

hl("@keyword", { link = "Keyword" })
hl("@keyword.function", { link = "Keyword" })
hl("@keyword.operator", { link = "Operator" })
hl("@keyword.return", { fg = C.magenta })
hl("@keyword.repeat", { link = "Repeat" })
hl("@keyword.conditional", { link = "Conditional" })
hl("@keyword.exception", { link = "Exception" })
hl("@keyword.debug", { link = "Debug" })
hl("@keyword.directive", { link = "PreProc" })
hl("@keyword.directive.define", { link = "Define" })

hl("@type", { link = "Type" })
hl("@type.builtin", { fg = C.yellow, bold = true })
hl("@type.definition", { link = "Typedef" })
hl("@type.qualifier", { link = "Type" })

hl("@variable", { fg = C.fg })
hl("@variable.builtin", { fg = C.red, italic = true })
hl("@variable.member", { fg = C.fg })
hl("@variable.parameter", { fg = C.yellow, italic = true })

hl("@label", { link = "Label" })

hl("@punctuation.delimiter", { link = "Delimiter" })
hl("@punctuation.bracket", { link = "Delimiter" })
hl("@punctuation.special", { fg = C.yellow, bold = true })

hl("@operator", { link = "Operator" })
hl("@attribute", { fg = C.cyan })
hl("@property", { fg = C.cyan })
hl("@field", { fg = C.cyan })
hl("@include", { link = "Include" })

hl("@tag", { fg = C.green })
hl("@tag.attribute", { fg = C.cyan })
hl("@tag.delimiter", { fg = C.muted })

hl("@markup.heading", { fg = C.cyan, bold = true })
hl("@markup.italic", { italic = true })
hl("@markup.bold", { bold = true })
hl("@markup.strikethrough", { strikethrough = true })
hl("@markup.underline", { underline = true })
hl("@markup.link", { fg = C.cyan, underline = true })
hl("@markup.link.url", { fg = C.cyan, underline = true })
hl("@markup.link.label", { fg = C.green })
hl("@markup.list", { fg = C.magenta })
hl("@markup.quote", { fg = C.muted })
hl("@markup.raw", { fg = C.green })
hl("@markup.math", { fg = C.cyan })

hl("@lsp.type.class", { link = "Type" })
hl("@lsp.type.comment", { link = "Comment" })
hl("@lsp.type.decorator", { link = "@attribute" })
hl("@lsp.type.enum", { link = "Type" })
hl("@lsp.type.enumMember", { fg = C.cyan })
hl("@lsp.type.function", { link = "Function" })
hl("@lsp.type.interface", { link = "Type" })
hl("@lsp.type.keyword", { link = "Keyword" })
hl("@lsp.type.macro", { link = "Macro" })
hl("@lsp.type.method", { link = "Function" })
hl("@lsp.type.namespace", { fg = C.cyan })
hl("@lsp.type.parameter", { fg = C.yellow, italic = true })
hl("@lsp.type.property", { fg = C.cyan })
hl("@lsp.type.struct", { link = "Structure" })
hl("@lsp.type.type", { link = "Type" })
hl("@lsp.type.typeParameter", { fg = C.yellow, italic = true })
hl("@lsp.type.variable", { link = "@variable" })

hl("@lsp.typemod.class.defaultLibrary", { bold = true })
hl("@lsp.typemod.enum.defaultLibrary", { bold = true })
hl("@lsp.typemod.enumMember.defaultLibrary", { fg = C.cyan, bold = true })
hl("@lsp.typemod.function.defaultLibrary", { bold = true })
hl("@lsp.typemod.keyword.async", { link = "Keyword" })
hl("@lsp.typemod.macro.defaultLibrary", { bold = true })
hl("@lsp.typemod.method.defaultLibrary", { bold = true })
hl("@lsp.typemod.operator.injected", { link = "Operator" })
hl("@lsp.typemod.string.injected", { link = "String" })
hl("@lsp.typemod.type.defaultLibrary", { bold = true })
hl("@lsp.typemod.variable.callable", { fg = C.yellow, bold = true })
hl("@lsp.typemod.variable.defaultLibrary", { bold = true })
hl("@lsp.typemod.variable.global", { bold = true })
hl("@lsp.typemod.variable.injected", { link = "@variable" })
hl("@lsp.typemod.variable.static", { bold = true })
