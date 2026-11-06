import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  submitEnd({ detail: { success, error, fetchResponse } }) {
    if (!success) console.warn(error || fetchResponse)
  }
}
