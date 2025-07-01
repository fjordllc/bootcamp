import Tagify from '@yaireo/tagify'
import '@yaireo/tagify/dist/tagify.css' // Tagify CSS
import fetcher from './fetcher'
import CSRF from './csrf'
import transformHeadSharp from './transform-head-sharp'
import validateTagName from './validate-tag-name'
import headIsSharpOrOctothorpe from './head-is-sharp-or-octothorpe'
import parseTags from './parse_tags'

//import VueTagsInput from '@johmun/vue-tags-input'

document.addEventListener('DOMContentLoaded', () => {
  const tagsContainer = document.querySelector('.tag-links')
  const tagsType = tagsContainer?.dataset.tagsType

  const fetchTagsData = async () => {
    try {
      const url = `/api/tags.json?taggable_type=${tagsType}`
      const response = await fetcher(url)
      const data = await response.json()
    } catch (error) {
      console.warn('使われているタグリストの読み込みに失敗しました', error)
    }
  }
  fetchTagsData()

  const tagListItems = tagsContainer?.querySelector('.tag-links__items')
  const tagsInitialValue = parseTags(
    tagsContainer?.dataset.tagsInitialValue || ''
  )

  const renderTags = (tags) => {
    tags.forEach((tag) => {
      const li = document.createElement('li')
      li.className = 'tag-links__item'
      li.innerHTML = `<a class="tag-links__item-link" href="/users/tags/${encodeURIComponent(
        tag
      )}">${tag}</a>`
      tagListItems.appendChild(li)
    })
  }
  renderTags(tagsInitialValue)
})
