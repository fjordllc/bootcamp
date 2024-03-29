import React from 'react'

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

const Pagination = ({ sum, per, neighbours = 4, page, setPage }) => {
  const totalPage = Math.ceil(sum / per)
  const numbers = createNumbers(page, neighbours, totalPage)
  const handlePaginate = (pageNumber) => {
    setPage(pageNumber)
    const url = new URL(location)
    if (pageNumber > 1) {
      url.searchParams.set('page', pageNumber)
    } else {
      url.searchParams.delete('page')
    }
    window.history.pushState(null, null, url)
    window.scrollTo(0, 0)
  }

  return (
    <nav className="pagination">
      {totalPage !== 0 && (
        <ul className="pagination__items">
          <First page={page} handlePaginate={handlePaginate} />
          <Prev page={page} handlePaginate={handlePaginate} />
          {numbers[0] > 1 && <ThreeDots />}
          {numbers.map((i) => {
            return (
              <Number
                key={i}
                page={page}
                handlePaginate={handlePaginate}
                i={i}
              />
            )
          })}
          {numbers[numbers.length - 1] < totalPage && <ThreeDots />}
          <Next
            page={page}
            handlePaginate={handlePaginate}
            totalPage={totalPage}
          />
          <Last
            page={page}
            handlePaginate={handlePaginate}
            totalPage={totalPage}
          />
        </ul>
      )}
    </nav>
  )
}

const First = ({ page, handlePaginate }) => {
  const disabled = page === 1 ? ' is-disabled' : ''

  return (
    <li className={'pagination__item is-prev' + disabled}>
      <button
        onClick={() => handlePaginate(1)}
        className={'pagination__item-link' + disabled}>
        <i className="fas fa-angle-double-left" />
      </button>
    </li>
  )
}

const Prev = ({ page, handlePaginate }) => {
  const disabled = page === 1 ? ' is-disabled' : ''

  return (
    <li className={'pagination__item is-prev' + disabled}>
      <button
        onClick={() => page !== 1 && handlePaginate(page - 1)}
        className={'pagination__item-link' + disabled}>
        <i className="fas fa-angle-left" />
      </button>
    </li>
  )
}

const Number = ({ page, handlePaginate, i }) => {
  return (
    <li className="pagination__item">
      <button
        onClick={() => handlePaginate(i)}
        className={'pagination__item-link' + (i === page ? ' is-active' : '')}>
        {i}
      </button>
    </li>
  )
}

const Next = ({ page, handlePaginate, totalPage }) => {
  const disabled = page === totalPage ? ' is-disabled' : ''

  return (
    <li className={'pagination__item is-next' + disabled}>
      <button
        onClick={() => page !== totalPage && handlePaginate(page + 1)}
        className={'pagination__item-link' + disabled}>
        <i className="fas fa-angle-right" />
      </button>
    </li>
  )
}

const Last = ({ page, handlePaginate, totalPage }) => {
  const disabled = page === totalPage ? ' is-disabled' : ''

  return (
    <li className={'pagination__item is-next' + disabled}>
      <button
        onClick={() => handlePaginate(totalPage)}
        className={'pagination__item-link' + disabled}>
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
