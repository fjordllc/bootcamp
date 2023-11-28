import React from 'react'
import clsx from 'clsx'

const Card = ({ children, className }) => {
  return (
    <div className={clsx('a-card', className)}>
        {children}
    </div>
  )
}

Card.displayName = 'Card'

const CardHeader = ({ children, className }) => {
  return (
    <header className={clsx("card-header", className)}>
      {children}
    </header>
  )
}

CardHeader.displayName = 'CardHeader'

const CardFooter = ({ children, className }) => {
  return (
    <div className={clsx("card-footer", className)}>
      <div className="card-main-actions">
        <div className="card-main-actions__items">
          {children}
        </div>
      </div>
    </div>
  )
}

CardFooter.displayName = 'CardFooter'

const CardFooterItem = ({ children, className }) => {
  return (
    <div className={clsx("card-main-actions__item", className)}>
      {children}
    </div>
  )
}

CardFooter.displayName = 'CardFooterItem'

const Root = Card
const Header = CardHeader
const Footer = CardFooter
const FooterItem = CardFooterItem

export { Root, Header, Footer, FooterItem }
