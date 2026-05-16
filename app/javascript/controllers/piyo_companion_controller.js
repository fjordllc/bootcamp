import { Controller } from 'stimulus'

const CONGRATULATION_MESSAGES = [
  'このセクション完了！よくがんばったね！🎉',
  'すごい！また一歩前進だね！✨',
  'おつかれさま！着実に進んでるよ！💪',
  'やったね！次のセクションも一緒にがんばろう！🌟',
  'クリアおめでとう！その調子！🎊'
]

const WELCOME_BACK_MESSAGES = [
  'おかえり！また一緒に学ぼう！📚',
  'ひさしぶり！待ってたよ！😊',
  '戻ってきてくれてうれしいピヨ！🐣'
]

const ABSENCE_THRESHOLD_MS = 3 * 24 * 60 * 60 * 1000 // 3 days
const AUTO_DISMISS_MS = 5000

export default class extends Controller {
  static targets = ['bubble', 'message']

  connect() {
    this.dismissTimer = null
    this.boundHandleCompletion = this.handleCompletion.bind(this)
    this.checkWelcomeBack()

    document.addEventListener(
      'reading-progress:completed',
      this.boundHandleCompletion
    )
  }

  disconnect() {
    if (this.dismissTimer) {
      clearTimeout(this.dismissTimer)
    }
    document.removeEventListener(
      'reading-progress:completed',
      this.boundHandleCompletion
    )
  }

  checkWelcomeBack() {
    const lastVisit = localStorage.getItem('textbook_last_visit')
    const now = Date.now()
    localStorage.setItem('textbook_last_visit', now.toString())

    if (lastVisit) {
      const elapsed = now - parseInt(lastVisit, 10)
      if (elapsed > ABSENCE_THRESHOLD_MS) {
        setTimeout(() => {
          this.showMessage(this.randomFrom(WELCOME_BACK_MESSAGES))
        }, 1000)
      }
    }
  }

  handleCompletion() {
    this.showMessage(this.randomFrom(CONGRATULATION_MESSAGES))
  }

  showMessage(text) {
    if (!this.hasBubbleTarget || !this.hasMessageTarget) return

    this.messageTarget.textContent = text
    this.bubbleTarget.classList.remove('is-hidden')

    if (this.dismissTimer) {
      clearTimeout(this.dismissTimer)
    }
    this.dismissTimer = setTimeout(() => this.dismiss(), AUTO_DISMISS_MS)
  }

  dismiss() {
    if (this.hasBubbleTarget) {
      this.bubbleTarget.classList.add('is-hidden')
    }
    if (this.dismissTimer) {
      clearTimeout(this.dismissTimer)
      this.dismissTimer = null
    }
  }

  randomFrom(array) {
    return array[Math.floor(Math.random() * array.length)]
  }
}
