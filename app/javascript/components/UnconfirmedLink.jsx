import React from 'react'

export default class UnconfirmedLink extends React.Component {
  openUnconfirmedItems() {
    const links = document.querySelectorAll(
      '.card-list-item .js-unconfirmed-link'
    )
    links.forEach((link) => {
      window.open(link.href, '_target', 'noopener')
    })
  }

  render() {
    return (
      <div className="card-footer">
        <div className="card-main-actions">
         <ul className="card-main-actions__items">
           <li className="card-main-actions__item">
             <button className="thread-unconfirmed-links-form__action a-button is-block is-sm is-secondary"
              onClick={() => this.openUnconfirmedItems()}
            >{this.props.label}</button>
            </li>
          </ul>
        </div>
      </div>
    )
  }
}
