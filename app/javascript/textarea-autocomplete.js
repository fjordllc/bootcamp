import Tribute from 'tributejs'
import TextareaAutocomplteEmoji from 'classes/textarea-autocomplte-emoji'
import TextareaAutocomplteMention from 'classes/textarea-autocomplte-mention'

document.addEventListener('DOMContentLoaded', () => {
  const textareas = document.querySelectorAll('.js-markdown')

  if (textareas.length === 0) { return }

  const emoji = new TextareaAutocomplteEmoji()
  const mention = new TextareaAutocomplteMention()

  mention.fetchValues(json => {
    mention.values = json
    const collection = [emoji.params(), mention.params()]
    const tribute = new Tribute({ collection: collection })
    tribute.attach(textareas)
  })
})
