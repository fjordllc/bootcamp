import React from 'react'

export default function UserPracticeProgress({ user }) {
  const percentage = user.cached_completed_percentage
  const fraction = user.cached_completed_fraction

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
      <div className="completed-practices-progress__counts">
        <input
          className="a-toggle-checkbox"
          type="checkbox"
          id={`userid_${user.id}`}
        />
        <label
          className="completed-practices-progress__counts-inner"
          htmlFor={`userid_${user.id}`}>
          <div className="completed-practices-progress__percentage">
            {roundedPercentage}
          </div>
          <div className="completed-practices-progress__number">
            {completedPracticesProgressNumber}
          </div>
        </label>
      </div>
    </div>
  )
}
