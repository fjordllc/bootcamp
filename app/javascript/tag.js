import Tagify from '@yaireo/tagify'
import '@yaireo/tagify/dist/tagify.css' // Tagify CSS
import fetcher from './fetcher'
import CSRF from './csrf'
import transformHeadSharp from './transform-head-sharp'
import validateTagName from './validate-tag-name'
import headIsSharpOrOctothorpe from './head-is-sharp-or-octothorpe'
import parseTags from './parse_tags'

document.addEventListener('DOMContentLoaded', () => {
  const tagsContainer = document.querySelector('.tag-component')
  if (!tagsContainer) return
  const tagsDisplay = tagsContainer.querySelector('.tags-display')
  const tagListItems = tagsDisplay.querySelector('.tag-links__items')
  const editButton = tagListItems.querySelector('.tag-links__item-edit')
  const tagsForm = tagsContainer.querySelector('.tags-form')
  const inputTags = tagsForm.querySelector('.tags-form__input')
  const sharpWarning = tagsForm.querySelector('.sharp-warning')
  const cancelButton = tagsForm.querySelector('.cancel-button')

  const tagsType = tagsContainer.dataset.tagsType
  const tagsTypeId = tagsContainer.dataset.tagsTypeId

  let tagsInitialValue = parseTags(tagsContainer.dataset.tagsInitialValue || '')
  let tags = [...tagsInitialValue]

  const tagify = new Tagify(inputTags, {
    validate: validateTagName,
    transformTag: transformHeadSharp
  })

  const setEditing = (isEditing) => {
    tagsDisplay.classList.toggle('hidden', isEditing)
    tagsForm.classList.toggle('hidden', !isEditing)
  }

  const renderTags = (tags) => {
    const items = tagListItems.querySelectorAll('.tag-links__item')
    items.forEach((item) => {
      if (!item.querySelector('.tag-links__item-edit')) {
        item.remove()
      }
    })

    tags.forEach((tag) => {
      const li = document.createElement('li')
      li.className = 'tag-links__item'
      const link = document.createElement('a')
      link.className = 'tag-links__item-link'
      link.href = `/${tagsType.toLowerCase()}s/tags/${encodeURIComponent(tag)}`
      link.textContent = tag
      li.appendChild(link)
      const editBtnLi = editButton?.parentElement
      tagListItems.insertBefore(li, editBtnLi || null)
    })
  }

  const fetchTagsData = async () => {
    try {
      const url = `/api/tags.json?taggable_type=${tagsType}`
      const data = await fetcher(url)
      tagify.whitelist = data.map((tag) => tag.value)
    } catch (error) {
      console.warn('使われているタグリストの読み込みに失敗しました', error)
    }
  }

  tagify.on('change', (e) => {
    tags = e.detail.tagify.value
      .filter((tag) => tag.__isValid)
      .map((tag) => tag.value)
    sharpWarning.classList.add('hidden')
  })

  tagify.on('input', (e) => {
    const isSharp = headIsSharpOrOctothorpe(e.detail.value)
    if (isSharp) {
      sharpWarning.classList.remove('hidden')
    } else {
      sharpWarning.classList.add('hidden')
    }
  })

  tagify.on('invalid', (e) => {
    alert(e.detail.message)
  })

  editButton?.addEventListener('click', () => {
    tagify.removeAllTags()
    tagify.addTags(tags, true)
    sharpWarning.classList.add('hidden')
    setEditing(true)
  })

  cancelButton?.addEventListener('click', (e) => {
    e.preventDefault()
    tags = [...tagsInitialValue]
    tagify.removeAllTags()
    tagify.addTags(tags, true)
    setEditing(false)
  })

  tagsForm.addEventListener('submit', async (e) => {
    e.preventDefault()
    tags = tagify.value.filter((tag) => tag.__isValid).map((tag) => tag.value)
    const params = {
      [tagsType.toLowerCase()]: {
        tag_list: tags.join(',')
      }
    }
    try {
      const response = await fetch(
        `/api/${tagsType.toLowerCase()}s/${tagsTypeId}`,
        {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': CSRF.getToken()
          },
          credentials: 'same-origin',
          redirect: 'manual',
          body: JSON.stringify(params)
        }
      )
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      tagsInitialValue = [...tags]
      renderTags(tags)
      setEditing(false)
    } catch (error) {
      alert('タグの更新に失敗しました')
      console.warn(error)
    }
  })

  fetchTagsData()
  renderTags(tagsInitialValue)
})
