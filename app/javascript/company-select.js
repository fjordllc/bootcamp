import Choices from 'choices.js'

document.addEventListener('DOMContentLoaded', () => {
  return new Choices('#js-company-select', {
    removeItemButton: true,
    searchResultLimit: 10,
    searchPlaceholderValue: '検索ワード',
    noResultsText: '一致する情報は見つかりません',
    itemSelectText: '選択'
  })
})
