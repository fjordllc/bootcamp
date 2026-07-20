import { Controller } from '@hotwired/stimulus'
import TextareaInitializer from 'textarea-initializer'
import { toast } from 'vanillaToast'

export default class extends Controller {
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
  }
}
