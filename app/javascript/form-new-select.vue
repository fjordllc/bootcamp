<template lang="pug">
div
  multiselect#select(
    v-model='selected',
    :options='options',
    placeholder='',
    :multiple='dividedCase',
    :clear-on-select='false',
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
  computed: {
    dividedCase: function () {
      const path = location.pathname
      const reg = /(\/reports\/).+/
      if (reg.test(path)) {
        return true
      } else {
        return false
      }
    }
  },
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
      valueInput.name = this.dividedName
      valueInput.value = e.id
      valueInput.id = e.title
      valueInput.type = 'hidden'
      valueBox.appendChild(valueInput)
    },
    remove(e) {
      const removeInput = document.getElementById(e.title)
      removeInput.remove()
    },
    wdividedName: function () {
      const path = location.pathname
      const regRepo = /(\/reports\/).+/
      const regQ = /(\/questions\/).+/
      const regPage = /(\/pages\/).+/
      if (regRepo.test(path)) {
        return 'report[practice_ids][]'
      } else if (regQ.test(path)) {
        return 'question[practice_id]'
      } else if (regPage.test(path)) {
        return 'page[practice_id]'
      }
    }
  }
}
</script>

<style scoped>
.multiselect {
  position: initial;
}
.multiselect__input {
  display: initial;
}
</style>
