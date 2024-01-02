import React from 'react'
import ReactPaginate from 'react-paginate'

export default function Pager({
  initialPageNumber,
  pageCount,
  pageRange,
  clickHandle
}) {
  const makeITag = (iconName) => {
    return `<i class='fas fa-angle-${iconName}'></i>`
  }

  return (
    <ReactPaginate
      forcePage={initialPageNumber - 1}
      pageCount={pageCount}
      pageRangeDisplayed={pageRange}
      onPageChange={clickHandle}
      previousLabel={makeITag('left')}
      nextLabel={makeITag('right')}
      breakLabel={'...'}
      breakClassName={'break-me'}
      marginPagesDisplayed={0}
      containerClassName={'pagination__items'}
      pageClassName={'pagination__item'}
      pageLinkClassName={'pagination__item-link'}
      previousClassName={'pagination__item is-prev'}
      previousLinkClassName={'pagination__item-link is-prev'}
      nextClassName={'pagination__item is-next'}
      nextLinkClassName={'pagination__item-link is-next'}
      activeClassName={'is-active'}
      disabledClassName={'is-disabled'}
    />
  )
}
