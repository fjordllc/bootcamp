import React from 'react'

import Report from './Report'
import Reports from './Reports'

export default {
  component: Report,
  title: 'Example/Report',
  argTypes: {
    emotion: {
      control: 'select',
      options: ['sad', 'soso', 'happy']
    }
  }
}

export const Single = ({ displayUserIcon, emotion }) => {
  const report = {
    id: 1,
    wip: false,
    url: 'sample',
    emotion: emotion,
    title: 'title',
    description: 'sample',
    currentUserId: 1,
    user: {
      id: 1,
      avatar_url:
        'https://gravatar.com/avatar/b866515b92c01910badb98d72730144f?s=400&d=robohash&r=x',
      url: '',
      long_name: 'name'
    },
    hasAnyComments: false,
    hasCheck: false,
    checkDate: '2017-01-01',
    checkUserName: 'komagata',
    reportedOn: '2017-01-01',
    createdAt: '2017-01-01 00:00:00'
  }

  return (
    <Report
      key={report.id}
      report={report}
      currentUserId={report.currentUserId}
      displayUserIcon={displayUserIcon}
    />
  )
}

Single.args = {
  displayUserIcon: true,
  emotion: 'happy'
}

export const BasicReports = ({ displayUserIcon, emotion }) => {
  const reports = [
    {
      id: 1,
      wip: false,
      url: 'sample',
      emotion: emotion,
      title: 'title',
      description: 'sample',
      currentUserId: 1,
      user: {
        id: 1,
        avatar_url:
          'https://gravatar.com/avatar/b866515b92c01910badb98d72730144f?s=400&d=robohash&r=x',
        url: '',
        long_name: 'name'
      },
      hasAnyComments: false,
      hasCheck: false,
      checkDate: '2017-01-01',
      checkUserName: 'komagata',
      reportedOn: '2017-01-01',
      createdAt: '2017-01-01 00:00:00'
    },
    {
      id: 2,
      wip: false,
      url: 'sample',
      emotion: emotion,
      title: 'title2',
      description: 'sample',
      currentUserId: 2,
      user: {
        id: 2,
        avatar_url:
          'https://gravatar.com/avatar/b866515b92c01910badb98d72730144f?s=400&d=robohash&r=x',
        url: '',
        long_name: 'name2'
      },
      hasAnyComments: false,
      hasCheck: false,
      checkDate: '2017-01-01',
      checkUserName: 'komagata',
      reportedOn: '2017-01-01',
      createdAt: '2017-01-01 00:00:00'
    },
    {
      id: 3,
      wip: true,
      url: 'sample',
      emotion: emotion,
      title: 'title3',
      description: 'sample',
      currentUserId: 3,
      user: {
        id: 3,
        avatar_url:
          'https://gravatar.com/avatar/b866515b92c01910badb98d72730144f?s=400&d=robohash&r=x',
        url: '',
        long_name: 'name3'
      },
      hasAnyComments: false,
      hasCheck: false,
      checkDate: '2017-01-01',
      checkUserName: 'komagata',
      reportedOn: '2017-01-01',
      createdAt: '2017-01-01 00:00:00'
    }
  ]

  return (
    <Reports
      totalPages={1}
      reports={reports}
      displayUserIcon={displayUserIcon}
      displayPagination={false}
    />
  )
}

BasicReports.args = {
  displayUserIcon: true,
  emotion: 'happy'
}
