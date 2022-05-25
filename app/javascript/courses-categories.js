import Sortable from 'sortablejs'
import Bootcamp from 'bootcamp'

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

      Bootcamp.patch(url, params).catch((error) => {
        console.warn(error)
      })
    }
  })
})
