import React, { useState } from 'react'

import Pagination from './Pagination'

export default {
  component: Pagination,
  title: 'Pagination'
}

const Template = (args) => {
  const [page, setPage] = useState(1)

  const handlePaginate = (p) => {
    setPage(p)
  }

  return (
    <Pagination
      {...args}
      page={page}
      onChange={(e) => handlePaginate(e.page)}
    />
  )
}

export const Default = Template.bind({})

Default.args = {
  sum: 10 * 20,
  per: 20,
  neighbours: 4
}
