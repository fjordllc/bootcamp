import { Controller } from '@hotwired/stimulus'
import TextareaInitializer from 'textarea-initializer'
import { toast } from 'vanillaToast'
import { get } from '@rails/request.js'

export default class extends Controller {
  static targets = ['title', 'description', 'practices']

  async replaceReport(e) {
    e.preventDefault()

    const response = await get('/api/reports/latest', { responseKind: 'json' })

    if (!response.ok) {
      toast('最新の日報が見つかりませんでした。')
      return
    }

    if (!confirm('日報が上書きされますが、よろしいですか？')) {
      return
    }

    const data = await response.json
    this.practicesTarget.choices.removeActiveItems()
    data.practice_ids.forEach((id) => {
      this.practicesTarget.choices.setChoiceByValue(String(id))
    })
    this.titleTarget.value = data.title
    this.descriptionTarget.value = data.description

    TextareaInitializer.uninitialize('.js-report-content')
    TextareaInitializer.initialize('.js-report-content')
  }
}
