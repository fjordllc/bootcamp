import { useEffect, useState } from 'react'
import queryString from 'query-string'

const usePage = () => {
  const defaultPage = parseInt(queryString.parse(location.search).page) || 1
  const [page, setPage] = useState(defaultPage)

  const getPageQueryParam = () => {
    return parseInt(queryString.parse(location.search).page) || 1
  }

  useEffect(() => {
    const handlePopstate = () => {
      setPage(getPageQueryParam())
    }
    window.addEventListener('popstate', handlePopstate)
    return () => {
      window.removeEventListener('popstate', handlePopstate)
    }
  }, [])

  return { page, setPage }
}

export default usePage
