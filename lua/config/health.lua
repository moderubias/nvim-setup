local M = {}

function M.check()
  vim.health.start("Neovim configuration")
  if vim.fn.has("nvim-0.12") == 1 then
    vim.health.ok("Neovim 0.12+")
  else
    vim.health.error("Neovim 0.12+ is required")
  end
  for _, group in ipairs({
    { "Core", "git", "rg", "fd" },
    { "Parser builds", "cc", "make", "curl", "tar", "tree-sitter" },
    { "Rust", "cargo", "rust-analyzer", "codelldb" },
    { "Python", "python3", "pyright-langserver", "ruff" },
    { "Web", "node", "npm", "astro-ls", "typescript-language-server", "prettier" },
    { "Writing", "latexmk", "xelatex", "texlab", "zathura", "latexindent", "glow" },
    { "Notebooks", "jupyter" },
  }) do
    vim.health.start(group[1])
    for i = 2, #group do
      local path = vim.fn.exepath(group[i])
      local mason = vim.fn.stdpath("data") .. "/mason/bin/" .. group[i]
      if vim.fn.executable(mason) == 1 then
        path = mason
      end
      if path ~= "" then
        vim.health.ok(group[i] .. ": " .. path)
      else
        vim.health.warn(group[i] .. " is missing", { "Install it with Mason or your system/project package manager." })
      end
    end
  end
  vim.health.start("Project environment")
  vim.health.info("Python: " .. require("languages.python").executable())
  vim.health.info(
    "Notebook provider: :checkhealth vim.provider; Molten needs pynvim, jupyter_client and a registered kernel."
  )
  vim.health.info("Astro formatting needs prettier and prettier-plugin-astro in the project.")
end

return M
