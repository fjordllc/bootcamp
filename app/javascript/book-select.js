import Choices from 'choices.js'

document.addEventListener('DOMContentLoaded', () => {
  const bookSelectCount = document.querySelectorAll('#js-book-select').length
  const elements = document.querySelectorAll('#js-book-select')
  for (let i = 0; i < bookSelectCount; i++) {
    // eslint-disable-next-line no-new
    new Choices(elements[i], {
      allowHTML: true,
      searchResultLimit: 20,
      searchPlaceholderValue: '検索ワード',
      noResultsText: '一致する情報は見つかりません',
      itemSelectText: '選択',
      shouldSort: false
    })
  }
  $('.books-form__add').on('cocoon:after-insert', () => {
    const elements = document.querySelectorAll('#js-book-select')
    const element = elements[elements.length - 1]
    if (element) {
      return new Choices(element, {
        allowHTML: true,
        searchResultLimit: 20,
        searchPlaceholderValue: '検索ワード',
        noResultsText: '一致する情報は見つかりません',
        itemSelectText: '選択',
        shouldSort: false
      })
    }
  })
})
