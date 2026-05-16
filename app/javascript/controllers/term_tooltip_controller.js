import { Controller } from 'stimulus'
import { get } from '@rails/request.js'

export default class extends Controller {
  static values = {
    term: String,
    sectionId: Number
  }

  connect() {
    this.cache = {}
    this.tooltip = null
    this.requestId = 0
  }

  disconnect() {
    this.removeTooltip()
  }

  toggle(event) {
    event.preventDefault()

    if (this.tooltip) {
      this.removeTooltip()
      return
    }

    const term = this.termValue
    const cacheKey = `${this.sectionIdValue}:${term}`

    if (this.cache[cacheKey]) {
      this.showTooltip(this.cache[cacheKey], event.currentTarget)
      return
    }

    this.showLoading(event.currentTarget)
    this.fetchExplanation(term, cacheKey, event.currentTarget)
  }

  async fetchExplanation(term, cacheKey, anchor) {
    // リクエストIDを更新して競合状態を防ぐ
    const currentRequestId = ++this.requestId

    try {
      const response = await get(
        `/api/textbooks/term_explanations/${encodeURIComponent(
          this.sectionIdValue
        )}?term=${encodeURIComponent(term)}`,
        { responseKind: 'json' }
      )

      // 最新のリクエストでない場合は無視
      if (currentRequestId !== this.requestId) {
        return
      }

      if (!response.ok) {
        this.showTooltip('説明が見つかりませんでした。', anchor)
        return
      }

      const data = await response.json
      const explanation = data.explanation || '説明がありません。'
      this.cache[cacheKey] = explanation
      this.removeTooltip()
      this.showTooltip(explanation, anchor)
    } catch {
      // 最新のリクエストでない場合は無視
      if (currentRequestId !== this.requestId) {
        return
      }
      this.removeTooltip()
      this.showTooltip('読み込みに失敗しました。', anchor)
    }
  }

  showLoading(anchor) {
    this.showTooltip('読み込み中...', anchor)
  }

  showTooltip(text, anchor) {
    this.removeTooltip()

    this.tooltip = document.createElement('div')
    this.tooltip.className = 'term-tooltip'
    this.tooltip.textContent = text

    const rect = anchor.getBoundingClientRect()
    this.tooltip.style.position = 'absolute'
    this.tooltip.style.left = `${rect.left + window.scrollX}px`
    this.tooltip.style.top = `${rect.bottom + window.scrollY + 4}px`
    this.tooltip.style.zIndex = '1000'

    document.body.appendChild(this.tooltip)

    document.addEventListener('click', this.handleOutsideClick)
  }

  handleOutsideClick = (event) => {
    if (
      this.tooltip &&
      !this.tooltip.contains(event.target) &&
      !this.element.contains(event.target)
    ) {
      this.removeTooltip()
    }
  }

  removeTooltip() {
    // リクエストをキャンセル（リクエストIDをリセット）
    this.requestId = 0
    document.removeEventListener('click', this.handleOutsideClick)
    if (this.tooltip) {
      this.tooltip.remove()
      this.tooltip = null
    }
  }
}
