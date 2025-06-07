import Sortable from 'sortablejs'
import { patch } from '@rails/request.js'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.querySelector('#js-survey-question-listing-sortable')
  if (!element) {
    return null
  }

  Sortable.create(element, {
    handle: '.js-grab',
    onEnd(event) {
      const id = event.item.dataset.survey_question_listing_id
      // sortablejsのindexは0からはじまるため+1する
      const params = { insert_at: event.newIndex + 1 }
      const url = `/api/survey_question_listings/${id}/position.json`

      patch(url, {
        body: JSON.stringify(params),
        contentType: 'application/json'
      })
        .then((response) => {
          if (!response.ok) {
            console.warn('Request failed:', response.status)
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  })
})
