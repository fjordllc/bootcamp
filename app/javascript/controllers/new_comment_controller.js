import { Controller } from '@hotwired/stimulus'
import TextareaInitializer from 'textarea-initializer'
import autosize from 'autosize'
import commentCheckable from 'comment-checkable'

export default class extends Controller {
  static targets = [
    'inputTab',
    'inputPanel',
    'inputBody',
    'previewTab',
    'previewPanel',
    'previewBody',
    'submitButton',
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
    this.setSubmitButtonState()
    TextareaInitializer.initialize(`#${this.inputBodyTarget.id}`)
  }

  openInputTab() {
    this.#showTab('input')
  }

  openPreviewTab() {
    this.#showTab('preview')
  }

  setSubmitButtonState() {
    const isEmpty = this.inputBodyTarget.value.length === 0

    this.submitButtonTarget.disabled = isEmpty
    if (this.hasSubmitAndCheckButtonTarget) {
      this.submitAndCheckButtonTarget.disabled = isEmpty
    }
    if (this.hasSubmitAndApproveButtonTarget) {
      this.submitAndApproveButtonTarget.disabled = isEmpty
    }
  }

  async #confirmReportComment() {
    if (this.commentableTypeValue !== 'Report' || !this.isMentorValue) {
      return true
    }

    const isChecked = await commentCheckable.isChecked(
      this.commentableTypeValue,
      this.commentableIdValue
    )

    if (isChecked) return true

    return window.confirm('日報を確認済みにしていませんがよろしいですか？')
  }

  #confirmProductApproval() {
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
