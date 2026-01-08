export default class {
  constructor(withGrant, setWithGrant) {
    this.withGrant = withGrant
    this.setWithGrant = setWithGrant
    this.tabs = null
    this.handleSelect = null
  }

  render(element) {
    element.innerHTML = `
    <nav class="pill-nav">
      <ul class="pill-nav__items">
        <li class="pill-nav__item">
          <button class="pill-nav__item-link" data-with-grant="false">全て</button>
        </li>
        <li class="pill-nav__item">
          <button class="pill-nav__item-link" data-with-grant="true">給付金コース</button>
        </li>
      </ul>
    </nav>
    `

    this.tabs = element.querySelectorAll('.pill-nav__item-link')

    this.tabs.forEach((tab) => {
      const tabWithGrant = tab.dataset.withGrant === 'true'
      if (tabWithGrant === this.withGrant) {
        tab.classList.add('is-active')
      }
    })

    this.handleSelect = (event) => {
      const selectedTab = event.currentTarget
      this.tabs.forEach((tab) => {
        tab.classList.remove('is-active')
      })
      selectedTab.classList.add('is-active')
      const tabWithGrant = selectedTab.dataset.withGrant === 'true'
      this.setWithGrant(tabWithGrant)
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
