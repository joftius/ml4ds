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
-- starts with one line, "Estimated time elapsed: E min, time remaining: R min": E is the estimate at the
-- start of the slide, R is the lecture length minus E. The estimate is week 2's rough pace: 2 minutes a
-- light slide, 1 a dark (.inverse) slide. A slide can override it with an attribute on its heading,
-- e.g.  ## Has it converged? {minutes="3"} . The lecture length is 90 minutes unless the deck's YAML
-- sets  st310-lecture-minutes: N . A slide without a note gets one holding only the line. Computed at
-- render time, so the numbers follow the deck as it changes. Not run for the public render (no notes).

local function slide_minutes(h)
  local m = h.attributes["minutes"]
  if m ~= nil and tonumber(m) ~= nil then return tonumber(m) end
  if h.classes:includes("inverse") then return 1 end
  return 2
end

function Pandoc(doc)
  if keep == nil then return nil end
  local total = 90
  local meta_total = doc.meta["st310-lecture-minutes"]
  if meta_total ~= nil and tonumber(pandoc.utils.stringify(meta_total)) ~= nil then
    total = tonumber(pandoc.utils.stringify(meta_total))
  end
  local blocks = doc.blocks
  local out = pandoc.List()
  local elapsed = 0
  local i = 1
  while i <= #blocks do
    local b = blocks[i]
    out:insert(b)
    if b.t == "Header" and b.level <= 2 then
      local line = pandoc.Para({pandoc.Str(string.format(
        "Estimated time elapsed: %d min, time remaining: %d min", elapsed, total - elapsed))})
      local nxt = blocks[i + 1]
      if nxt ~= nil and nxt.t == "Div" and nxt.classes:includes("notes") then
        nxt.content:insert(1, line)
        out:insert(nxt)
        i = i + 1
      else
        out:insert(pandoc.Div({line}, pandoc.Attr("", {"notes"})))
      end
      elapsed = elapsed + slide_minutes(b)
    end
    i = i + 1
  end
  doc.blocks = out
  return doc
end
