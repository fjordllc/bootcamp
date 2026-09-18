import { Controller } from '@hotwired/stimulus'
import { toast } from 'vanillaToast'
import { get } from '@rails/request.js'

export default class extends Controller {
  static values = {
    watching: Boolean
  }

  submitEnd(event) {
    const { success, error, fetchResponse } = event.detail

    if (success) {
      toast(this.watchingValue ? 'Watchを外しました' : 'Watchしました！')
    } else {
      console.warn(error || fetchResponse)
      toast(
        this.watchingValue
          ? 'Watchを外せませんでした。時間をおいてもう一度実行してください'
          : 'Watchできませんでした。時間をおいてもう一度実行してください',
        'error'
      )
    }
  }

  async refresh(event) {
    const { watchableId, watchableType } = event.detail

    try {
      const response = await get('/watches/refresh', {
        query: {
          watchable_id: watchableId,
          watchable_type: watchableType
        },
        responseKind: 'turbo-stream'
      })

      if (!response.ok) {
        throw new Error(`${response.error}`)
      }
    } catch (error) {
      console.warn(error)
    }
  }
}
