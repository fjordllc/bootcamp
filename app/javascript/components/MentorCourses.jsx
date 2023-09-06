import React from 'react'
import useSWR from 'swr'
import fetcher from '../fetcher'

const Header = () => {
  return (
    <thead className="admin-table__header">
      <tr className="admin-table__labels">
        <td className="admin-table__label">コース名</td>
        <td className="admin-table__label">説明文</td>
        <td className="admin-table__label actions">操作</td>
      </tr>
    </thead>
  )
}

export default function MentorCourses() {
  const { data, error } = useSWR('/api/courses.json', fetcher)
  if (error) return <>An error has occurred.</>
  if (!data) return <>Loading...</>
  const courses = data.courses

  return (
    <div className="admin-table">
      <table className="admin-table__table">
        <Header />
        <tbody className="admin-table__items">
          {courses.map((course) => {
            return <MentorCourse key={course.id} course={course} />
          })}
        </tbody>
      </table>
    </div>
  )
}

function MentorCourse(props) {
  const course = props.course
  const url = `/courses/${course.id}/practices`
  const editUrl = `/mentor/courses/${course.id}/edit`
  const sortUrl = `/mentor/courses/${course.id}/categories`

  return (
    <tr className="admin-table__item">
      <td className="admin-table__item-value">
        <a href={url}>{course.title}</a>
      </td>
      <td className="admin-table__item-value">{course.description}</td>
      <td className="admin-table__item-value admin-table__item-value is-text-align-center">
        <ul className="is-inline-buttons">
          <li>
            <a
              href={editUrl}
              className="a-button is-sm is-secondary is-icon is-block">
              <i className="fa fa-solid fa-pen" />
            </a>
          </li>
          <li>
            <a
              href={sortUrl}
              className="a-button is-sm is-secondary is-icon is-block">
              <i className="fa-solid fa-align-justify" />
            </a>
          </li>
        </ul>
      </td>
    </tr>
  )
}
