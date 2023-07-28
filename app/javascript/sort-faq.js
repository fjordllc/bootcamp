import Sortable from 'sortablejs'
import Bootcamp from 'bootcamp'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.querySelector('#js-faq-sortable')
  if (!element) {
    return null
  }

  Sortable.create(element, {
    handle: '.js-grab',
    onEnd(event) {
      const id = event.item.dataset.faq_id
      const params = { insert_at: event.newIndex + 1 }
      const url = `/api/admin/faqs/${id}`

      Bootcamp.patch(url, params).catch((error) => {
        console.warn(error)
      })
    }
  })
})
