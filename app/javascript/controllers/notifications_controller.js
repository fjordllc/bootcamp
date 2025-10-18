import { Controller } from 'stimulus'

export default class extends Controller {
  openAll() {
    const links = document.querySelectorAll(
      '.card-list-item .js-unconfirmed-link'
    )
    links.forEach((link) => {
      window.open(link.href, '_blank', 'noopener')
    })
  }
}
