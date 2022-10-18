import React, { useState, useEffect } from 'react'
import useSWR, { useSWRConfig } from 'swr'
import fetcher from '../fetcher'
import Bootcamp from '../bootcamp'

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
            return (
              <Category
                key={category.id}
                category={category}
              />
            )
          })}
        </tbody>
      </table>
    </div>
  )
}

const Category = ({ category }) => {
  const { mutate } = useSWRConfig()

  const destroy = (id) => {
    if (window.confirm('本当によろしいですか？')) {
      Bootcamp.delete(`/api/categories/${id}`)
        .then((response) => {
          mutate('/api/categories.json')
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }

  return (
    <tr className="admin-table__item">
      <td className="admin-table__item-value">
        <a href={`/admin/categories/${category.id}`}>{category.name}</a>
      </td>
      <td className="admin-table__item-value">{category.slug}</td>
      <td className="admin-table__item-value is-text-align-center">
        <ul className="is-inline-buttons">
          <li>
            <a
              href={`/admin/categories/${category.id}/edit`}
              className="a-button is-sm is-secondary is-icon spec-edit"
            >
              <i className="fa-solid fa-pen" />
            </a>
          </li>
          <li>
            <button onClick={() => destroy(category.id)} className="a-button is-sm is-danger is-icon js-delete">
              <i className="fa-solid fa-trash-alt" />
            </button>
          </li>
        </ul>
      </td>
    </tr>
  )
}

export default Categories
