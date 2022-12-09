
document.addEventListener('DOMContentLoaded', () => {
  const Choices = Array.from(
    document.querySelectorAll('.a-toggle-checkbox')
  )

  Choices.forEach((choice) => {
    choice.addEventListener('click', () => {
      const additionalQuestionField = document.getElementsByName(`js-additional_question_${choice.name}`)
      if(
        !choice.classList.contains('js-answer_required_choice') &&
        choice.type !== 'checkbox'
        ) {
        additionalQuestionField[0].classList.add('is-hidden')
      }
    })
  })

  const answerRequiredChoices = Array.from(
    document.querySelectorAll('.js-answer_required_choice')
  )

  answerRequiredChoices.forEach((answerRequiredChoice) => {
    answerRequiredChoice.addEventListener('click', () => {
      const additionalQuestionField = document.getElementsByName(`js-additional_question_${answerRequiredChoice.name}`)
      if(answerRequiredChoice.checked) {
        additionalQuestionField[0].classList.remove('is-hidden')
      } else if(!answerRequiredChoice.checked && answerRequiredChoice.type === 'checkbox') {
        const choicesInSameQuestion = document.getElementsByName(answerRequiredChoice.name)
        const checkBoxStatuses = []
        choicesInSameQuestion.forEach((ChoiceInSameQuestion) => {
          if (ChoiceInSameQuestion.checked && ChoiceInSameQuestion.classList.contains('js-answer_required_choice')) {
            checkBoxStatuses.push(true)
          } else {
            checkBoxStatuses.push(false)
          }
        })
        if(checkBoxStatuses.includes(true)) {
          additionalQuestionField[0].classList.remove('is-hidden')
        } else {
          additionalQuestionField[0].classList.add('is-hidden')
        }
      }
    })
  })
})

