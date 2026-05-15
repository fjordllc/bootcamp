import { Controller } from 'stimulus'
import TextareaInitializer from '../textarea-initializer'
import CSRF from '../csrf'
import { toast } from '../vanillaToast'

export default class extends Controller {
  static targets = [
    'report',
    'modal',
    'templateInput',
    'submitButton',
    'templateTab',
    'previewTab',
    'templateContent',
    'previewContent'
  ]

  static values = {
    registeredTemplate: String,
    registeredTemplateId: Number,
    editing: Boolean,
    isEditingTemplateValid: Boolean
  }

  connect() {
    if (this.reportTarget.value === '') {
      this.reportTarget.value = this.registeredTemplateValue
    }
    this.registeredTemplateValue = this.templateInputTarget.value
    TextareaInitializer.initialize('.js-report-content')
  }

  replaceReport(e) {
    e.preventDefault()
    if (
      this.reportTarget.value === '' ||
      confirm('日報が上書きされますが、よろしいですか？')
    ) {
      this.reportTarget.value = this.registeredTemplateValue
      TextareaInitializer.uninitialize('.js-report-content')
      TextareaInitializer.initialize('.js-report-content')
    }
  }

  clickOutside(e) {
    if (e.target !== e.currentTarget) {
      return
    }
    if (this.editingValue === this.registeredTemplateValue) {
      this.closeModal()
    } else {
      confirm('テンプレートを登録せずに終了しますか？') && this.closeModal()
    }
  }

  openModal(e) {
    e.preventDefault()
    this.modalTarget.classList.remove('is-hidden')
    this.templateInputTarget.value = this.registeredTemplateValue
    TextareaInitializer.initialize('#js-template-content')
    this.updateSubmitButtonState()
  }

  closeModal() {
    this.modalTarget.classList.add('is-hidden')
  }

  registerTemplate(e) {
    e.preventDefault()
    const editingTemplate = this.templateInputTarget.value

    if (
      editingTemplate === '' ||
      editingTemplate === this.registeredTemplateValue
    ) {
      return null
    }

    const params = {
      report_template: { description: editingTemplate }
    }
    fetch('/api/report_templates', {
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
      .then((newTemplate) => {
        this.registeredTemplateValue = editingTemplate
        this.registeredTemplateIdValue = newTemplate.id
        toast('テンプレートを登録しました！')
        this.closeModal()
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  updateTemplate(e) {
    e.preventDefault()
    const editingTemplate = this.templateInputTarget.value
    if (
      editingTemplate === '' ||
      editingTemplate === this.registeredTemplateValue
    ) {
      return null
    }

    const params = {
      report_template: { description: editingTemplate }
    }
    fetch(`/api/report_templates/${this.registeredTemplateIdValue}`, {
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
        this.registeredTemplateValue = editingTemplate
        toast('テンプレートを変更しました！')
        this.closeModal()
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  clickTemplateTab(e) {
    e.preventDefault()
    this.editingValue = true
    this.templateTabTarget.classList.add('is-active')
    this.previewTabTarget.classList.remove('is-active')
    this.templateContentTarget.classList.add('is-active')
    this.previewContentTarget.classList.remove('is-active')
  }

  clickPreviewTab(e) {
    e.preventDefault()
    this.editingValue = false
    this.templateTabTarget.classList.remove('is-active')
    this.previewTabTarget.classList.add('is-active')
    this.templateContentTarget.classList.remove('is-active')
    this.previewContentTarget.classList.add('is-active')
  }

  updateSubmitButtonState() {
    const editingTemplate = this.templateInputTarget.value.trim()
    const registeredTemplate = this.registeredTemplateValue.trim()

    const isValid =
      editingTemplate !== '' && editingTemplate !== registeredTemplate
    this.isEditingTemplateValidValue = isValid
    this.submitButtonTarget.disabled = !isValid
  }
}
