import React from 'react'

export default function UserPracticeProgress({ user }) {
  const percentage = user.cached_completed_percentage
  const fraction = user.completed_fraction

  const roundedPercentage = user.graduated_on
    ? '100%'
    : Math.round(percentage) + '%'

  const ariaValuenow = user.graduated_on ? 100 : percentage

  const completedPracticesProgressNumber = user.graduated_on ? '卒業' : fraction

  return (
    <div className="completed-practices-progress">
      <div className="completed-practices-progress__bar-container">
        <div className="completed-practices-progress__bar"></div>
        <div
          className="completed-practices-progress__percentage-bar"
          aria-valuemax="100"
          aria-valuemin="0"
          aria-valuenow={ariaValuenow}
          role="progressbar"
          style={{ width: roundedPercentage }}></div>
      </div>
      <div className="completed-practices-progress__number">
        {completedPracticesProgressNumber}
      </div>
    </div>
  )
}
