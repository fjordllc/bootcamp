import CSRF from 'csrf'
import { Controller } from '@hotwired/stimulus'
import MarkdownInitializer from 'markdown-initializer'
import TextareaInitializer from 'textarea-initializer'
import { toast } from 'vanillaToast'

export default class extends Controller {
  #markdownInitializer = new MarkdownInitializer()
  #savedMemo = ''

  static values = {
    practiceId: Number
  }

  static targets = [
    'display',
    'displayWithMemo',
    'displayWithoutMemo',
    'displayContent',
    'editor',
    'editorTextarea',
    'editorTextareaContent',
    'editorTextareaTab',
    'editorPreview',
    'editorPreviewContent',
    'editorPreviewTab',
    'editorControl'
  ]

  connect() {
    this.#initializeEditor()
  }

  handleClickEditButton() {
    this.#showEditor()
  }

  async handleClickSaveButton() {
    const memo = this.editorTextareaContentTarget.value

    try {
      this.#setFormDisabled(true)
      await this.#updateMemo(memo, this.practiceIdValue)
    } catch (error) {
      toast('メモの保存に失敗しました', 'error')
      console.warn(error)
      return
    } finally {
      this.#setFormDisabled(false)
    }

    this.#savedMemo = memo
    this.#renderMemo(this.#savedMemo)
    this.#showDisplay()
    TextareaInitializer.initialize('#js-practice-memo')
  }

  handleClickCancelButton() {
    this.editorTextareaContentTarget.value = this.#savedMemo
    this.#renderMemo(this.#savedMemo)
    this.#showDisplay()
    TextareaInitializer.initialize('#js-practice-memo')
  }

  showEditorTextarea() {
    this.editorTextareaTarget.classList.add('is-active')
    this.editorTextareaTabTarget.classList.add('is-active')
    this.editorPreviewTarget.classList.remove('is-active')
    this.editorPreviewTabTarget.classList.remove('is-active')
  }

  showEditorPreview() {
    this.editorTextareaTarget.classList.remove('is-active')
    this.editorTextareaTabTarget.classList.remove('is-active')
    this.editorPreviewTarget.classList.add('is-active')
    this.editorPreviewTabTarget.classList.add('is-active')
  }

  updateEditorPreviewContent() {
    this.editorPreviewContentTarget.innerHTML =
      this.#markdownInitializer.render(this.editorTextareaContentTarget.value)
  }

  async #fetchMemo() {
    const response = await fetch(
      `/api/practices/${this.practiceIdValue}.json`,
      {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin',
        redirect: 'manual'
      }
    )
    if (!response.ok) {
      throw new Error(`メモの取得に失敗しました: ${response.status}`)
    }
    const json = await response.json()

    return json.memo ?? ''
  }

  async #updateMemo(memo, practiceId) {
    const params = {
      practice: {
        memo
      }
    }

    const response = await fetch(`/api/practices/${practiceId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })
    if (!response.ok) {
      throw new Error(`メモの更新に失敗しました: ${response.status}`)
    }

    toast('保存しました！')
  }

  #renderMemo(memo) {
    const renderedMemo = this.#markdownInitializer.render(memo)

    this.displayContentTarget.innerHTML = renderedMemo
    this.editorPreviewContentTarget.innerHTML = renderedMemo
  }

  #showDisplay() {
    const hasMemo = this.#savedMemo !== ''

    this.displayWithMemoTarget.classList.toggle('is-hidden', !hasMemo)
    this.displayWithoutMemoTarget.classList.toggle('is-hidden', hasMemo)
    this.displayTarget.classList.remove('is-hidden')
    this.editorTarget.classList.add('is-hidden')
  }

  #showEditor() {
    this.displayTarget.classList.add('is-hidden')
    this.editorTarget.classList.remove('is-hidden')
  }

  async #initializeEditor() {
    try {
      this.#savedMemo = await this.#fetchMemo()
    } catch (error) {
      toast('メモの取得に失敗しました', 'error')
      console.warn(error)
      return
    }

    this.editorTextareaContentTarget.value = this.#savedMemo
    this.#renderMemo(this.#savedMemo)
    this.#showDisplay()
    TextareaInitializer.initialize('#js-practice-memo')
  }

  #setFormDisabled(isDisabled) {
    this.editorControlTargets.forEach((control) => {
      control.disabled = isDisabled
    })
  }
}
