<template lang="pug">
div
  multiselect(
    v-model='value',
    :options='options',
    placeholder='',
    label='name',
    track-by='name',
    @input='input()'
  )
</template>

<script>
import Multiselect from 'vue-multiselect'

export default {
  components: {
    Multiselect
  },
  props: {
    bookSelected: { type: String, required: false, default: null },
    books: { type: String, required: true },
    hiddenNameParam: { type: String, required: true }
  },
  data() {
    return {
      value: {},
      options: {},
      hiddenName: this.hiddenNameParam
    }
  },
  created() {
    this.value =
      JSON.parse(this.bookSelected).length !== 0
        ? {
            id: JSON.parse(this.bookSelected)[0],
            name: JSON.parse(this.bookSelected)[1]
          }
        : { id: '', name: '本を選んでください' }
    this.options = JSON.parse(this.books).map(function (book) {
      return { id: book[0], name: book[1] }
    })
  },
  mounted() {
    const element = document.getElementsByName(this.hiddenName)[0]
    element.value = this.value.id
  },
  methods: {
    input() {
      const element = document.getElementsByName(this.hiddenName)[0]
      element.value = this.value.id
    }
  }
}
</script>

<style scoped>
.multiselect--active {
  overflow-y: scroll;
}
.multiselect {
  position: initial;
}
.multiselect__input {
  display: initial;
}
</style>
