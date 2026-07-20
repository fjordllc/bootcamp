import { Controller } from '@hotwired/stimulus'
import TextareaInitializer from 'textarea-initializer'
import { toast } from 'vanillaToast'

export default class extends Controller {
  static targets = ['title', 'description', 'practices']

  async replaceReport(e) {
    e.preventDefault()

    const response = await fetch('/api/reports/latest.json', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin'
    })

    if (!response.ok) {
      toast('最新の日報が見つかりませんでした。')
      return
    }

    if (!confirm('日報が上書きされますが、よろしいですか？')) {
      return
    }

    const data = await response.json()
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
