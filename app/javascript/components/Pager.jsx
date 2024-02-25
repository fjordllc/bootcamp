import React from 'react'
import ReactPaginate from 'react-paginate'

export default function Pager({
  initialPageNumber,
  pageCount,
  pageRange,
  clickHandle
}) {
  const makeITag = (iconName) => <i className={`fas fa-angle-${iconName}`}></i>

  return (
    <div className="pagination-container">
      <button onClick={() => clickHandle(1)} className="pagination__item-link">
        {makeITag('double-left')}
      </button>

      <ReactPaginate
        forcePage={initialPageNumber - 1}
        pageCount={pageCount}
        pageRangeDisplayed={pageRange}
        marginPagesDisplayed={0}
        previousLabel={makeITag('left')}
        nextLabel={makeITag('right')}
        onPageChange={(e) => clickHandle(e.selected + 1)}
        containerClassName="pagination__items"
        pageClassName="pagination__item"
        pageLinkClassName="pagination__item-link"
        previousClassName="pagination__item is-prev"
        previousLinkClassName="pagination__item-link is-prev"
        nextClassName="pagination__item is-next"
        nextLinkClassName="pagination__item-link is-next"
        activeClassName="is-active"
        disabledClassName="is-disabled"
      />

      <button
        onClick={() => clickHandle(pageCount)}
        className="pagination__item-link">
        {makeITag('double-right')}
      </button>
    </div>
  )
}
