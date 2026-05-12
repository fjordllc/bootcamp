import Choices from 'choices.js'

const choiceOptions = {
  removeItemButton: true,
  allowHTML: true,
  searchResultLimit: 20,
  searchPlaceholderValue: '検索ワード',
  noResultsText: '一致する情報は見つかりません',
  itemSelectText: '選択',
  shouldSort: false
}

document.addEventListener('DOMContentLoaded', () => {
  const element = document.getElementById('js-choices-single-select')
  if (element) {
    // eslint-disable-next-line no-new
    new Choices(element, choiceOptions)
  }

  const elementMultipleSelect = document.getElementById(
    'js-choices-multiple-select'
  )
  if (elementMultipleSelect) {
    // eslint-disable-next-line no-new
    new Choices(elementMultipleSelect, {
      ...choiceOptions,
      resetScrollPosition: false,
      renderSelectedChoices: 'always'
    })
  }

  const elementsOfSingles = document.querySelectorAll('.js-choices-singles')
  if (elementsOfSingles.length > 0) {
    for (const element of elementsOfSingles) {
      // eslint-disable-next-line no-new
      new Choices(element, choiceOptions)
    }
  }

  const elements = document.querySelectorAll('.js-choices-added-select')
  const elementsCount = elements.length
  if (!elements) return
  for (let i = 0; i < elementsCount; i++) {
    // eslint-disable-next-line no-new
    new Choices(elements[i], {
      ...choiceOptions,
      removeItemButton: false
    })
  }

  const addChoiceButtons = document.querySelectorAll('.js-add-choice')
  addChoiceButtons.forEach((button) => {
    button.addEventListener('cocooned:after-insert', () => {
      const elements = document.querySelectorAll('.js-choices-added-select')
      if (!elements) return
      const element = elements[elements.length - 1]
      if (element) {
        // eslint-disable-next-line no-new
        new Choices(element, {
          ...choiceOptions,
          removeItemButton: false
        })
      }
    })
  })
})
