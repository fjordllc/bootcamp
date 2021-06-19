<template lang="pug">
.a-card
  p { user }
</template>

<script>
export default {
  props: {
    userId: { type: String, required: true }
  },
  data() {
    return {
      reports: []
    }
  },
  mounted() {
    fetch(
        `/api/niconico_calendars/${this.userId}.json`,
        {
          method: 'GET',
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
          },
          credentials: 'same-origin'
        })
          .then((response) => {
            return response.json()
          })
          .then((json) => {
            if (json[0]) {
              json.forEach((r) => {
                this.reports.push(r)
              })
            }
          })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    }
  }
}
</script>

<style scoped>

</style>
