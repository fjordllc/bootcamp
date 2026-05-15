import Sortable from 'sortablejs'
import { patch } from '@rails/request.js'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.querySelector('#js-category-sortable')
  if (!element) {
    return null
  }

  Sortable.create(element, {
    handle: '.js-grab',
    onEnd(event) {
      const id = event.item.dataset.courses_category_id
      const params = { insert_at: event.newIndex + 1 }
      const url = `/api/courses_categories/${id}/position.json`

      patch(url, { body: params }).catch((error) => {
        console.warn(error)
      })
    }
  })
})
