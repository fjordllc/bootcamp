import React, { useState, useEffect, useRef, forwardRef } from 'react'
import dayjs from 'dayjs'
import useSWR from 'swr'
import fetcher from '../fetcher'

const clientDateFormat = 'YYYY年M月'
const serverDateFormat = 'YYYY-MM-DD'

const GrassHeader = ({ currentUser, hideGrass }) => {
  const isDashboard = location.pathname === '/'
  return (
    <header className="card-header is-sm">
      <h2 className="card-header__title">学習時間</h2>
      {currentUser &&
        currentUser.primary_role === 'graduate' &&
        isDashboard && (
          <button
            onClick={hideGrass}
            className="a-button is-xs is-muted-bordered">
            非表示
          </button>
        )}
    </header>
  )
}

const GrassBody = ({ children }) => {
  return <div className="user-grass">{children}</div>
}

const GrassNav = ({ onAddOneYear, currentDate, onSubtractOneYear }) => {
  const prevYearMonth = dayjs(currentDate).subtract(1, 'year')
  const isLatestYearMonth = dayjs().isSame(currentDate, 'month')
  return (
    <div className="user-grass-nav">
      <div className="user-grass-nav__previous" onClick={onSubtractOneYear}>
        <i className="fa-solid fa-angle-left" />
      </div>
      <div className="user-grass-nav__year--month">
        {prevYearMonth?.format(clientDateFormat)} 〜
        {currentDate?.format(clientDateFormat)}
      </div>
      {!isLatestYearMonth ? (
        <div className="user-grass-nav__next" onClick={onAddOneYear}>
          <i className="fa-solid fa-angle-right" />
        </div>
      ) : (
        <div className="user-grass-nav__next is-blank" />
      )}
    </div>
  )
}

const GrassCanvas = forwardRef((_, ref) => {
  return (
    <canvas
      id="grass"
      className="a-grass"
      width="650px"
      height="130px"
      ref={ref}></canvas>
  )
})

export default function Grass({ currentUser, userId }) {
  const [currentDate, setCurrentDate] = useState(dayjs())
  const [isVisible, setIsVisible] = useState(true)
  const canvasRef = useRef(null)
  const formattedDate = currentDate.format(serverDateFormat)

  const { data: grasses } = useSWR(
    `/api/grasses/${userId}.json?end_date=${formattedDate}`,
    fetcher
  )

  const hideGrass = () => {
    setIsVisible(false)
  }

  useEffect(() => {
    if (grasses && canvasRef.current) {
      const render = () => {
        const startX = 16
        const startY = 20
        const height = 10
        const width = 10
        const spanX = 2
        const spanY = 2
        const ctx = canvasRef.current.getContext('2d')
        ctx.font = '8px Arial'
        ctx.strokeStyle = 'rgb(132, 132, 132)'
        ctx.clearRect(0, 0, 650, 130)

        const colors = ['#e2e5ec', '#98A5DA', '#5D72C4', '#223FAF', '#06063e']
        const dotw = ['日', '月', '火', '水', '木', '金', '土']
        for (let i = 0; i < dotw.length; i++) {
          ctx.strokeText(dotw[i], 0, startY + 8 + (height + spanY) * i)
        }

        let row = 0
        let col = 0
        let lastMonth = 0
        for (let i = 0; i < grasses.length; i++) {
          const grass = grasses[i]
          ctx.fillStyle = colors[grass.velocity]
          ctx.fillRect(
            startX + (width + spanX) * col,
            startY + (height + spanY) * row,
            width,
            height
          )

          if (row === 0) {
            const month = new Date(grass.date).getMonth() + 1
            if (lastMonth !== month) {
              ctx.strokeText(month, startX + (width + spanX) * col, startY - 10)
            }
            lastMonth = month
          }

          if (row >= 6) {
            row = 0
            col++
          } else {
            row++
          }
        }

        const lastDate = grasses[grasses.length - 1].date
        if (!dayjs(lastDate).isSame(currentDate, 'month')) {
          setCurrentDate(dayjs(lastDate))
        }

        const sampleStartX = 555
        const sampleStartY = 120
        const sampleSpanX = 3
        ctx.font = '10px Arial'
        for (let i = 0; i < colors.length; i++) {
          ctx.fillStyle = colors[i]
          ctx.fillRect(
            sampleStartX + (width + sampleSpanX) * i,
            sampleStartY,
            width,
            height
          )
        }
        ctx.strokeText('0 h', sampleStartX - 23, sampleStartY + 8.5)
        ctx.strokeText('6 h', sampleStartX + 71, sampleStartY + 8.5)
      }
      render()
    }
    document.cookie = `user_grass=${JSON.stringify(userId)}`
  }, [grasses])

  const onAddOneYear = () => {
    setCurrentDate(currentDate.add(1, 'year'))
  }

  const onSubtractOneYear = () => {
    setCurrentDate(currentDate.subtract(1, 'year'))
  }

  if (!isVisible) {
    return null
  }

  return (
    <div className="a-card">
      <GrassHeader currentUser={currentUser} hideGrass={hideGrass} />
      <hr className="a-border-tint" />
      <GrassBody>
        <GrassNav
          currentDate={currentDate}
          onAddOneYear={onAddOneYear}
          onSubtractOneYear={onSubtractOneYear}
        />
        <GrassCanvas ref={canvasRef} />
      </GrassBody>
    </div>
  )
}
