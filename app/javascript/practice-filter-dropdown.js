import Choices from 'choices.js'

export default class {
  constructor(practices, practiceId, setPracticeId) {
    this.practices = practices
    this.practiceId = practiceId
    this.setPracticeId = setPracticeId
    this.choices = null
    this.selectElement = null
    this.handleSelectChange = null
  }

  render(element) {
    element.innerHTML = `
        <nav class="page-filter form">
          <div class="container is-md">
            <div class="form-item is-inline-md-up">
              <label class="a-form-label" for="js-choices-single-select">
                プラクティスで絞り込む
              </label>
              <select class="a-form-select" id="js-choices-single-select">
              </select>
            </div>
          </div>
        </nav>
        <hr class="a-border">
    `

    this.selectElement = element.querySelector('#js-choices-single-select')

    const defaultOption = document.createElement('option')
    defaultOption.value = ''
    defaultOption.textContent = '全ての日報を表示'
    this.selectElement.appendChild(defaultOption)

    this.practices.forEach((practice) => {
      const option = document.createElement('option')
      option.value = practice.id
      option.textContent = practice.title
      this.selectElement.appendChild(option)
    })

    this.choices = new Choices(this.selectElement, {
      searchEnabled: true,
      allowHTML: true,
      searchResultLimit: 20,
      searchPlaceholderValue: '検索ワード',
      noResultsText: '一致する情報は見つかりません',
      itemSelectText: '選択',
      shouldSort: false
    })

    if (this.practiceId) {
      this.choices.setChoiceByValue(this.practiceId)
    }

    this.handleSelectChange = (event) => {
      const value = event.target.value
      this.setPracticeId(value)
    }

    this.selectElement.addEventListener('change', this.handleSelectChange)
  }

  destroy() {
    if (this.selectElement && this.handleSelectChange) {
      this.selectElement.removeEventListener('change', this.handleSelectChange)
    }
    if (this.choices) {
      this.choices.destroy()
      this.choices = null
    }
    this.selectElement = null
    this.handleSelectChange = null
  }
}
