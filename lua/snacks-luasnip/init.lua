-- Basically a 1:1 port of telescope-luasnip to the Snacks picker with some enhancements

local M = {}

local filter_null = function(str, default)
  return str and str or (default and default or '')
end

local filter_description = function(name, description)
  local result = ''
  if description and #description > 1 then
    for _, line in ipairs(description) do
      result = result .. line .. ' '
    end
  elseif name and description and description[1] ~= name then
    result = description[1]
  end
  return result
end

local get_docstring = function(luasnip, ft, context)
  local docstring = {}
  if context then
    local snips_for_ft = luasnip.get_snippets(ft)
    if snips_for_ft then
      for _, snippet in pairs(snips_for_ft) do
        if context.name == snippet.name and context.trigger == snippet.trigger then
          local raw_docstring = snippet:get_docstring()
          if type(raw_docstring) == 'string' then
            for chunk in string.gmatch(snippet:get_docstring(), '[^\n]+') do
              docstring[#docstring + 1] = chunk
            end
          else
            docstring = raw_docstring
          end
        end
      end
    end
  end
  return docstring
end

local function get_filetype_priority(ft, current_ft)
  if ft == current_ft then
    return 1
  elseif ft == '' or ft == '-' then
    return 3
  else
    return 2
  end
end

function M.pick(opts)
  opts = opts or {}

  -- Dependency checks
  local has_snacks, snacks = pcall(require, 'snacks')
  if not has_snacks then
    vim.notify('snacks.nvim is required for snacks-luasnip.nvim', vim.log.levels.ERROR)
    return
  end

  local has_luasnip, luasnip = pcall(require, 'luasnip')
  if not has_luasnip then
    vim.notify('LuaSnip is not available', vim.log.levels.ERROR)
    return
  end

  local available = luasnip.available()
  local items = {}
  local current_ft = vim.bo.filetype

  for filename, file in pairs(available) do
    for i, snippet in ipairs(file) do
      local ft = filename == '' and '-' or filename
      local display_ft = ft == '-' and 'all' or ft

      local icon, icon_hl = snacks.util.icon(display_ft, 'filetype')

      local search_text = filter_null(snippet.trigger)
        .. ' '
        .. filter_null(snippet.name)
        .. ' '
        .. ft
        .. ' '
        .. filter_description(snippet.name, snippet.description)

      local priority = get_filetype_priority(ft, current_ft)

      table.insert(items, {
        idx = #items + 1,
        score = #items + 1,
        text = search_text,
        ft = ft,
        display_ft = display_ft,
        name = snippet.name,
        trigger = snippet.trigger,
        description = snippet.description,
        context = snippet,
        icon = icon,
        icon_hl = icon_hl,
        ft_priority = priority,
      })
    end
  end

  -- Sort items by filetype priority, then by name, then by trigger
  table.sort(items, function(a, b)
    if a.ft_priority ~= b.ft_priority then
      return a.ft_priority < b.ft_priority
    elseif a.ft ~= b.ft then
      return a.ft < b.ft
    elseif a.name ~= b.name then
      return a.name < b.name
    else
      return a.trigger < b.trigger
    end
  end)

  for i, item in ipairs(items) do
    item.idx = i
    item.score = i
  end

  return snacks.picker.pick(vim.tbl_deep_extend('force', {
    source = 'luasnip',
    title = 'LuaSnip Snippets',

    items = items,

    format = function(item)
      local description = filter_description(item.name, item.description)
      return {
        { item.icon .. '  ', item.icon_hl },
        { string.format('%-6s', item.display_ft) .. ' ', 'SnacksPickerDirectory' },
        { string.format('%-24s', item.name or '') .. ' ', 'SnacksPickerFile' },
        { description, 'SnacksPickerComment' },
      }
    end,

    preview = function(ctx)
      if not ctx.item then
        return false
      end

      local snippet_lines = get_docstring(luasnip, ctx.item.ft, ctx.item.context)
      if vim.tbl_isempty(snippet_lines) then
        snippet_lines = { 'No preview available' }
      end

      ctx.preview:reset()
      ctx.preview:set_lines(snippet_lines)

      if ctx.item.ft and ctx.item.ft ~= '-' then
        ctx.preview:highlight({ ft = ctx.item.ft })
      end

      return true
    end,

    layout = {
      preview = { minimal = true },
    },

    confirm = function(picker, item)
      if not item then
        return
      end

      picker:close()

      local snippets_to_expand = {}
      luasnip.available(function(snippet)
        if snippet.trigger == item.context.trigger and snippet.name == item.context.name then
          table.insert(snippets_to_expand, snippet)
        end
        return nil
      end)

      if #snippets_to_expand > 0 then
        vim.cmd('startinsert!')
        vim.defer_fn(function()
          luasnip.snip_expand(snippets_to_expand[1])
        end, 50)
      else
        vim.notify(
          "Snippet '" .. item.name .. "' was selected, but there are no snippets to expand!",
          vim.log.levels.ERROR
        )
      end
    end,

    matcher = {
      fuzzy = true,
      smartcase = true,
      ignorecase = true,
    },
  }, opts))
end

return M
