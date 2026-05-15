import { checkProduct } from './checkable_react'

export class ProductChecker {
  constructor(checkerElement) {
    const { checkerId, checkerName, checkerAvatar, currentUserId, productId } =
      checkerElement.dataset

    this.element = checkerElement
    this.checkerId = checkerId
    this.checkerName = checkerName
    this.checkerAvatar = checkerAvatar
    this.currentUserId = currentUserId
    this.productId = productId
    this.isAssigned = Boolean(checkerId)
    this.isSelfAssigned = checkerId === currentUserId
  }

  initProductChecker() {
    this.element.innerHTML = ''
    if (!this.checkerId || this.isSelfAssigned) {
      this.generateActionButton()
    } else {
      this.generateAssigneeDisplay()
    }
  }

  updateButton(button, isAssigned) {
    button.innerHTML = ''
    const config = isAssigned
      ? { class: 'is-warning', icon: 'fa-times', label: '担当から外れる' }
      : { class: 'is-secondary', icon: 'fa-hand-paper', label: '担当する' }
    button.className = `a-button is-block ${config.class} is-sm`
    button.textContent = config.label
    const icon = document.createElement('i')
    icon.className = `fas ${config.icon}`
    button.appendChild(icon)
  }

  handleCheckerToggle(button) {
    const nextIsAssigned = !this.isAssigned
    this.updateButton(button, nextIsAssigned)

    checkProduct(
      this.productId,
      this.currentUserId,
      '/api/products/checker',
      this.isAssigned ? 'delete' : 'patch'
    )

    this.isAssigned = nextIsAssigned
  }

  generateActionButton() {
    const button = document.createElement('button')
    this.updateButton(button, this.isAssigned)
    this.element.appendChild(button)

    button.addEventListener('click', () => this.handleCheckerToggle(button))
  }

  generateAssigneeDisplay() {
    const container = document.createElement('div')
    container.className =
      'a-button is-sm is-block card-list-item__assignee-button is-only-mentor'

    const imgSpan = document.createElement('span')
    imgSpan.className = 'card-list-item__assignee-image'

    const img = document.createElement('img')
    img.className = 'a-user-icon'
    img.src = this.checkerAvatar
    img.width = '20'
    img.height = '20'
    img.alt = 'Checker Avatar'
    imgSpan.appendChild(img)

    const nameSpan = document.createElement('span')
    nameSpan.className = 'card-list-item__assignee-name'
    nameSpan.textContent = this.checkerName

    container.append(imgSpan, nameSpan)
    this.element.appendChild(container)
  }
}
