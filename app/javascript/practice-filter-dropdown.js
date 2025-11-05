import Choices from 'choices.js'

export default class PracticeFilterDropdown {
  constructor(practices, setPracticeId, practiceId) {
    this.practices = practices;
    this.setPracticeId = setPracticeId;
    this.practiceId = practiceId;
    this.choicesInstance = null;
  }

  render(targetElement) {
    targetElement.innerHTML = `
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

    const selectElement = targetElement.querySelector('#js-choices-single-select');

    const defaultOption = document.createElement("option");
    defaultOption.value = '';
    defaultOption.textContent = '全ての日報を表示';
    selectElement.appendChild(defaultOption);

    this.practices.forEach((practice) => {
      const option = document.createElement("option");
      option.value = practice.id;
      option.textContent = practice.title;
      selectElement.appendChild(option);
    })

    this.choicesInstance = new Choices(selectElement, {
      searchEnabled: true,
      allowHTML: true,
      searchResultLimit: 20,
      searchPlaceholderValue: '検索ワード',
      noResultsText: '一致する情報は見つかりません',
      itemSelectText: '選択',
      shouldSort: false
    })

    if (this.practiceId) {
      this.choicesInstance.setChoiceByValue(this.practiceId)
    }

    selectElement.addEventListener('change', (event) => {
      const value = event.target.value;
      this.setPracticeId(value)
    })
  }

  destroy() {
    if (this.choicesInstance) {
      this.choicesInstance.destroy()
      this.choicesInstance = null
    }
  }
}
