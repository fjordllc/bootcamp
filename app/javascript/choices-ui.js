import Choices from 'choices.js'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('js-company-select')
  if (element) {
    return new Choices(element, {
      removeItemButton: true,
      allowHTML: true,
      searchResultLimit: 10,
      searchPlaceholderValue: '検索ワード',
      noResultsText: '一致する情報は見つかりません',
      itemSelectText: '選択'
    })
  }

  const elementMultipleSelect = document.getElementById(
    'js-choices-multiple-select'
  )
  if (elementMultipleSelect) {
    return new Choices(elementMultipleSelect, {
      removeItemButton: true,
      allowHTML: true,
      searchResultLimit: 6,
      searchPlaceholderValue: '検索ワード',
      noResultsText: '一致する情報は見つかりません',
      itemSelectText: '選択',
      shouldSort: false,
      resetScrollPosition: false,
      renderSelectedChoices: 'always'
    })
  }
})
