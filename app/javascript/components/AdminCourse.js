import React from 'react'

export default function AdminCourse(props) {
  const course = props.course
  const url = `/courses/${course.id}/practices`
  const editUrl = `/admin/courses/${course.id}/edit`
  const sortUrl = `/courses/${course.id}/categories`

  return (
    <tr className="admin-table__item">
      <td className="admin-table__item-value">
        <a href={url}>{course.title}</a> 
      </td>
      <td className="admin-table__item-value">
        {course.description}
      </td>
      <td className="admin-table__item-value admin-table__item-value is-text-align-center">
        <ul className="is-inline-buttons">
          <li>
            <a href={editUrl} className="a-button is-sm is-secondary is-icon is-block">
              <i className="fa fa-solid fa-pen" />
            </a>
          </li>
          <li>
            <a href={sortUrl} className="a-button is-sm is-secondary is-icon is-block">
              <i className="fa-solid fa-align-justify" />
            </a>
          </li>
        </ul>
      </td>
    </tr>
  )
}
