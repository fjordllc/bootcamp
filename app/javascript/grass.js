document.addEventListener('DOMContentLoaded', () => {
  const hideGrass = document.querySelector('.hide-grass')
  if (hideGrass) {
    const grassContainer = hideGrass?.closest('.a-card')
    if (!grassContainer) return

    hideGrass.addEventListener('click', () => {
      document.cookie = `user_grass=${hideGrass.dataset.userId}; path=/;`
      grassContainer.style.display = 'none'
    })
  }

  const canvas = document.querySelector('.grass')
  if (!canvas) return

  let grasses
  try {
    grasses = JSON.parse(canvas.dataset.times)
  } catch (error) {
    console.error('Failed to parse grass data:', error)
    return
  }

  if (grasses) {
    const startX = 16
    const startY = 20
    const height = 10
    const width = 10
    const spanX = 2
    const spanY = 2
    const ctx = canvas.getContext('2d')
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
      ctx.strokeText('0 h', sampleStartX - 23, sampleStartY + 8.5)
      ctx.strokeText('6 h', sampleStartX + 71, sampleStartY + 8.5)
    }
  }
})
