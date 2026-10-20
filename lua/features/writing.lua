local M = {}

M.templates = {
  research = {
    "# Исследование",
    "",
    "## Вопрос и гипотеза",
    "",
    "## Источники",
    "",
    "| Источник / DOI | Утверждение | Ограничения |",
    "| --- | --- | --- |",
    "| | | |",
    "",
    "## Метод",
    "",
    "## Воспроизводимость",
    "",
    "- Данные и версия:",
    "- Модель / baseline:",
    "- Окружение и commit:",
    "- Seed:",
    "- Метрики:",
    "",
    "## Результаты",
    "",
    "## Ограничения и альтернативные объяснения",
    "",
    "## Следующий эксперимент",
    "",
  },
  proof = {
    "# Утверждение",
    "",
    "## Определения и предпосылки",
    "",
    "$$",
    "",
    "$$",
    "",
    "## Примеры и граничные случаи",
    "",
    "## Доказательство",
    "",
    "## Проверка шагов",
    "",
    "## Следствия",
    "",
    "## Источники",
    "",
  },
  video = {
    "# Название видео",
    "",
    "## Для кого и зачем",
    "",
    "## Главное обещание",
    "",
    "## Первые 15 секунд",
    "",
    "## Сценарий",
    "",
    "| Время | Речь | Кадр / демонстрация |",
    "| --- | --- | --- |",
    "| 00:00 | | |",
    "",
    "## Источники и проверка фактов",
    "",
    "## Съёмка",
    "",
    "- [ ] Звук",
    "- [ ] Экран и уведомления",
    "- [ ] Демонстрации",
    "- [ ] Дополнительные кадры",
    "",
    "## Публикация",
    "",
    "- [ ] Заголовок и обложка",
    "- [ ] Описание и ссылки",
    "- [ ] Главы и субтитры",
    "",
  },
  stream = {
    "# План стрима",
    "",
    "## Тема и цель",
    "",
    "## Перед эфиром",
    "",
    "- [ ] Микрофон и запись",
    "- [ ] Сцены и захват экрана",
    "- [ ] Уведомления и личные данные",
    "",
    "## План эфира",
    "",
    "| Время | Тема | Демонстрация |",
    "| --- | --- | --- |",
    "| 00:00 | Вступление | |",
    "",
    "## Вопросы зрителей",
    "",
    "## Таймкоды и клипы",
    "",
    "## Итоги и следующий эфир",
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
