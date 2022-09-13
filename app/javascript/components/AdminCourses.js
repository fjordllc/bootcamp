import React from 'react'
import useSWR from 'swr'
import AdminCourse from 'components/AdminCourse'

const fetcher = (url) => fetch(url).then((res) => res.json())

export default function AdminCourses() {
  const { data, error } = useSWR('/api/courses.json', fetcher)
  if (error) return 'An error has occurred.'
  if (!data) return 'Loading...'
  const courses = data.courses

  return (
    <div className="page-body">
      <div className="container is-lg">
        <div className="admin-table">
          <table className="admin-table__table">
            <thead className="admin-table__header">
              <tr className="admin-table__labels">
                <td className="admin-table__label">コース名</td>
                <td className="admin-table__label">説明文</td>
                <td className="admin-table__label">操作</td>
              </tr>
            </thead>
            <tbody className="admin-table__items">
              {courses.map((course) => {
                return <AdminCourse key={course.id} course={course} />
              })}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
