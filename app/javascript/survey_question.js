document.addEventListener('DOMContentLoaded', () => {
  const radioButtonChoices = document.getElementsByName(
    'survey_question[question_format]'
  )
  const radioButtonElements = document.querySelectorAll('.radio_button')
  const checkBoxElements = document.querySelectorAll('.check_box')
  const linearScaleElements = document.querySelectorAll('.linear_scale')
  const radioButtonTitleOfReasonForChoice = document.getElementById(
    'survey_question_radio_button_attributes_title_of_reason_for_choice'
  )
  const checkBoxTitleOfReasonForChoice = document.getElementById(
    'survey_question_check_box_attributes_title_of_reason_for_choice'
  )
  const linearScaleTitleOfReasonForChoice = document.getElementById(
    'survey_question_linear_scale_attributes_title_of_reason_for_choice'
  )
  const radioButtonDescriptionOfReasonForChoice = document.getElementById(
    'survey_question_radio_button_attributes_description_of_reason_for_choice'
  )
  const checkBoxDescriptionOfReasonForChoice = document.getElementById(
    'survey_question_check_box_attributes_description_of_reason_for_choice'
  )
  const linearScaleDescriptionOfReasonForChoice = document.getElementById(
    'survey_question_linear_scale_attributes_description_of_reason_for_choice'
  )
  const startOfScale = document.getElementById(
    'survey_question_linear_scale_attributes_start_of_scale'
  )
  const endOfScale = document.getElementById(
    'survey_question_linear_scale_attributes_end_of_scale'
  )
  const reasonForChoiceRequired = document.getElementById(
    'survey_question_linear_scale_attributes_reason_for_choice_required'
  )

  radioButtonChoices.forEach((radioButtonChoice) => {
    radioButtonChoice.addEventListener('change', () => {
      const removeFieldsElements = document.querySelectorAll('.remove_fields')
      removeFieldsElements.forEach((removeFieldsElement) => {
        removeFieldsElement.click()
      })
      radioButtonTitleOfReasonForChoice.value = ''
      radioButtonDescriptionOfReasonForChoice.value = ''
      checkBoxTitleOfReasonForChoice.value = ''
      checkBoxDescriptionOfReasonForChoice.value = ''
      linearScaleTitleOfReasonForChoice.value = ''
      linearScaleDescriptionOfReasonForChoice.value = ''
      startOfScale.value = ''
      endOfScale.value = ''
      reasonForChoiceRequired.checked = false
      if (
        radioButtonChoice.value === 'text_field' ||
        radioButtonChoice.value === 'text_area'
      ) {
        radioButtonElements.forEach((radioButtonElement) => {
          radioButtonElement.classList.add('is-hidden')
        })
        checkBoxElements.forEach((checkBoxElement) => {
          checkBoxElement.classList.add('is-hidden')
        })
        linearScaleElements.forEach((linearScaleElement) => {
          linearScaleElement.classList.add('is-hidden')
        })
      } else if (radioButtonChoice.value === 'radio_button') {
        radioButtonElements.forEach((radioButtonElement) => {
          radioButtonElement.classList.remove('is-hidden')
        })
        checkBoxElements.forEach((checkBoxElement) => {
          checkBoxElement.classList.add('is-hidden')
        })
        linearScaleElements.forEach((linearScaleElement) => {
          linearScaleElement.classList.add('is-hidden')
        })
      } else if (radioButtonChoice.value === 'check_box') {
        radioButtonElements.forEach((radioButtonElement) => {
          radioButtonElement.classList.add('is-hidden')
        })
        checkBoxElements.forEach((checkBoxElement) => {
          checkBoxElement.classList.remove('is-hidden')
        })
        linearScaleElements.forEach((linearScaleElement) => {
          linearScaleElement.classList.add('is-hidden')
        })
      } else if (radioButtonChoice.value === 'linear_scale') {
        radioButtonElements.forEach((radioButtonElement) => {
          radioButtonElement.classList.add('is-hidden')
        })
        checkBoxElements.forEach((checkBoxElement) => {
          checkBoxElement.classList.add('is-hidden')
        })
        linearScaleElements.forEach((linearScaleElement) => {
          linearScaleElement.classList.remove('is-hidden')
        })
      }
    })
  })
})
