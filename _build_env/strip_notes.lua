-- strip_notes.lua: drop reveal.js speaker notes (::: {.notes} blocks) from the
-- public render of a deck. The public site is what students see, and the site
-- search indexes the notes, so timing lines, cut orders, board-script pointers
-- and worked answers to the retrieval questions must not be in them.
--
-- The instructor's own render keeps the notes: set the environment variable
-- ST310_KEEP_NOTES to any value, e.g.
--
--   ST310_KEEP_NOTES=1 quarto render weeks/01-introduction-foundations/slides/01-1-introduction.qmd \
--       --output-dir instructor/_rendered/decks
--
-- (--output-dir keeps that render out of docs/). Referenced from each deck's
-- YAML as  filters: [../../../_build_env/strip_notes.lua].
-- Unchanged copy of the 25 September 2026 version, included so that this
-- folder renders on its own.

local keep = os.getenv("ST310_KEEP_NOTES")

function Div(el)
  if keep == nil and el.classes:includes("notes") then
    return {}
  end
  return nil
end

-- Time keeping (convenor, 19 October 2026). In the instructor's render, the speaker note of every slide
-- starts with one line, a progress bar: the share of the deck's estimated slide minutes completed before
-- this slide, e.g.  [########------------] 40%  32 of 80 min . The estimate is week 2's rough pace:
-- 2 minutes a light slide, 1 a dark (.inverse) slide. A slide can override it with an attribute on its
-- heading, e.g.  ## Has it converged? {minutes="3"} . A slide without a note gets one holding only the
-- bar. Computed at render time, so it follows the deck as it changes. Not run for the public render.

local function slide_minutes(h)
  local m = h.attributes["minutes"]
  if m ~= nil and tonumber(m) ~= nil then return tonumber(m) end
  if h.classes:includes("inverse") then return 1 end
  return 2
end

local function is_slide(b) return b.t == "Header" and b.level <= 2 end

function Pandoc(doc)
  if keep == nil then return nil end
  local blocks = doc.blocks
  local total = 0
  for _, b in ipairs(blocks) do if is_slide(b) then total = total + slide_minutes(b) end end
  if total == 0 then return nil end
  local width = 20
  local out = pandoc.List()
  local done = 0
  local i = 1
  while i <= #blocks do
    local b = blocks[i]
    out:insert(b)
    if is_slide(b) then
      local filled = math.floor(width * done / total + 0.5)
      local bar = "[" .. string.rep("#", filled) .. string.rep("-", width - filled) .. "]"
      local line = pandoc.Para({pandoc.Code(bar), pandoc.Space(),
        pandoc.Str(string.format("%d%%  %d of %d min", math.floor(100 * done / total + 0.5), done, total))})
      local nxt = blocks[i + 1]
      if nxt ~= nil and nxt.t == "Div" and nxt.classes:includes("notes") then
        nxt.content:insert(1, line)
        out:insert(nxt)
        i = i + 1
      else
        out:insert(pandoc.Div({line}, pandoc.Attr("", {"notes"})))
      end
      done = done + slide_minutes(b)
    end
    i = i + 1
  end
  doc.blocks = out
  return doc
end
