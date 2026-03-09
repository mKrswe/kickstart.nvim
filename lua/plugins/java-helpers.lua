return {
  'NickJAllen/java-helpers.nvim',
  ft = 'java',
  cmd = {
    'JavaHelpersNewFile',
    'JavaHelpersPickStackTraceLine',
    'JavaHelpersPickStackTrace',
    'JavaHelpersGoToStackTraceLine',
    'JavaHelpersGoUpStackTrace',
    'JavaHelpersGoDownStackTrace',
    'JavaHelpersGoToBottomOfStackTrace',
    'JavaHelpersGoToTopOfStackTrace',
    'JavaHelpersGoToNextStackTrace',
    'JavaHelpersGoToPrevStackTrace',
    'JavaHelpersSendStackTraceToQuickfix',
    'JavaHelpersDeobfuscate',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/snacks.nvim',
  },
  keys = {
    -- New Java types
    { '<leader>jn', ':JavaHelpersNewFile<cr>',          desc = '[J]ava [N]ew type (pick)' },
    { '<leader>jc', ':JavaHelpersNewFile Class<cr>',    desc = '[J]ava new [C]lass' },
    { '<leader>ji', ':JavaHelpersNewFile Interface<cr>', desc = '[J]ava new [I]nterface' },
    { '<leader>je', ':JavaHelpersNewFile Enum<cr>',     desc = '[J]ava new [E]num' },
    -- Stack trace navigation
    { '<leader>jg', ':JavaHelpersGoToStackTraceLine<cr>', desc = '[J]ava [G]o to stack trace line' },
    { '<leader>jp', ':JavaHelpersPickStackTraceLine<cr>', desc = '[J]ava [P]ick stack trace line' },
    { '[j',         ':JavaHelpersGoUpStackTrace<cr>',     desc = 'Stack trace up' },
    { ']j',         ':JavaHelpersGoDownStackTrace<cr>',   desc = 'Stack trace down' },
  },
  opts = {
    new_file = {
      java_source_dirs = { 'src/main/java', 'src/test/java', 'src' },
      should_format = true,
    },
  },
}
