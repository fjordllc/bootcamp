import { Controller } from '@hotwired/stimulus'
import { toast } from 'vanillaToast'
import MarkdownInitializer from 'markdown-initializer'
import TextareaInitializer from 'textarea-initializer'
import autosize from 'autosize'
import commentCheckable from 'comment-checkable'
import { post } from '@rails/request.js'

export default class extends Controller {
  static targets = [
    'inputTab',
    'inputPanel',
    'inputBody',
    'previewTab',
    'previewPanel',
    'previewBody',
    'submitButton',
    'checkAndApproveButtonWrapper',
    'submitAndCheckButton',
    'submitAndApproveButton'
  ]

  static values = {
    commentableType: String,
    commentableId: Number,
    isMentor: Boolean,
    currentUserId: Number
  }

  connect() {
    this.isSubmitting = false
    this.setSubmitButtonState()
    TextareaInitializer.initialize(`#${this.inputBodyTarget.id}`)
    this.#showPendingToast()
  }

  openInputTab() {
    this.#showTab('input')
  }

  openPreviewTab() {
    this.#showTab('preview')
  }

  setSubmitButtonState() {
    const isDisabled =
      this.inputBodyTarget.value.length === 0 || this.isSubmitting

    this.submitButtonTarget.disabled = isDisabled
    if (this.hasSubmitAndCheckButtonTarget) {
      this.submitAndCheckButtonTarget.disabled = isDisabled
    }
    if (this.hasSubmitAndApproveButtonTarget) {
      this.submitAndApproveButtonTarget.disabled = isDisabled
    }
  }

  renderPreview() {
    this.previewBodyTarget.innerHTML = new MarkdownInitializer().render(
      this.inputBodyTarget.value
    )
  }

  async submit(event) {
    event.preventDefault()

    if (this.isSubmitting) return
    this.isSubmitting = true
    this.setSubmitButtonState()

    const form = event.currentTarget
    const operation = event.submitter?.value

    try {
      if (!this.#confirmProductApproval(operation)) return
      if (!(await this.#confirmReportComment(operation))) return

      const isAssignedProductChecker = await this.#assignProductChecker()
      await this.#postComment(form)
      this.#dispatchWatchRefresh()
      const isCheckedOrApproved = await this.#checkOrApprove(operation)
      this.#resetForm()

      if (isAssignedProductChecker || isCheckedOrApproved) {
        location.reload()
      } else {
        toast('コメントを投稿しました！')
      }
    } catch (error) {
      console.warn(error)
    } finally {
      this.isSubmitting = false
      this.setSubmitButtonState()
    }
  }

  #showPendingToast() {
    const message = sessionStorage.getItem('showToast')
    if (!message) return

    sessionStorage.removeItem('showToast')
    toast(message)
  }

  #isCheckOrApproveOperation(operation) {
    return ['commentAndCheck', 'commentAndApprove'].includes(operation)
  }

  async #confirmReportComment(operation) {
    const isMentorViewingReport =
      this.commentableTypeValue === 'Report' && this.isMentorValue
    if (!isMentorViewingReport || this.#isCheckOrApproveOperation(operation)) {
      return true
    }

    const isChecked = await commentCheckable.isChecked(
      this.commentableTypeValue,
      this.commentableIdValue
    )
    if (isChecked) return true

    return window.confirm('日報を確認済みにしていませんがよろしいですか？')
  }

  #confirmProductApproval(operation) {
    if (operation !== 'commentAndApprove') return true

    return window.confirm('提出物を合格にしてよろしいですか？')
  }

  async #assignProductChecker() {
    const shouldAssign = await commentCheckable.isUnassignedAndUncheckedProduct(
      this.commentableTypeValue,
      this.commentableIdValue,
      this.isMentorValue
    )

    if (!shouldAssign) return false

    await commentCheckable.assignChecker(
      this.commentableIdValue,
      this.currentUserIdValue
    )

    return true
  }

  async #postComment(form) {
    const response = await post(form.action, {
      body: new FormData(form),
      responseKind: 'turbo-stream'
    })

    if (!response.ok) {
      throw new Error('コメントの投稿に失敗しました')
    }
  }

  #dispatchWatchRefresh() {
    this.dispatch('refresh', {
      prefix: 'watch',
      detail: {
        watchableId: this.commentableIdValue,
        watchableType: this.commentableTypeValue
      }
    })
  }

  async #checkOrApprove(operation) {
    if (!this.#isCheckOrApproveOperation(operation)) return false

    await commentCheckable.check(
      this.commentableTypeValue,
      this.commentableIdValue,
      '/api/checks',
      'post'
    )
    this.checkAndApproveButtonWrapperTarget.classList.add('is-hidden')

    return true
  }

  #resetForm() {
    this.openInputTab()
    this.inputBodyTarget.value = ''
    autosize.update(this.inputBodyTarget)
    this.previewBodyTarget.innerHTML = ''
    this.setSubmitButtonState()
  }

  #showTab(tabName) {
    const showInput = tabName === 'input'
    const showPreview = tabName === 'preview'

    this.inputTabTarget.classList.toggle('is-active', showInput)
    this.inputPanelTarget.classList.toggle('is-active', showInput)
    this.previewTabTarget.classList.toggle('is-active', showPreview)
    this.previewPanelTarget.classList.toggle('is-active', showPreview)
  }
}
