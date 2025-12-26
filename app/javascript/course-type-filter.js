export default class {
  constructor(courseType, setCourseType) {
    this.courseType = courseType
    this.setCourseType = setCourseType
    this.tabs = null
    this.handleSelect = null
  }

  render(element) {
    element.innerHTML = `
    <nav class="tab-nav">
      <ul class="tab-nav__items">
        <li class="tab-nav__item">
          <a class="tab-nav__item-link" href="#" data-course-type="all">全て</a>
        </li>
        <li class="tab-nav__item">
          <a class="tab-nav__item-link" href="#" data-course-type="grant">給付金コース</a>
        </li>
      </ul>
    </nav>
    `

    this.tabs = element.querySelectorAll('.tab-nav__item-link')

    this.tabs.forEach((tab) => {
      if (tab.dataset.courseType === this.courseType) {
        tab.classList.add('is-active')
      }
    })

    this.handleSelect = (event) => {
      event.preventDefault()
      const selectedTab = event.currentTarget
      this.tabs.forEach((tab) => {
        tab.classList.remove('is-active')
      })
      selectedTab.classList.add('is-active')
      this.setCourseType(selectedTab.dataset.courseType)
    }

    this.tabs.forEach((tab) => {
      tab.addEventListener('click', this.handleSelect)
    })
  }

  destroy() {
    if (!this.tabs || !this.handleSelect) return

    this.tabs.forEach((tab) => {
      tab.removeEventListener('click', this.handleSelect)
    })

    this.tabs = null
    this.handleSelect = null
  }
}
