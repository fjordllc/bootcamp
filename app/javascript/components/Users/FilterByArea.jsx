import React from 'react'
// components
import LoadingListPlaceholder from '../LoadingListPlaceholder'
import EmptyMessage from '../ui/EmptyMessage'
import { UserGroup } from '../ui/UserGroup'
import { MultiColumns } from '../layout/MultiColumns'
// hooks
import { useSearchParams, usePopstate } from '../../hooks/useSearchParams'
import useSWR from 'swr'
// helper
import fetcher from '../../fetcher'

function RegionCard({ region, numberOfUsersByRegion, onUpdateSelectedArea }) {
  return (
    <nav className="page-nav a-card">
      <header className="page-nav__header">
        <h2 className="page-nav__title">
          <span className="page-nav__title-inner">{region}</span>
        </h2>
      </header>
      <hr className="a-border-tint"></hr>
      <ul className="page-nav__items">
        {Object.keys(numberOfUsersByRegion).map((area) => (
          <li key={area} className="page-nav__item">
            <button
              onClick={() => onUpdateSelectedArea({ region, area })}
              className="page-nav__item-link a-text-link">
              {`${area}（${numberOfUsersByRegion[area]})`}
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
export default function FilterByArea({ numberOfUsersByRegion }) {
  const { searchParams, setSearchParams } = useSearchParams({ area: '東京都' })
  const apiUrl = '/api/users/areas?'
  const { data: users, error, mutate } = useSWR(apiUrl + searchParams, fetcher)

  const handleUpdateSelectedArea = async ({ region, area }) => {
    const search = new URLSearchParams({ region, area })
    const newUsers = await fetcher(apiUrl + search).catch((error) => {
      console.error(error)
    })
    mutate(newUsers)
    setSearchParams(search)
  }

  usePopstate(async () => {
    const newUsers = await fetcher(apiUrl + searchParams).catch((error) => {
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
    <MultiColumns data-testid="areas" isReverse>
      {/* region毎に区分されたareaの選択一覧 */}
      <MultiColumns.Sub className="is-sm">
        {Object.keys(numberOfUsersByRegion).map((region) => (
          <RegionCard
            key={region}
            region={region}
            numberOfUsersByRegion={numberOfUsersByRegion[region]}
            onUpdateSelectedArea={handleUpdateSelectedArea}
          />
        ))}
      </MultiColumns.Sub>
      {/* 選択されたareaのユーザー一覧 */}
      <MultiColumns.Main>
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
      </MultiColumns.Main>
    </MultiColumns>
  )
}
