import Sortable from 'sortablejs'
import Bootcamp from 'bootcamp'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.querySelector('#js-faq-category-sortable')
  if (!element) return

  Sortable.create(element, {
    handle: '.js-grab',
    onEnd(event) {
      const id = event.item.id
      const url = `/admin/faq_categories/${id}`
      const params = {
        faq_category: {
          insert_at: event.newIndex + 1
        }
      }

      Bootcamp.patch(url, params).catch((error) => {
        console.error('Error while updating an order:', error)
      })
    }
  })
})
