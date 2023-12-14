import React, { useState, useEffect, useRef } from 'react'
import dayjs from 'dayjs'
import useSWR from 'swr'
import fetcher from '../fetcher'
import GrassHeader from './GrassHeader'
import GrassBody from './GrassBody'
import GrassNav from './GrassNav'
import GrassCanvas from './GrassCanvas'

const serverDateFormat = 'YYYY-MM-DD'

export default function Grass({ currentUser, userId }) {
  const [currentDate, setCurrentDate] = useState(dayjs())
  const [isVisible, setIsVisible] = useState(true)
  const isDashboard = location.pathname === '/'
  const canvasRef = useRef(null)
  const formattedDate = currentDate.format(serverDateFormat)

  const { data: grasses, error } = useSWR(
    `/api/grasses/${userId}.json?end_date=${formattedDate}`,
    fetcher
  )

  if (error) {
    console.warn('Error fetching grass data:', error)
  }

  const hideGrass = () => {
    setIsVisible(false)
    document.cookie = `user_grass=${JSON.stringify(userId)}`
  }

  useEffect(() => {
    const userGrassCookie = document.cookie
      .split('; ')
      .find((row) => row.startsWith('user_grass='))
    if (userGrassCookie) {
      const userGrass = JSON.parse(userGrassCookie.split('=')[1])
      if (userGrass === userId) {
        setIsVisible(false)
      }
    }
  }, [])

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
    <>
      <GrassHeader
        currentUser={currentUser}
        hideGrass={hideGrass}
        isDashboard={isDashboard}
      />
      <hr className="a-border-tint" />
      <GrassBody>
        <GrassNav
          currentDate={currentDate}
          onAddOneYear={onAddOneYear}
          onSubtractOneYear={onSubtractOneYear}
        />
        <GrassCanvas ref={canvasRef} />
      </GrassBody>
    </>
  )
}
