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
