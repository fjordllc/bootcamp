<template lang="pug">
div
  multiselect(
    v-model='selected',
    :options='practices',
    label='title',
    placeholder='',
    :max-height='300',
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
    title: { type: String, required: true },
    solved: { type: String, required: true },
    currentUserId: { type: String, required: true }
  },
  data() {
    const initOption =
      this.title.length !== 0
        ? { id: blankOption.id, title: this.title } // 初期描画でblankOption.titleがチラつくのを防止する
        : blankOption
    return {
      selected: initOption,
      practices: [initOption]
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
      fetch(`/api/practices.json?scoped_by_user=true`)
        .then((response) => {
          return response.json()
        })
        .then((practices) => {
          this.practices = [blankOption].concat(practices)
          if (this.queryPracticeId) {
            this.selected = this.practices.find((practice) => {
              return practice.id === parseInt(this.queryPracticeId)
            })
          }
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    submit() {
      this.$nextTick(() => {
        location.href = `${location.pathname}?all=true&solved=${this.solved}&practice_id=${this.selected.id}&title=${this.selected.title}`
      })
    }
  }
}
</script>

<style scoped>
.multiselect--active {
  overflow-y: scroll;
}
</style>
