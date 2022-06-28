import Choices from 'choices.js'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('js-book-select')
  if (element) {
    return new Choices('#js-book-select', {
      removeItemButton: true,
      allowHTML: true,
      searchResultLimit: 10,
      searchPlaceholderValue: '検索ワード',
      noResultsText: '一致する情報は見つかりません',
      itemSelectText: '本を選んでください',
      shouldSort: false
    })
  }
})
