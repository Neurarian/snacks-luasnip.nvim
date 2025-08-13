<div align="center">

# snacks-luasnip.nvim

<img width="1535" height="481" alt="2025-08-13T21:18:45,803470792+02:00" src="https://github.com/user-attachments/assets/fa549dbf-622c-478b-b33c-43f81719c5e8" />

</div>

---

This is basically a 1:1 port of [telescope-luasnip.nvim](https://github.com/benfowler/telescope-luasnip.nvim) to the [snacks.nvim](https://github.com/folke/snacks.nvim) picker with some QoL enhancements.

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
