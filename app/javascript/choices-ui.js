import Choices from 'choices.js'

function initializeChoices() {
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

  const addChoiceButtons = document.querySelectorAll('.js-add-choice')
  addChoiceButtons.forEach((button) => {
    button.addEventListener('cocooned:after-insert', () => {
      const elements = document.querySelectorAll('.js-choices-added-select')
      if (!elements) return
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
}

// Initialize on different events for Rails 7.2 compatibility
document.addEventListener('DOMContentLoaded', initializeChoices)
document.addEventListener('turbo:load', initializeChoices)
document.addEventListener('turbo:frame-load', initializeChoices)
// For older Turbolinks compatibility
document.addEventListener('turbolinks:load', initializeChoices)
