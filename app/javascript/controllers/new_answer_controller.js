import { Controller } from '@hotwired/stimulus'
import { toast } from 'vanillaToast'

export default class extends Controller {
  static values = { questionId: Number }

  submitEnd({ detail: { success, error, fetchResponse } }) {
    if (success) {
      toast('回答を投稿しました！')
      this.dispatch('refresh', {
        prefix: 'watch',
        detail: {
          watchableId: this.questionIdValue,
          watchableType: 'Question'
        }
      })
    } else if (fetchResponse?.statusCode !== 422) {
      console.warn(error || fetchResponse)
    }
  }
}
