import React, { useState, useEffect, useRef } from 'react'
import Choices from 'choices.js'

export default function PracticeFilterDropdown({
  practices,
  setPracticeId,
  practiceId
}) {
  const [selectedId, setSelectedId] = useState(practiceId)

  const onChange = (event) => {
    const value = event.target.value
    setSelectedId(value)
    setPracticeId(value)
  }

  const selectRef = useRef(null)

  useEffect(() => {
    const selectElement = selectRef.current
    const choicesInstance = new Choices(selectElement, {
      searchEnabled: true,
      allowHTML: true,
      searchResultLimit: 20,
      searchPlaceholderValue: '検索ワード',
      noResultsText: '一致する情報は見つかりません',
      itemSelectText: '選択',
      shouldSort: false
    })

    return () => {
      choicesInstance.destroy()
    }
  }, [])

  return (
    <>
      <nav className="page-filter form">
        <div className="container is-md">
          <div className="form-item is-inline-md-up">
            <label className="a-form-label" htmlFor="js-choices-single-select">
              プラクティスで絞り込む
            </label>
            <select
              className="a-form-select"
              onChange={onChange}
              ref={selectRef}
              value={selectedId}
              id="js-choices-single-select">
              <option key="" value="">
                全ての日報を表示
              </option>
              {practices.map((practice) => {
                return (
                  <option key={practice.id} value={practice.id}>
                    {practice.title}
                  </option>
                )
              })}
            </select>
          </div>
        </div>
      </nav>
    </>
  )
}
