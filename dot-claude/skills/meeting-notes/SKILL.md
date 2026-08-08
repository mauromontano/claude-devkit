---
name: meeting-notes
description: Turn a Google Meet transcript (or Gemini "take notes" output) into a self-contained, well-organized HTML document — TL;DR, decisions, action items, open questions, risks. Handles one meeting or a combined daily digest. Activates on meeting notes, meeting minutes, transcript, "notes from your meeting", or a daily meeting digest. Driven by the /meeting command.
---

# meeting-notes

Extract the signal from a meeting transcript into a fixed, skimmable structure and render
it as a **self-contained HTML** document (archify-styled: dark/light toggle, no external
dependencies, print-friendly). Works for a **single meeting** or a **daily digest** that
merges several transcripts from one day.

The `/meeting` command is the entry point; this skill holds the reusable machinery.

## Flow

1. **Locate the transcript(s).** See `references/sources.md`. Preferred path is Gmail via
   the user's logged-in browser (Meet emails a *link to a Google Doc*, not raw text);
   always fall back to pasted text or a local file path.
2. **Extract.** Apply the rubric in `references/extraction.md` to fill the fixed sections.
   For a digest, extract each meeting, then merge and de-duplicate the action items.
3. **Render.** Fill `assets/template.html` (single or digest layout) and save to the
   resolved output dir: **Google Drive "Meet Recordings"** folder if Drive Desktop is
   installed and synced (`~/Library/CloudStorage/GoogleDrive-*/…/Meet Recordings/`),
   otherwise `~/meeting-notes/`. Path: `<base>/<YYYY-MM-DD>/<slug>.html` (digest:
   `digest.html`). See the `/meeting` command step 4 for the exact resolution logic.

## The template

`assets/template.html` is a self-contained page with two layouts inside it, marked by HTML
comments:

- `<!-- MEETING:SINGLE_START -->` … `<!-- MEETING:SINGLE_END -->` — one meeting.
- `<!-- MEETING:DIGEST_START -->` … `<!-- MEETING:DIGEST_END -->` — the daily digest:
  a merged action-items table at the top, then one collapsible section per meeting.

Keep whichever layout you need, delete the other, and replace the `[[PLACEHOLDER]]` tokens.
Do **not** add external `<script>`/`<link>`/font/image URLs — the page must open offline.
The theme toggle, CSS variables, and print styles are already wired; leave them intact.

## Fixed sections (edit here to change the default template)

Metadata (title · date · attendees · duration) → **TL;DR** (3–5 bullets) → **Key decisions**
→ **Action items** (table: item · owner · due · status) → **Open questions** → **Risks &
blockers** → **Topics discussed** → **Notable quotes** → **Links & resources**.

Every section renders even when empty — show an explicit "None captured" so the reader
knows it was considered, not skipped.
