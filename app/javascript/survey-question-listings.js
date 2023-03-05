import Sortable from 'sortablejs'
import Bootcamp from 'bootcamp'

document.addEventListener('DOMContentLoaded', () => {
  const element = document.querySelector(
    '#js-survey-question-listings-sortable'
  )
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

      Bootcamp.patch(url, params).catch((error) => {
        console.warn(error)
      })
    }
  })
})
