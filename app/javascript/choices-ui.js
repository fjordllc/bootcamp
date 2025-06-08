import Choices from 'choices.js'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('js-choices-single-select')
  if (element) {
    return new Choices(element, {
      removeItemButton: true,
      allowHTML: true,
      searchResultLimit: 20,
      searchPlaceholderValue: '検索ワード',
      noResultsText: '一致する情報は見つかりません',
      itemSelectText: '選択',
      shouldSort: false
    })
  }

  const elementMultipleSelect = document.getElementById(
    'js-choices-multiple-select'
  )
  if (elementMultipleSelect) {
    return new Choices(elementMultipleSelect, {
      removeItemButton: true,
      allowHTML: true,
      searchResultLimit: 20,
      searchPlaceholderValue: '検索ワード',
      noResultsText: '一致する情報は見つかりません',
      itemSelectText: '選択',
      shouldSort: false,
      resetScrollPosition: false,
      renderSelectedChoices: 'always'
    })
  }

  const elementsOfSingles = document.querySelectorAll('.js-choices-singles')
  if (elementsOfSingles.length > 0) {
    for (const element of elementsOfSingles) {
      // eslint-disable-next-line no-new
      new Choices(element, {
        removeItemButton: true,
        allowHTML: true,
        searchResultLimit: 20,
        searchPlaceholderValue: '検索ワード',
        noResultsText: '一致する情報は見つかりません',
        itemSelectText: '選択',
        shouldSort: false
      })
    }
  }

  const elements = document.querySelectorAll('.js-choices-added-select')
  const elementsCount = elements.length
  if (!elements) return
  for (let i = 0; i < elementsCount; i++) {
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
  $('.js-add-choice').on('cocooned:after-insert', () => {
    const elements = document.querySelectorAll('.js-choices-added-select')
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
