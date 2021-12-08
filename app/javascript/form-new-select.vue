<template lang="pug">
div
  multiselect(
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
      editdata: { type: String }
  },
  data () {
    console.log(this.editdata)
    const practicesId = JSON.parse(this.practices)
    const practicesName = practicesId.map(practice => { 
      let robj = {title: practice[0], id: practice[1]}
      return robj
      })
    console.log(practicesName)

    return {
      selected: [],
      options: practicesName,
      practicesId: practicesId
    }
  },
  created() {
    if(this.editdata.length > 0) {
      console.log(1)
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
      console.log(e)
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