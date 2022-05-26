import Sortable from 'sortablejs'
import Bootcamp from 'bootcamp'

document.addEventListener('DOMContentLoaded', () => {
  const elements = document.querySelectorAll('.js-admin-category-practice')
  if (!elements) {
    return null
  }

  elements.forEach((element) => {
    Sortable.create(element, {
      handle: '.js-grab',
      onEnd(event) {
        const id = event.item.dataset.categories_practice_id
        const params = { insert_at: event.newIndex + 1 }
        const url = `/api/categories_practices/${id}/position.json`

        Bootcamp.patch(url, params).catch((error) => {
          console.warn(error)
        })
      }
    })
  })
})
