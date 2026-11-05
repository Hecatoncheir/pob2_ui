-- Один и тот же анализатор и грамматика используются локально и в CI.
local analyzer_root, parser_path, files = unpack(_G.arg)
vim.opt.runtimepath:append(analyzer_root)
package.path = analyzer_root .. '/lua/?.lua;' .. analyzer_root .. '/lua/?/init.lua;' .. package.path
vim.treesitter.language.add('dart', { path = parser_path })
require('cyclomatic.config').setup({ nested_functions = 'inline' })
local analyzer = require('cyclomatic.analyzer')
assert(analyzer.get_query('dart'), 'Нет запросов анализатора Dart')
local results = {}
for file in io.lines(files) do
  local source = table.concat(vim.fn.readfile(file), '\n')
  local parser = vim.treesitter.get_string_parser(source, 'dart')
  assert(not parser:parse()[1]:root():has_error(), 'Ошибка грамматики: ' .. file)
  local analysis = assert(analyzer.analyze_string(source, 'dart'), 'Нет результата: ' .. file)
  for _, entry in ipairs(analysis.entries) do
    results[#results + 1] = {file = file, line = entry.row + 1, cognitive = entry.cognitive, cyclomatic = entry.cyclomatic, name = entry.name}
  end
end
io.stdout:write(vim.json.encode(results))
