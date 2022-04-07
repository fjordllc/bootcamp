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
})
