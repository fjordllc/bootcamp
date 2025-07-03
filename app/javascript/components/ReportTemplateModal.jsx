import React, { useState, useEffect } from 'react'
import TextareaInitializer from '../textarea-initializer'
import CSRF from '../csrf'
import { toast } from '../vanillaToast'

export default function ReportTemplateModal({
  registeredTemplate,
  setRegisteredTemplate,
  registeredTemplateId,
  setRegisteredTemplateId,
  isTemplateRegistered,
  closeModal
}) {
  const [isEditing, setIsEditing] = useState(true)
  const [editingTemplate, setEditingTemplate] = useState(registeredTemplate)

  useEffect(() => {
    TextareaInitializer.initialize('#js-template-content')
  }, [])

  const isEditingTemplateValid =
    editingTemplate !== '' && editingTemplate !== registeredTemplate

  const clickOutsideModal = (e) => {
    if (e.target !== e.currentTarget) {
      return
    }

    if (editingTemplate === registeredTemplate) {
      closeModal()
    } else {
      confirm('テンプレートを登録せずに終了しますか？') && closeModal()
    }
  }

  const clickTemplateTab = () => {
    setIsEditing(true)
  }

  const clickPreviewTab = () => {
    setIsEditing(false)
  }

  const registerTemplate = (e) => {
    e.preventDefault()
    if (!isEditingTemplateValid) {
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
        setRegisteredTemplate(editingTemplate)
        setRegisteredTemplateId(newTemplate.id)
        toast('テンプレートを登録しました！')
        closeModal()
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  const updateTemplate = (e) => {
    e.preventDefault()
    if (!isEditingTemplateValid) {
      return null
    }

    const params = {
      report_template: { description: editingTemplate }
    }
    fetch(`/api/report_templates/${registeredTemplateId}`, {
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
        setRegisteredTemplate(editingTemplate)
        toast('テンプレートを登録しました！')
        closeModal()
      })
      .catch((error) => {
        console.warn(error)
      })
  }

  return (
    <div className="a-overlay is-js" onClick={clickOutsideModal}>
      <div className="a-card is-modal">
        <header className="card-header is-sm">
          <h1 className="card-header__title">日報テンプレート</h1>
        </header>
        <hr className="a-border" />
        <div className="a-form-tabs js-tabs">
          <div
            className={`a-form-tabs__tab js-tabs__tab ${
              isEditing ? 'is-active' : ''
            }`}
            onClick={clickTemplateTab}>
            テンプレート
          </div>
          <div
            className={`a-form-tabs__tab js-tabs__tab ${
              isEditing ? '' : 'is-active'
            }`}
            onClick={clickPreviewTab}>
            プレビュー
          </div>
        </div>
        <div className="a-markdown-input js-markdown-parent">
          <div
            className={`a-markdown-input__inner js-tabs__content ${
              isEditing ? 'is-active' : ''
            }`}>
            <textarea
              className="a-text-input a-markdown-input__textare has-max-height"
              id="js-template-content"
              data-preview="#js-template-preview"
              value={editingTemplate}
              onChange={(e) => setEditingTemplate(e.target.value)}
              name="report_template[description]"></textarea>
          </div>
          <div
            className={`a-markdown-input__inner js-tabs__content a-long-text is-md a-markdown-input__preview ${
              isEditing ? '' : 'is-active'
            }`}
            id="js-template-preview"></div>
        </div>
        <footer className="card-footer">
          <div className="card-main-actions">
            <ul className="card-main-actions__items">
              {isTemplateRegistered ? (
                <li className="card-main-actions__item">
                  <button
                    className="a-button is-primary is-sm is-block"
                    disabled={!isEditingTemplateValid}
                    onClick={updateTemplate}>
                    変更
                  </button>
                </li>
              ) : (
                <li className="card-main-actions__item">
                  <button
                    className="a-button is-primary is-sm is-block"
                    disabled={!isEditingTemplateValid}
                    onClick={registerTemplate}>
                    登録
                  </button>
                </li>
              )}
              <li className="card-main-actions__item is-sub">
                <div
                  className="card-main-actions__muted-action"
                  onClick={closeModal}>
                  キャンセル
                </div>
              </li>
            </ul>
          </div>
        </footer>
      </div>
    </div>
  )
}
