import Sortable from 'sortablejs'
import Bootcamp from 'bootcamp'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.querySelector('#js-coding-test-sortable')
  if (!element) {
    return null
  }

  Sortable.create(element, {
    handle: '.js-grab',
    onEnd(event) {
      const id = event.item.dataset.practice_coding_test_id
      const params = { insert_at: event.newIndex + 1 }
      const url = `/api/coding_tests/${id}/position.json`

      Bootcamp.patch(url, params).catch((error) => {
        console.warn(error)
      })
    }
  })
})
