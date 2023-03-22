import React, { useState } from 'react'

import Pagination from './Pagination'

export default {
  component: Pagination,
  title: 'Components/Pagination'
}

export const Simple = (args) => {
  const [page, setPage] = useState(1)

  return (
    <Pagination
      {...args}
      page={page}
      onChange={(e) => setPage(e.page)}
    />
  )
}

Simple.args = {
  sum: 10 * 20,
  per: 20,
  neighbours: 4
}
