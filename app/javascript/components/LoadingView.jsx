import React from 'react'

const LoadingView = () => {
  return (
    <div className="admin-table is-loading">
      <table className="admin-table__table">
        <thead className="admin-table__header">
          <tr className="admin-table__labels">
            {[...Array(3)].map((_, index) => (
              <th key={index} className="admin-table__label">
                <div className="a-placeholder"></div>
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="admin-table__items">
          {[...Array(12)].map((_, rowIndex) => (
            <tr key={rowIndex} className="admin-table__item">
              {[...Array(3)].map((_, cellIndex) => (
                <td key={cellIndex} className="admin-table__item-value">
                  <div className="a-placeholder"></div>
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
export default LoadingView
