import { Controller } from '@hotwired/stimulus'
import TextareaInitializer from 'textarea-initializer'
import CSRF from 'csrf'
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
    'previewPanel'
  ]

  static values = {
    savedPresetDescription: String,
    presetId: Number,
    editing: Boolean,
    isEditingPresetValid: Boolean
  }

  connect() {
    if (this.reportInputTarget.value === '') {
      this.reportInputTarget.value = this.savedPresetDescriptionValue
    }
    this.savedPresetDescriptionValue = this.presetInputTarget.value
    TextareaInitializer.initialize('.js-report-content')
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
    if (this.editingValue === this.savedPresetDescriptionValue) {
      this.closeModal()
    } else {
      confirm('テンプレートを登録せずに終了しますか？') && this.closeModal()
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

  registerPreset(e) {
    e.preventDefault()
    const editingDescription = this.presetInputTarget.value

    if (
      editingDescription === '' ||
      editingDescription === this.savedPresetDescriptionValue
    ) {
      return null
    }

    const params = {
      report_preset: { description: editingDescription }
    }
    fetch('/api/report_presets', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': CSRF.getToken()
      },
      credentials: 'same-origin',
      redirect: 'manual',
      body: JSON.stringify(params)
    })
      .then((response) => {
        return response.json()
      })
      .then((createdPreset) => {
        this.savedPresetDescriptionValue = editingDescription
        this.presetIdValue = createdPreset.id
        toast('テンプレートを登録しました！')
        this.closeModal()
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  updatePreset(e) {
    e.preventDefault()
    const editingDescription = this.presetInputTarget.value
    if (
      editingDescription === '' ||
      editingDescription === this.savedPresetDescriptionValue
    ) {
      return null
    }

    const params = {
      report_preset: { description: editingDescription }
    }
    fetch(`/api/report_presets/${this.presetIdValue}`, {
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
      .then(() => {
        this.savedPresetDescriptionValue = editingDescription
        toast('テンプレートを変更しました！')
        this.closeModal()
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  openPresetEditTab(e) {
    e.preventDefault()
    this.editingValue = true
    this.presetEditTabTarget.classList.add('is-active')
    this.previewTabTarget.classList.remove('is-active')
    this.presetEditPanelTarget.classList.add('is-active')
    this.previewPanelTarget.classList.remove('is-active')
  }

  openPreviewTab(e) {
    e.preventDefault()
    this.editingValue = false
    this.presetEditTabTarget.classList.remove('is-active')
    this.previewTabTarget.classList.add('is-active')
    this.presetEditPanelTarget.classList.remove('is-active')
    this.previewPanelTarget.classList.add('is-active')
  }

  updateSubmitButtonState() {
    const editingDescription = this.presetInputTarget.value.trim()
    const savedPresetDescription = this.savedPresetDescriptionValue.trim()

    const isValid =
      editingDescription !== '' && editingDescription !== savedPresetDescription
    this.isEditingPresetValidValue = isValid
    this.submitButtonTarget.disabled = !isValid
  }
}
