-- Properly set the file type for ocaml interface files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.templ",
  desc = "Detect and set the proper file type for templ files",
  callback = function()
    vim.cmd(":set filetype=templ")
  end,
})
