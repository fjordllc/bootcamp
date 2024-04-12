import CSRF from 'csrf'
import Footprint from './footprint.js'

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
    this.getFootprints()
  },
  methods: {
    getFootprints() {
      fetch(this.url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => response.json())
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
