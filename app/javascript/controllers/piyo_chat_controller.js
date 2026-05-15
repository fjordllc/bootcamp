import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['panel', 'messages', 'input', 'sendButton', 'badge']
  static values = { sectionId: Number, open: { type: Boolean, default: false } }

  connect() {
    this.loadHistory()
  }

  toggle() {
    this.openValue = !this.openValue
    this.panelTarget.classList.toggle('is-hidden', !this.openValue)

    if (this.openValue) {
      this.hideBadge()
      this.scrollToBottom()
      this.inputTarget.focus()
    }
  }

  close() {
    this.openValue = false
    this.panelTarget.classList.add('is-hidden')
  }

  async send() {
    const content = this.inputTarget.value.trim()
    if (!content) return

    this.inputTarget.value = ''
    this.appendMessage('user', content)
    this.setLoading(true)

    try {
      const response = await fetch('/api/textbooks/piyo_chat_messages', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.csrfToken
        },
        body: JSON.stringify({
          section_id: this.sectionIdValue,
          content: content
        })
      })

      if (!response.ok) throw new Error('送信に失敗しました')

      const data = await response.json()
      this.appendMessage('assistant', data.assistant_message.content)
    } catch (error) {
      this.appendMessage('assistant', 'ごめんなさい、エラーが発生しました。もう一度試してみてください。')
    } finally {
      this.setLoading(false)
    }
  }

  onKeydown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      this.send()
    }
  }

  async loadHistory() {
    try {
      const response = await fetch(
        `/api/textbooks/piyo_chat_messages?section_id=${this.sectionIdValue}`
      )
      if (!response.ok) return

      const messages = await response.json()
      messages.forEach((msg) => this.appendMessage(msg.role, msg.content))
    } catch {
      // 履歴読み込み失敗は無視
    }
  }

  appendMessage(role, content) {
    const el = document.createElement('div')
    el.className = `piyo-chat-message piyo-chat-message--${role}`
    el.textContent = content
    this.messagesTarget.appendChild(el)
    this.scrollToBottom()

    if (!this.openValue && role === 'assistant') {
      this.showBadge()
    }
  }

  setLoading(loading) {
    this.sendButtonTarget.disabled = loading

    if (loading) {
      this.loadingEl = document.createElement('div')
      this.loadingEl.className = 'piyo-chat-message piyo-chat-message--assistant piyo-chat-message--loading'
      this.loadingEl.textContent = '...'
      this.messagesTarget.appendChild(this.loadingEl)
      this.scrollToBottom()
    } else if (this.loadingEl) {
      this.loadingEl.remove()
      this.loadingEl = null
    }
  }

  scrollToBottom() {
    requestAnimationFrame(() => {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    })
  }

  showBadge() {
    if (this.hasBadgeTarget) {
      this.badgeTarget.classList.remove('is-hidden')
    }
  }

  hideBadge() {
    if (this.hasBadgeTarget) {
      this.badgeTarget.classList.add('is-hidden')
    }
  }

  get csrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.content : ''
  }
}
