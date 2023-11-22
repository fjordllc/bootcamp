import React from 'react'
import clsx from 'clsx'

export const MultiColumns = ({
  className,
  children,
  isReverse = false,
  ...props
}) => {
  return (
    <div className={clsx('page-body', className)} {...props}>
      <div className="container is-lg">
        <div className={clsx('page-body__columns', isReverse && 'is-reverse')}>
          {children}
        </div>
      </div>
    </div>
  )
}

const MultiColumnsMain = ({ className, children, ...props }) => {
  return (
    <div className={clsx('page-body__column is-main', className)} {...props}>
      {children}
    </div>
  )
}

const MultiColumnsSub = ({ className, children, ...props }) => {
  return (
    <div className={clsx('page-body__column is-sub', className)} {...props}>
      {children}
    </div>
  )
}

MultiColumns.Main = MultiColumnsMain
MultiColumns.Sub = MultiColumnsSub
