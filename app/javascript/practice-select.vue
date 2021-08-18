<template lang="pug">
div
  multiselect(
    v-model='selected',
    :options='practices',
    label='title',
    placeholder='',
    :max-height='100',
    @select='submit()'
  )
</template>

<script>
import Multiselect from 'vue-multiselect'

const blankOption = { id: '', title: '全ての質問を表示' }

export default {
  components: {
    Multiselect
  },
  props: {
    solved: { type: String, required: true },
    currentUserId: { type: String, required: true }
  },
  data() {
    return {
      selected: blankOption,
      practices: [blankOption]
    }
  },
  computed: {
    queryPracticeId() {
      return new URLSearchParams(location.search).get('practice_id')
    }
  },
  created() {
    this.fetchPractices()
  },
  methods: {
    fetchPractices() {
      fetch(`/api/practices.json?user_id=${this.currentUserId}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest'
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((practices) => {
          this.practices = this.practices.concat(practices)
          if (this.queryPracticeId) {
            this.selected = this.practices.find((practice) => {
              return practice.id === parseInt(this.queryPracticeId)
            })
          }
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    submit() {
      this.$nextTick(() => {
        location.href = `${location.pathname}?solved=${this.solved}&practice_id=${this.selected.id}`
      })
    }
  }
}
</script>

<style scoped>
.multiselect {
  background-color: #fff;
}

.multiselect--active {
  overflow-y: scroll;
}
</style>
