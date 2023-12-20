import React, { useState, useEffect } from 'react'
import ReportTemplateModal from './ReportTemplateModal'
import TextareaInitializer from '../textarea-initializer'

export default function ReportTemplate({ templateDescription, templateId }) {
  const [registeredTemplate, setRegisteredTemplate] = useState(
    templateDescription !== null ? templateDescription : ''
  )
  const [isTemplateRegistered, setIsTemplateRegistered] = useState(
    templateDescription !== null
  )
  const [editingTemplate, setEditingTemplate] = useState(registeredTemplate)
  const [showModal, setShowModal] = useState(false)

  useEffect(() => {
    const report = document.querySelector('#report_description')
    if (report.value === '') {
      report.value = registeredTemplate
      TextareaInitializer.initialize('.js-report-content')
    }
  }, [])

  const replaceReport = (e) => {
    e.preventDefault()
    const report = document.querySelector('#report_description')
    if (
      report.value === '' ||
      confirm('日報が上書きされますが、よろしいですか？')
    ) {
      report.value = registeredTemplate
      TextareaInitializer.uninitialize('.js-report-content')
      TextareaInitializer.initialize('.js-report-content')
    }
  }

  const openModal = (e) => {
    e.preventDefault()
    setShowModal(true)
  }

  const closeModal = () => {
    setShowModal(false)
  }

  return (
    <div className="form-item-actions">
      <ul className="form-item-actions__items">
        {isTemplateRegistered && (
          <li className="form-item-actions__item">
            <a
              className="form-item-actions__text-link is-danger"
              onClick={replaceReport}>
              テンプレートを反映する
            </a>
          </li>
        )}
        {isTemplateRegistered ? (
          <li className="form-item-actions__item">
            <button
              className="a-button is-sm is-secondary is-block"
              onClick={openModal}>
              テンプレート変更
            </button>
          </li>
        ) : (
          <li>
            <button
              className="a-button is-sm is-secondary is-block"
              onClick={openModal}>
              テンプレート登録
            </button>
          </li>
        )}
      </ul>
      {showModal && (
        <ReportTemplateModal
          templateId={templateId}
          setRegisteredTemplate={setRegisteredTemplate}
          isTemplateRegistered={isTemplateRegistered}
          setIsTemplateRegistered={setIsTemplateRegistered}
          editingTemplate={editingTemplate}
          setEditingTemplate={setEditingTemplate}
          closeModal={closeModal}
        />
      )}
    </div>
  )
}
