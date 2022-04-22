local module = {}
module.SymbolKind = {
  File = 1,
  Module = 2,
  Namespace = 3,
  Package = 4,
  Class = 5,
  Method = 6,
  Property = 7,
  Field = 8,
  Constructor = 9,
  Enum = 10,
  Interface = 11,
  Function = 12,
  Variable = 13,
  Constant = 14,
  String = 15,
  Number = 16,
  Boolean = 17,
  Array = 18,
  Object = 19,
  Key = 20,
  Null = 21,
  EnumMember = 22,
  Struct = 23,
  Event = 24,
  Operator = 25,
  TypeParameter = 26
}
local function tbl_push(arr, ...)
  for _, v in ipairs {...} do table.insert(arr, v) end
  return #arr
end
local function tbl_unshift(arr, ...)
  local arr2 = {...}
  for i = #arr2, 1, -1 do table.insert(arr, 1, arr2[i]) end
  return #arr
end
function pos_to_index(line, col)
  local ret = 0
  for i = 1, line - 1, 1 do
    local l = vim.fn.getline(i)
    if(l == '')then l = ' ' end
    ret = ret + (#l)
  end
  ret = ret + col
  return ret
end
module.go = function(kind, direction, position)
  local handler = function(err, result, ctx, config)
    print('result is', vim.inspect(result), 'that is result')
    local ret = {}
    local stack = {unpack(result)}

    local c = [[
    local min_range = {s = 0, e = math.huge}
    local min_range_symbol = nil
    local cursor = pos_to_index(unpack(vim.api.nvim_win_get_cursor(0)))
    while (#stack ~= 0) do
      local symbol = table.remove(stack, 1)
      if (symbol.kind == kind) then 
        local tmp1, tmp2 = symbol.range.start, symbol.range['end']
        local s, e = pos_to_index(tmp1.line + 1, tmp1.character), pos_to_index(tmp2.line, tmp2.character - 1)
        if(cursor >= s and cursor <= e and s >= min_range.s and e <= min_range.e) then
          min_range_symbol = symbol
          min_range = {s = s, e = e}
        end
      end
      local tmp = symbol.children or {}
      tbl_unshift(stack, unpack(tmp))
    end
    if(min_range_symbol) then
      min_range_symbol.children = nil
    end
    ]]

    stack = {unpack(result)}
    while (#stack ~= 0) do
      local symbol = table.remove(stack, 1)
      if (symbol.kind == kind) then tbl_push(ret, symbol) end
      local tmp = symbol.children or {}
      tbl_unshift(stack, unpack(tmp))
      symbol.children = nil
    end
    local sys = vim.tbl_map(function(item)
      if (position == 'start') then
        return item.range.start
      else
        local tmp = item.range['end']
        tmp.character = tmp.character - 1
        return tmp
      end
    end, ret)
    local index = 0
    local distance = math.huge
    for i, v in ipairs(sys) do
      local x1 = pos_to_index(v.line + 1, v.character)
      local o = pos_to_index(unpack(vim.api.nvim_win_get_cursor(0)))
      -- print(x1, o)
      local x = x1 - o
      if (((direction == 'next' and x > 0) or (direction == 'prev' and x < 0)) and
          math.abs(x) < distance) then
        distance = math.abs(x)
        index = i
      end
    end
    if (index ~= 0) then
      local tmp = sys[index]
      vim.api.nvim_win_set_cursor(0, {tmp.line + 1, tmp.character})
    end
  end
  local textDocument = vim.lsp.util.make_text_document_params()
  vim.lsp.buf_request(0, 'textDocument/documentSymbol',
                      {textDocument = textDocument}, handler)

end
module.next = function(kind, position) module.go(kind, 'next', position) end
module.prev = function(kind, position) module.go(kind, 'prev', position) end
return module
