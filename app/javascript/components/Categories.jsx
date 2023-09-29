import React from 'react'
import useSWR from 'swr'
import fetcher from '../fetcher'

const Categories = () => {
  const { data, error } = useSWR(`/api/categories.json`, fetcher)
  if (error) return <>エラーが発生しました。</>
  if (!data) return <>ロード中…</>

  return (
    <div className="admin-table is-grab">
      <table className="admin-table__table">
        <thead className="admin-table__header">
          <tr className="admin-table__labels">
            <th className="admin-table__label">名前</th>
            <th className="admin-table__label">URLスラッグ</th>
            <th className="admin-table__label">操作</th>
          </tr>
        </thead>
        <tbody className="admin-table__items">
          {data.map((category) => {
            return <Category key={category.id} category={category} />
          })}
        </tbody>
      </table>
    </div>
  )
}

const Category = ({ category }) => {
  return (
    <tr className="admin-table__item">
      <td className="admin-table__item-value">
        <a href={`/mentor/categories/${category.id}`}>{category.name}</a>
      </td>
      <td className="admin-table__item-value">{category.slug}</td>
      <td className="admin-table__item-value is-text-align-center">
        <ul className="is-inline-buttons">
          <li>
            <a
              href={`/mentor/categories/${category.id}/edit`}
              className="a-button is-sm is-secondary is-icon spec-edit">
              <i className="fa-solid fa-pen" />
            </a>
          </li>
          <li>
            <a
              href={`/mentor/categories/${category.id}/practices`}
              className="a-button is-sm is-secondary is-icon is-block">
              <i className="fa-solid fa-align-justify" />
            </a>
          </li>
        </ul>
      </td>
    </tr>
  )
}

export default Categories
