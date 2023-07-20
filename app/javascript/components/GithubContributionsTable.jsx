import React from "react"
import useSWR from "swr"

import fetcher from "../fetcher"
import GithubContributionsTableData from "./GithubContributionsTableData"

const TABLE_COL_SPAN = 53

export default function GithubContributionsTable ({ account }) {
  const { data, error } = useSWR(
    `/api/github_contributions/${account}`,
    fetcher
  )

  if (error) return console.warn(error)
  if (!data) return <>Loading...</>

  return (
    // Todo Design
    <table style={{ margin: '0 auto' }}>
      <thead>
        <tr><td colSpan={TABLE_COL_SPAN} /></tr>
      </thead>
      <tbody>
        {data.table.map((row, index) => (
          <tr key={index}>
            {row.map(({ level, index }) => (
              <GithubContributionsTableData
                contributionLevel={level}
                key={index}
              />
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  )
}
