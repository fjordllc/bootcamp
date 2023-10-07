import React from 'react'
import LoadingListPlaceholder from '../LoadingListPlaceholder'
import EmptyMessage from '../ui/EmptyMessage'
import { UserGroup, UserGroupHeader, UserGroupIcons } from '../ui/UserGroup'
import useSWR from 'swr'
import fetcher from '../../fetcher'
import useSearchParams from '../../hooks/useSearchParams'

function Region({ region, areas, handleClick }) {
  return (
    <li key={region}>
      <h2>{region}</h2>
      <ul>
        {Object.keys(areas).map((area) => (
          <li key={area}>
            <button onClick={() => handleClick(region, area)}>
              {`${area}（${areas[area]})`}
            </button>
          </li>
        ))}
      </ul>
    </li>
  )
}

export default function Areas({ userCounts }) {
  const [searchParams, setSearchParams] = useSearchParams({ area: '東京都' })
  const apiUrl = '/api/users/areas?'
  const { data: users, error, mutate } = useSWR(apiUrl + searchParams, fetcher)

  const handleClick = async (region, area) => {
    const searchParams = new URLSearchParams({ region, area })
    const newUsers = await fetcher(apiUrl + searchParams).catch((error) => {
      console.error(error)
    })
    mutate(newUsers)
    setSearchParams({ region, area })
  }

  const onPopstate = async () => {
    const search = new URL(location).searchParams
    const newUsers = await fetcher(apiUrl + search).catch((error) => {
      console.error(error)
    })
    mutate(newUsers)
  }

  React.useEffect(() => {
    window.addEventListener('popstate', onPopstate)
    return () => window.removeEventListener('popstate', onPopstate)
  }, [onPopstate])

  if (error) return console.warn(error)
  if (!users) {
    return (
      <div className="page-body">
        <div className="container is-md">
          <LoadingListPlaceholder />
        </div>
      </div>
    )
  }

  return (
    <div className="page-body">
      <div className="container is-lg">
        <section>
          <ul>
            {Object.keys(userCounts).map((region) => (
              <Region
                key={region}
                region={region}
                areas={userCounts[region]}
                handleClick={handleClick}
              />
            ))}
          </ul>
        </section>
        <section className="a-card">
          {users.length > 0 ? (
            <UserGroup>
              <UserGroupHeader>{searchParams.get('area')}</UserGroupHeader>
              <UserGroupIcons users={users} />
            </UserGroup>
          ) : (
            <EmptyMessage>都道府県別ユーザー一覧はありません</EmptyMessage>
          )}
        </section>
      </div>
    </div>
  )
}
