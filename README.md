<div align="center">

# snacks-luasnip.nvim

</div>

This is basically a 1:1 port of [telescope-luasnip.nvim](https://github.com/benfowler/telescope-luasnip.nvim) to the [snacks.nvim](https://github.com/folke/snacks.nvim) with some QoL enhancements.

## 📦 Installation

### lazy.nvim

```lua
{
  "Neurarian/snacks-luasnip.nvim",
  dependencies = {
  "folke/snacks.nvim",
  "L3MON4D3/LuaSnip",
},
  keys = {
    { "<leader>sc", function() require("snacks-luasnip").pick() end, desc = "Search Code Snippets" },
  },
}
```

## 🚀 Basic Usage

```lua
-- Direct function call
require("snacks-luasnip").pick()
```

## 🔧 Requirements

- [snacks.nvim](https://github.com/folke/snacks.nvim)
- [LuaSnip](https://github.com/L3MON4D3/LuaSnip)
- Neovim (duh)

## 📝 Notes

- Snippets need to be loaded before the picker can display them
- If no snippets appear, try entering insert mode first to trigger snippet loading

## 🙏 Credits

[telescope-luasnip.nvim](https://github.com/benfowler/telescope-luasnip.nvim).
