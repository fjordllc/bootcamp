<template lang="pug">
div
  multiselect(
    id='select',
    v-model='selected',
    :options='options',
    placeholder='',
    :multiple='true',
    :clear-on-select='false',
    label='title',
    track-by='title',
    @select='select($event)',
    @remove='remove($event)'
  )
  div(id='multiselect__values')
  </template>

<script>
import Multiselect from 'vue-multiselect'
export default {
  components: { 
    Multiselect 
  },
  props: {
      practices: { type: String, required: true },
      editdata: { type: [Array], default: ()=>[] }
  },
  data () {
    const jsonPractices = JSON.parse(this.practices)
    const practices = jsonPractices.map(practice => { 
      let robj = {title: practice[0], id: practice[1]}
      return robj
      })
    return {
      selected: [],
      options: practices
    }
  },
  mounted() {
    for(const data of this.editdata) {
      console.log(data)
      for(const practice of this.options) {
        if(data === practice.id) {
          this.selected.push({ title: practice.title, id: practice.id})
          this.select(practice)        
        }
      }
    }
  },
  methods: {
    select(e) {
      const valueBox = document.getElementById("multiselect__values")
      const valueInput = document.createElement("input")
      valueInput.name = "report[practice_ids][]"
      valueInput.value = e.id
      valueInput.id = e.title
      valueInput.type = "hidden"
      valueBox.appendChild(valueInput)
    },
    remove(e) {
      const removeInput = document.getElementById(e.title)
      removeInput.remove()
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
<style src="vue-multiselect/dist/vue-multiselect.min.css">