import React from 'react'
import LoadingListPlaceholder from '../LoadingListPlaceholder'
import EmptyMessage from '../ui/EmptyMessage'
import { UserGroup } from '../ui/UserGroup'
import useSWR from 'swr'
import fetcher from '../../fetcher'
import { useSearchParams, usePopstate } from '../../hooks/useSearchParams'

function Region({ region, numberOfUsersByRegion, handleClick }) {
  return (
    <li key={region} className="page-nav a-card">
      <div className="side-nav-block">
        <header class="page-nav__header">
          <h2 className="page-nav__title">
            <span className="page-nav__title-inner">{region}</span>
          </h2>
        </header>
        <hr className="a-border-tint"></hr>
        <ul className="page-nav__items">
          {Object.keys(numberOfUsersByRegion).map((area) => (
            <li key={area} className="page-nav__item">
              <button onClick={() => handleClick(region, area)} className="page-nav__item-link a-text-link">
                {`${area}（${numberOfUsersByRegion[area]})`}
              </button>
            </li>
          ))}
        </ul>
      </div>
    </li>
  )
}

export default function Areas({ numberOfUsers }) {
  const [searchParams, setSearchParams] = useSearchParams({ area: '東京都' })
  const apiUrl = '/api/users/areas?'
  const { data: users, error, mutate } = useSWR(apiUrl + searchParams, fetcher)

  const handleClick = async (region, area) => {
    const search = new URLSearchParams({ region, area })
    const newUsers = await fetcher(apiUrl + search).catch((error) => {
      console.error(error)
    })
    mutate(newUsers)
    setSearchParams(search)
  }

  usePopstate(async () => {
    const search = new URL(location).searchParams
    const newUsers = await fetcher(apiUrl + search).catch((error) => {
      console.error(error)
    })
    mutate(newUsers)
  })

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
    <div data-testid="areas" className="page-body">
      <div className="container is-lg">
        <div className="page-body__columns is-reverse">
          <div className="page-body__column is-sub is-sm">
            <nav className="side-nav">
              <ul className="side-nav-blocks">
                {Object.keys(numberOfUsers).map((region) => (
                  <Region
                    key={region}
                    region={region}
                    numberOfUsersByRegion={numberOfUsers[region]}
                    handleClick={handleClick}
                  />
                ))}
              </ul>
            </nav>
          </div>
          <div className="page-body__column is-main">
            <section className="a-card">
              {users.length > 0 ? (
                <UserGroup>
                  <UserGroup.Header>
                    {searchParams.get('area') || '東京都'}
                  </UserGroup.Header>
                  <UserGroup.Icons users={users} />
                </UserGroup>
              ) : (
                <EmptyMessage>都道府県別ユーザー一覧はありません</EmptyMessage>
              )}
            </section>
          </div>
        </div>
      </div>
    </div>
  )
}
