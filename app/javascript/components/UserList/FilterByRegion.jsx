import React from 'react'
import LoadingListPlaceholder from '../LoadingListPlaceholder'
import EmptyMessage from '../ui/EmptyMessage'
import { UserGroup } from '../ui/UserGroup'
import useSWR from 'swr'
import fetcher from '../../fetcher'
import { useSearchParams, usePopstate } from '../../hooks/useSearchParams'

function Region({ region, numberOfUsersByRegion, handleClick }) {
  return (
    <nav key={region} className="page-nav a-card">
      <header className="page-nav__header">
        <h2 className="page-nav__title">
          <span className="page-nav__title-inner">{region}</span>
        </h2>
      </header>
      <hr className="a-border-tint"></hr>
      <ul className="page-nav__items">
        {Object.keys(numberOfUsersByRegion).map((subdivisionOrCountry) => (
          <li key={subdivisionOrCountry} className="page-nav__item">
            <button
              onClick={() => handleClick(region, subdivisionOrCountry)}
              className="page-nav__item-link a-text-link">
              {`${subdivisionOrCountry}（${numberOfUsersByRegion[subdivisionOrCountry]})`}
            </button>
          </li>
        ))}
      </ul>
    </nav>
  )
}

/**
 * 都道府県を指定しないデフォルトでは東京都が選択されます
 */
export default function FilterByRegion({ numberOfUsersByRegion }) {
  const [searchParams, setSearchParams] = useSearchParams({ subdivision_or_country: '東京都' })
  const apiUrl = '/api/users/regions?'
  const { data: users, error, mutate } = useSWR(apiUrl + searchParams, fetcher)

  const handleClick = async (region, subdivisionOrCountry) => {
    const search = new URLSearchParams({ region, subdivision_or_country: subdivisionOrCountry })
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

  if (error) return <>エラーが発生しました。</>
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
    <div data-testid="regions" className="page-body">
      <div className="container is-lg">
        <div className="page-body__columns is-reverse">
          <div className="page-body__column is-sub is-sm">
            {Object.keys(numberOfUsersByRegion).map((region) => (
              <Region
                key={region}
                region={region}
                numberOfUsersByRegion={numberOfUsersByRegion[region]}
                handleClick={handleClick}
              />
            ))}
          </div>
          <div className="page-body__column is-main">
            <section className="a-card">
              {users.length > 0 ? (
                <UserGroup>
                  <UserGroup.Header>
                    {searchParams.get('subdivision_or_country') || '東京都'}
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
