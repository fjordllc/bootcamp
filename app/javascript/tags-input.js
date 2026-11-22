import Tagify from '@yaireo/tagify'
import { get } from '@rails/request.js'
import transformHeadSharp from 'transform-head-sharp'
import validateTagName from 'validate-tag-name'
import headIsSharpOrOctothorpe from 'head-is-sharp-or-octothorpe'
import parseTags from 'parse_tags'

function syncHiddenInput(tagify, hiddenInput) {
  const values = tagify.value
    .filter((tag) => tag.__isValid === true)
    .map((tag) => tag.value)
  hiddenInput.value = values.join(',')
}

function initTagsInput(container) {
  const input = container.querySelector('[data-tags-input-field]')
  const hiddenInput = container.querySelector('[data-tags-hidden-input]')
  const sharpWarning = container.querySelector('[data-tags-sharp-warning]')
  if (!input || !hiddenInput) return

  const initialValue = input.dataset.tagsInitialValue || ''
  const taggableType = input.dataset.taggableType || ''

  const tagify = new Tagify(input, {
    validate: validateTagName,
    transformTag: transformHeadSharp
  })

  // Set initial tags
  const initialTags = parseTags(initialValue)
  if (initialTags.length > 0) {
    tagify.addTags(initialTags)
  }

  // Sync hidden input on initial load
  syncHiddenInput(tagify, hiddenInput)

  // Fetch whitelist
  get(`/api/tags.json?taggable_type=${taggableType}`, {
    responseKind: 'json'
  })
    .then((res) => res.json)
    .then((data) => {
      tagify.whitelist = data.map((tag) => tag.value)
    })
    .catch((err) => {
      console.warn('使われているタグリストの読み込みに失敗しました', err)
    })

  tagify.on('input', (e) => {
    const show = headIsSharpOrOctothorpe(e.detail.value)
    if (sharpWarning) {
      sharpWarning.style.display = show ? '' : 'none'
    }
  })

  tagify.on('change', () => {
    syncHiddenInput(tagify, hiddenInput)
    if (sharpWarning) {
      sharpWarning.style.display = 'none'
    }
  })

  tagify.on('invalid', (e) => {
    alert(e.detail.message)
    if (sharpWarning) {
      sharpWarning.style.display = 'none'
    }
  })

  // Listen for add-tag-from-shortcut custom event (dispatched by tag-shortcut.js)
  tagify.DOM.scope.addEventListener('add-tag-from-shortcut', (e) => {
    const newTag = e.detail?.tag
    if (!newTag || tagify.value.some((t) => t.value === newTag)) return
    tagify.addTags([newTag])
  })
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[data-tags-input]').forEach(initTagsInput)
})
