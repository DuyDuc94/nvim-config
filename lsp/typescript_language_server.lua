return {
  cmd = { "typescript-language-server", "--stdio" },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  filetypes = { "javascript", "typescript", "typescriptreact", "typescript.tsx" },
}
