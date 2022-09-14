<template lang="pug">
.user-icons(v-if='!loaded')
    .fa-solid.fa-spinner.fa-pulse
    |
    | ロード中
.user-icons(v-else)
  h3.user-icons__title
    | 見たよ
  ul.user-icons__items(
    v-if='tenOrLessFootprints || (moreThanTenFoorptints && isDisplay)'
  )
    footprint(
      v-for='footprint in limitedDisplayOnPage',
      :key='footprint.key',
      :footprint='footprint'
    )
  .user-icons__more(
    v-if='moreThanTenFoorptints && isDisplay',
    @click='showRemainingFootprints'
  )
    | その他{{ numberOfRemainingFootprints }}人
  ul.user-icons__items(v-else-if='moreThanTenFoorptints && !isDisplay')
    footprint(
      v-for='footprint in footprints',
      :key='footprint.key',
      :footprint='footprint'
    )
</template>
<script>
import Footprint from './footprint'

export default {
  name: 'Footprints',
  components: {
    footprint: Footprint
  },
  props: {
    footprintableId: { type: String, required: true },
    footprintableType: { type: String, required: true }
  },
  data() {
    return {
      footprints: [],
      isDisplay: true,
      footprintTotalCount: null,
      loaded: null
    }
  },
  computed: {
    url() {
      const params = new URL(location.href).searchParams
      params.set('footprintableType', this.footprintableType)
      params.set('footprintableId', this.footprintableId)
      return `/api/footprints.json?footprintable_type=${this.footprintableType}&footprintable_id=${this.footprintableId}`
    },
    limitedDisplayOnPage() {
      return this.footprints.slice(0, 10)
    },
    tenOrLessFootprints() {
      // 名前大丈夫そ？
        return this.footprintTotalCount <= 10
    },
    moreThanTenFoorptints() {
      return this.footprintTotalCount > 10
    },
    numberOfRemainingFootprints() {
      return this.footprintTotalCount - 10
    }
  },
  created() {
    window.onpopstate = function () {
      location.replace(location.href)
    }
    this.getFootprints()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getFootprints() {
      fetch(this.url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.footprints = []
          json.footprints.forEach((footprint) => {
            this.footprints.push(footprint)
          })
          this.footprintTotalCount = json.footprint_total_count
          this.loaded = true
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    showRemainingFootprints() {
      this.isDisplay = false
    }
  }
}
</script>
