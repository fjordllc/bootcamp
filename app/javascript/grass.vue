<template lang="pug">
.a-card
  header.card-header.is-sm
    h2.card-header__title
      | 学習時間
    h2.card-header__title(v-if='currentUser.primary_role === "graduate"')
      | <button @click='close'>非表示</button>
  .user-grass
    .user-grass-nav
      .user-grass-nav__previous(@click='onPrevYearMonth')
        i.fas.fa-angle-left
      .user-grass-nav__year--month {{ prevYearMonth && prevYearMonth.format(clientFormat) }} 〜 {{ currentYearMonth && currentYearMonth.format(clientFormat) }}
      .user-grass-nav__next(
        v-if='!isLatestYearMonth(currentYearMonth)',
        @click='onNextYearMonth'
      )
        i.fas.fa-angle-right
      .user-grass-nav__next.is-blank(v-else)
    canvas#grass.a-grass(width='650px', height='130px')
</template>

<script>
import dayjs from 'dayjs'

export default {
  props: {
    currentUser: { type: Object, required: true },
    userId: { type: String, required: true }
  },
  data() {
    return {
      clientFormat: 'YYYY年M月',
      serverFormat: 'YYYY-MM-DD',
      prevYearMonth: null,
      currentYearMonth: null
    }
  },
  mounted() {
    this.prevYearMonth = this.getPrevYearMonth()
    this.currentYearMonth = this.getCurrentYearMonth()
    this.canvas = document.getElementById('grass')

    this.load(dayjs().format(this.serverFormat))
  },
  beforeDestroy() {
    document.cookie = `user_grass=${JSON.stringify(this.userId)}`
  },
  methods: {
    getPrevYearMonth(yearMonth) {
      return dayjs(yearMonth).subtract(1, 'year')
    },
    getCurrentYearMonth(yearMonth) {
      return dayjs(yearMonth)
    },
    isLatestYearMonth(currentYearMonth) {
      return dayjs().isSame(currentYearMonth, 'month')
    },
    onPrevYearMonth() {
      const prev = dayjs(this.currentYearMonth).subtract(1, 'year')
      this.load(prev.format(this.serverFormat))
    },
    onNextYearMonth() {
      const next = dayjs(this.currentYearMonth).add(1, 'year')
      this.load(next.format(this.serverFormat))
    },
    load(date) {
      fetch(`/api/grasses/${this.userId}.json?end_date=${date}`)
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.render(json)
        })
        .catch((error) => {
          console.warn('parsing failed', error)
        })
    },
    render(grasses) {
      const startX = 16
      const startY = 20
      const height = 10
      const width = 10
      const spanX = 2
      const spanY = 2
      const ctx = this.canvas.getContext('2d')
      ctx.font = '8px Arial'
      ctx.strokeStyle = 'rgb(132, 132, 132)'
      ctx.clearRect(0, 0, 650, 130)

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
        ctx.fillRect(
          startX + (width + spanX) * col,
          startY + (height + spanY) * row,
          width,
          height
        )

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

      const lastDate = grasses[grasses.length - 1].date
      this.prevYearMonth = this.getPrevYearMonth(lastDate)
      this.currentYearMonth = this.getCurrentYearMonth(lastDate)

      // render sample
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
    },
    close() {
      this.$destroy()
      this.$el.parentNode.removeChild(this.$el)
    }
  }
}
</script>
