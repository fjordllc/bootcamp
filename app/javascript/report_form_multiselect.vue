<template lang="pug">
div
  multiselect(
    v-model='selected',
    :options='options',
    placeholder='',
    :multiple='true',
    label='title',
    track-by='title',
    @select='select($event)',
    @remove='remove($event)'
  )
  #multiselect__values
</template>

<script>
import Multiselect from 'vue-multiselect'
export default {
  components: {
    Multiselect
  },
  props: {
    practices: { type: String, required: true },
    editpractices: { type: [Array], default: () => [] }
  },
  data() {
    const jsonPractices = JSON.parse(this.practices)
    const practices = jsonPractices.map((practice) => {
      const robj = { title: practice[0], id: practice[1] }
      return robj
    })
    return {
      selected: [],
      options: practices,
      editdata: this.editpractices || []
    }
  },
  computed: {},
  mounted() {
    for (const data of this.editdata) {
      for (const practice of this.options) {
        if (data === practice.id) {
          this.selected.push({ title: practice.title, id: practice.id })
          this.select(practice)
        }
      }
    }
  },
  methods: {
    select(e) {
      const valueBox = document.getElementById('multiselect__values')
      const valueInput = document.createElement('input')
      valueInput.name = 'report[practice_ids][]'
      valueInput.value = e.id
      valueInput.id = e.title
      valueInput.type = 'hidden'
      valueBox.appendChild(valueInput)
    },
    remove(e) {
      const removeInput = document.getElementById(e.title)
      removeInput.remove()
    }
  }
}
</script>

<style src="vue-multiselect/dist/vue-multiselect.min.css"></style>
<style scoped>
.multiselect {
  position: initial;
}
.multiselect__input {
  display: initial;
}
</style>
