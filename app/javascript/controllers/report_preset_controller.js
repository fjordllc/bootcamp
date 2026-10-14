import { Controller } from '@hotwired/stimulus'
import { post, put } from '@rails/request.js'
import TextareaInitializer from 'textarea-initializer'
import { toast } from 'vanillaToast'

export default class extends Controller {
  static targets = [
    'reportInput',
    'modal',
    'presetInput',
    'submitButton',
    'presetEditTab',
    'previewTab',
    'presetEditPanel',
    'previewPanel',
    'replaceReportAction',
    'openModalButton'
  ]

  static values = {
    presetId: Number,
    savedPresetDescription: String
  }

  connect() {
    if (this.reportInputTarget.value === '') {
      this.reportInputTarget.value = this.savedPresetDescriptionValue
    }
    TextareaInitializer.initialize('.js-report-content')
    this.updatePresetControls()
  }

  replaceReportWithPreset(e) {
    e.preventDefault()
    if (
      this.reportInputTarget.value === '' ||
      confirm('日報が上書きされますが、よろしいですか？')
    ) {
      this.reportInputTarget.value = this.savedPresetDescriptionValue
      TextareaInitializer.uninitialize('.js-report-content')
      TextareaInitializer.initialize('.js-report-content')
    }
  }

  clickOutside(e) {
    if (e.target !== e.currentTarget) {
      return
    }
    if (
      this.presetInputTarget.value === this.savedPresetDescriptionValue ||
      confirm('テンプレートを登録せずに終了しますか？')
    ) {
      this.closeModal()
    }
  }

  openModal(e) {
    e.preventDefault()
    this.modalTarget.classList.remove('is-hidden')
    this.presetInputTarget.value = this.savedPresetDescriptionValue
    TextareaInitializer.initialize('#js-preset-content')
    this.updateSubmitButtonState()
  }

  closeModal() {
    this.modalTarget.classList.add('is-hidden')
  }

  savePreset(e) {
    e.preventDefault()
    const editingDescription = this.presetInputTarget.value

    if (
      editingDescription.trim() === '' ||
      editingDescription.trim() === this.savedPresetDescriptionValue.trim()
    ) {
      return
    }

    if (this.presetIdValue > 0) {
      return this.updatePreset(editingDescription)
    }
    return this.registerPreset(editingDescription)
  }

  registerPreset(editingDescription) {
    const params = {
      report_preset: { description: editingDescription }
    }

    return post('/api/report_presets', {
      body: params,
      responseKind: 'json',
      redirect: 'manual'
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error('テンプレートの登録に失敗しました')
        }
        return response.json
      })
      .then((createdPreset) => {
        this.presetIdValue = createdPreset.id
        this.savedPresetDescriptionValue = editingDescription
        this.updatePresetControls()
        toast('テンプレートを登録しました！')
        this.closeModal()
      })
      .catch((error) => {
        console.warn(error)
        toast('テンプレートを登録できませんでした。', 'error')
      })
  }

  updatePreset(editingDescription) {
    const params = {
      report_preset: { description: editingDescription }
    }

    return put(`/api/report_presets/${this.presetIdValue}`, {
      body: params,
      responseKind: 'json',
      redirect: 'manual'
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error('テンプレートの変更に失敗しました')
        }
        this.savedPresetDescriptionValue = editingDescription
        this.updatePresetControls()
        toast('テンプレートを変更しました！')
        this.closeModal()
      })
      .catch((error) => {
        console.warn(error)
        toast('テンプレートを変更できませんでした。', 'error')
      })
  }

  updatePresetControls() {
    const isPresetRegistered = this.presetIdValue > 0
    this.replaceReportActionTarget.classList.toggle(
      'is-hidden',
      !isPresetRegistered
    )
    this.openModalButtonTarget.textContent = isPresetRegistered
      ? 'テンプレート変更'
      : 'テンプレート登録'
    this.submitButtonTarget.textContent = isPresetRegistered ? '変更' : '登録'
    this.updateSubmitButtonState()
  }

  updateSubmitButtonState() {
    const editingDescription = this.presetInputTarget.value.trim()
    const savedDescription = this.savedPresetDescriptionValue.trim()

    const isValid =
      editingDescription !== '' && editingDescription !== savedDescription
    this.submitButtonTarget.disabled = !isValid
  }

  openPresetEditTab(e) {
    e.preventDefault()
    this.presetEditTabTarget.classList.add('is-active')
    this.previewTabTarget.classList.remove('is-active')
    this.presetEditPanelTarget.classList.add('is-active')
    this.previewPanelTarget.classList.remove('is-active')
  }

  openPreviewTab(e) {
    e.preventDefault()
    this.presetEditTabTarget.classList.remove('is-active')
    this.previewTabTarget.classList.add('is-active')
    this.presetEditPanelTarget.classList.remove('is-active')
    this.previewPanelTarget.classList.add('is-active')
  }
}
