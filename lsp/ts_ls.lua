---@type vim.lsp.Config
return {
  cmd = { 'typescript-language-server', '--stdio' },
  init_options = {
    tsserver = {
      fallbackPath = vim.fn.expand('~/.local/lib/node_modules/typescript/lib'),
    },
  },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      'tsconfig.json',
      'jsconfig.json',
      'package.json',
      'package-lock.json',
      'yarn.lock',
      'pnpm-lock.yaml',
      'bun.lockb',
      'bun.lock',
      '.git',
    }) or vim.fn.getcwd()

    -- Prefer tsgo when either a project-local or global binary is available.
    local local_tsgo = vim.fs.joinpath(root, 'node_modules/.bin', 'tsgo')
    if vim.fn.executable('tsgo') == 1 or vim.fn.executable(local_tsgo) == 1 then
      return
    end

    on_dir(root)
  end,
}
