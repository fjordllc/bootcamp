import Sortable from 'sortablejs'
import { patch } from '@rails/request.js'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.querySelector('#js-faq-sortable')
  if (!element) return

  Sortable.create(element, {
    handle: '.js-grab',
    onEnd(event) {
      const id = event.item.id
      const categoryId = event.item.dataset.faqCategoryId
      const url = `/admin/faq_categories/${categoryId}/faqs/${id}`
      const params = {
        faq: {
          insert_at: event.newIndex + 1
        }
      }

      patch(url, { body: params }).catch((error) => {
        console.error('Error while updating an order:', error)
      })
    }
  })
})
