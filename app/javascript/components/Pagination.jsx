import React, { useState, useRef, useEffect } from 'react'

const createRange = (a, z) => {
  const items = []
  for (let i = a; i <= z; i++) {
    items.push(i)
  }
  return items
}

const createNumbers = (current, neighbours, max) => {
  let first = current - neighbours
  let last = current + neighbours
  first = first < 1 ? 1 : first
  last = last > max ? max : last
  return createRange(first, last)
}

const Pagination = (props) => {
  const isFirstRender = useRef(true)
  const [page, setPage] = useState(props.page)
  const [numbers, setNumbers] = useState([])
  const totalPage = Math.ceil(props.sum / props.per)

  useEffect(() => {
    setNumbers(createNumbers(page, props.neighbours, totalPage))

    // 初回レンダリング時はスキップし、変数を更新する
    if (isFirstRender.current) {
      isFirstRender.current = false
      return;
    }

    props.onChange({ page: page })
  }, [page])

  return (
    <nav className="pagination">
      {totalPage !== 0 && (
        <ul className="pagination__items">
          <First page={page} setPage={setPage} />
          <Prev page={page} setPage={setPage} />
          {numbers[0] > 1 && (
            <ThreeDots />
          )}
          {numbers.map(i => {
            return <Number key={i} page={page} setPage={setPage} i={i} />
          })}
          {numbers[numbers.length - 1] < totalPage && (
            <ThreeDots />
          )}
          <Next page={page} setPage={setPage} totalPage={totalPage} />
          <Last page={page} setPage={setPage} totalPage={totalPage} />
        </ul>
      )}
    </nav>
  )
}

const First = ({ setPage, page }) => {
  const disabled = page === 1 ? ' is-disabled' : ''

  return (
    <li className={'pagination__item is-prev' + disabled}>
      <button
        onClick={() => setPage(1)}
        className={'pagination__item-link' + disabled}
      >
        <i className="fas fa-angle-double-left" />
      </button>
    </li>
  )
}

const Prev = ({ page, setPage }) => {
  const disabled = page === 1 ? ' is-disabled' : ''

  return (
    <li className={'pagination__item is-prev' + disabled}>
      <button
        onClick={() => (page !== 1) && setPage(page - 1)}
        className={'pagination__item-link' + disabled}
      >
        <i className="fas fa-angle-left" />
      </button>
    </li>
  )
}

const Number = ({ page, setPage, i }) => {
  return (
    <li className="pagination__item">
      <button
        onClick={() => setPage(i)}
        className={'pagination__item-link' + (i === page ? ' is-active' : '')}
      >
        {i}
      </button>
    </li>
  )
}

const Next = ({ page, setPage, totalPage }) => {
  const disabled = page === totalPage ? ' is-disabled' : ''

  return (
    <li className={'pagination__item is-next' + disabled}>
      <button
        onClick={() => page !== totalPage && setPage(page + 1)}
        className={'pagination__item-link' + disabled}
      >
        <i className="fas fa-angle-right" />
      </button>
    </li>
  )
}

const Last = ({ page, setPage, totalPage }) => {
  const disabled = page === totalPage ? ' is-disabled' : ''

  return (
    <li className={'pagination__item is-next' + disabled}>
      <button
        onClick={() => setPage(totalPage)}
        className={'pagination__item-link' + disabled}
      >
        <i className="fas fa-angle-double-right" />
      </button>
    </li>
  )
}

const ThreeDots = () => {
  return (
    <li className="pagination__item is-disabled">
      <div className="pagination__item-link">…</div>
    </li>
  )
}

export default Pagination
