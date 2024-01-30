import React from 'react'

const MentorPageLoadingView = ({ rows, columns }) => {
  const renderTableLabels = () => (
    <thead className="admin-table__header">
      <tr className="admin-table__labels">
        {[...Array(columns)].map((_, index) => (
          <th key={index} className="admin-table__label">
            <div className="a-placeholder"></div>
          </th>
        ))}
      </tr>
    </thead>
  )

  const renderTableItems = () => (
    <tbody className="admin-table__items">
      {[...Array(rows)].map((_, rowIndex) => (
        <tr key={rowIndex} className="admin-table__item">
          {[...Array(columns)].map((_, columnIndex) => (
            <td key={columnIndex} className="admin-table__item-value">
              <div className="a-placeholder"></div>
            </td>
          ))}
        </tr>
      ))}
    </tbody>
  )

  return (
    <div className="admin-table is-loading">
      <table className="admin-table__table">
        {renderTableLabels()}
        {renderTableItems()}
      </table>
    </div>
  )
}

export default MentorPageLoadingView
