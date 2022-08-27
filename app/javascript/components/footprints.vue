<template lang="pug">
.user-icons
  h3.user-icons__title(v-if='!loaded')
    .fa-solid.fa-spinner.fa-pulse
    |
    | ロード中
  h3.user-icons__title(v-else-if='footprintTotalCount !== 0')
    | 見たよ
  ul.user-icons__items(v-if='footprintTotalCount < 10 || footprintTotalCount === 10')
    footprint(
      v-for='footprint in footprints',
      :key='footprint.key',
      :footprint='footprint'
    )
  ul.user-icons__items(v-else-if='footprintTotalCount > 10 && isDisplay')
    footprint(
      v-for='footprint in limitedDisplayOnPage',
      :key='footprint.key',
      :footprint='footprint'
    )
  .page-content-prev-next__item-link( 
    v-if='footprintTotalCount > 10 && isDisplay',
    @click='showRemainingFootprints'
  )
    | その他{{ footprintTotalCount - 10 }}人
  ul.user-icons__items(v-else-if='footprintTotalCount > 10 && !isDisplay')
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
