import MarkdownInitializer from 'markdown-initializer'

export default function initializeAnswer(answer) {
  const events = new AbortController()
  const copyTimeouts = new Set()
  const listen = (element, event, callback) => {
    element.addEventListener(event, callback, { signal: events.signal })
  }
  const answerDescription = answer.dataset.answer_description
  const answerDisplay = answer.querySelector('.answer-display')
  const answerDisplayContent = answerDisplay.querySelector('.answer-text')
  if (answerDescription) {
    answerDisplayContent.innerHTML = new MarkdownInitializer().render(
      answerDescription
    )
  }

  const createdAtElement = answer.querySelector('.created-at')
  if (createdAtElement && navigator.clipboard) {
    listen(createdAtElement, 'click', () => {
      const answerURL = answer.dataset.answerUrl
      navigator.clipboard
        .writeText(answerURL)
        .then(() => {
          if (events.signal.aborted) return
          createdAtElement.classList.add('is-active')
          const copyTimeout = setTimeout(() => {
            createdAtElement.classList.remove('is-active')
            copyTimeouts.delete(copyTimeout)
          }, 4000)
          copyTimeouts.add(copyTimeout)
        })
        .catch((error) => {
          console.error(error)
        })
    })
  }

  return () => {
    events.abort()
    copyTimeouts.forEach((timeout) => clearTimeout(timeout))
    copyTimeouts.clear()
  }
}
