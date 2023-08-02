import React from 'react'

function getGrassColor(level) {
  switch (level) {
    case 1:
      return '#0e4429'
    case 2:
      return '#006d32'
    case 3:
      return '#26a641'
    case 4:
      return '#39d353'
    default:
      return 'transparent'
  }
}

function hasContribution(level) {
  return level === 0
}

// Todo Design
const defaultStyle = {
  width: '8px',
  height: '8px',
  padding: '1px',
  margin: '1px',
  display: 'block',
  borderRadius: '2px'
}

export default function GithubContributionsTableData({ contributionLevel }) {
  const style = {
    ...defaultStyle,
    border: hasContribution(contributionLevel) ? '1px solid lightgray' : 'none',
    backgroundColor: getGrassColor(contributionLevel)
  }

  return (
    <td>
      <span style={style} />
    </td>
  )
}
