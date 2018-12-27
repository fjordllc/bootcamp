import 'whatwg-fetch'

document.addEventListener('DOMContentLoaded', () => {
  const canvas = document.getElementById('grass')
  if (!canvas) {
    return false
  }

  const userId = canvas.dataset.userId

  fetch(`/api/grasses/${userId}.json`, {
    method: 'GET',
    headers: {
      'X-Requested-With': 'XMLHttpRequest'
    },
    credentials: 'same-origin'
  })
    .then(response => {
      return response.json()
    })
    .then(json => {
      render(json)
    })
    .catch(error => {
      console.warn('parsing failed', error)
    })

  const render = grasses => {
    const startX = 20
    const startY = 20
    const height = 10
    const width = 10
    const spanX = 2
    const spanY = 2
    const ctx = canvas.getContext('2d')
    ctx.font = '8px Arial'
    ctx.strokeStyle = 'rgb(132, 132, 132)'

    // render day of the week
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
      ctx.fillRect(startX + (width + spanX) * col, startY + (height + spanY) * row, width, height)

      // render month
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

    // render sample
    const sampleStartX = 555
    const sampleStartY = 120
    const sampleSpanX = 3
    ctx.font = '10px Arial'
    for (let i = 0; i < colors.length; i++) {
      ctx.fillStyle = colors[i]
      ctx.fillRect(sampleStartX + (width + sampleSpanX) * i, sampleStartY, width, height)
    }
    ctx.strokeText('0 h', sampleStartX - 23, sampleStartY + 8.5)
    ctx.strokeText('8 h', sampleStartX + 71, sampleStartY + 8.5)
  }
})
