local M = {}

M.templates = {
  research = {
    "# Research",
    "",
    "## Question and hypothesis",
    "",
    "## Sources",
    "",
    "| Source / DOI | Statement | Limitations |",
    "| --- | --- | --- |",
    "| | | |",
    "",
    "## Method",
    "",
    "## Reproducibility",
    "",
    "- Data and version:",
    "- Model / baseline:",
    "- Environment and commit:",
    "- Seed:",
    "- Metrics:",
    "",
    "## Results",
    "",
    "## Limitations and alternative explanations",
    "",
    "## Next experiment",
    "",
  },
  proof = {
    "# Statement",
    "",
    "## Definitions and assumptions",
    "",
    "$$",
    "",
    "$$",
    "",
    "## Examples and edge cases",
    "",
    "## Proof",
    "",
    "## Verification of steps",
    "",
    "## Corollaries",
    "",
    "## Sources",
    "",
  },
  video = {
    "# Video title",
    "",
    "## Audience and purpose",
    "",
    "## Main promise",
    "",
    "## First 15 seconds",
    "",
    "## Script",
    "",
    "| Time | Narration | Shot / demonstration |",
    "| --- | --- | --- |",
    "| 00:00 | | |",
    "",
    "## Sources and fact-checking",
    "",
    "## Recording",
    "",
    "- [ ] Audio",
    "- [ ] Screen and notifications",
    "- [ ] Demonstrations",
    "- [ ] B-roll",
    "",
    "## Publishing",
    "",
    "- [ ] Title and thumbnail",
    "- [ ] Description and links",
    "- [ ] Chapters and subtitles",
    "",
  },
  stream = {
    "# Stream outline",
    "",
    "## Topic and goal",
    "",
    "## Before going live",
    "",
    "- [ ] Microphone and recording",
    "- [ ] Scenes and screen capture",
    "- [ ] Notifications and personal data",
    "",
    "## Stream agenda",
    "",
    "| Time | Topic | Demonstration |",
    "| --- | --- | --- |",
    "| 00:00 | Introduction | |",
    "",
    "## Audience questions",
    "",
    "## Timestamps and clips",
    "",
    "## Summary and next stream",
    "",
  },
}

function M.template(kind)
  if not kind or kind == "" then
    vim.ui.select({ "research", "proof", "video", "stream" }, { prompt = "New note" }, function(choice)
      if choice then
        M.template(choice)
      end
    end)
    return
  end
  local lines = M.templates[kind]
  if not lines then
    vim.notify("Unknown template: " .. kind, vim.log.levels.WARN)
    return
  end
  vim.cmd.enew()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.deepcopy(lines))
  vim.bo.filetype = "markdown"
  vim.bo.swapfile = false
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

function M.stats()
  local count = vim.fn.wordcount()
  local words = count.visual_words or count.words
  local minutes = words / 150
  vim.notify(
    string.format(
      "%d words · %d characters · ~%.1f min at 150 words/min",
      words,
      count.visual_chars or count.chars,
      minutes
    ),
    vim.log.levels.INFO,
    { title = "Writing" }
  )
  return { words = words, characters = count.visual_chars or count.chars, minutes = minutes }
end

return M
