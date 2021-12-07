<template lang="pug">
div
  multiselect(
    v-model='selected',
    :options='options',
    placeholder='',
    :multiple="true",
    :clear-on-select="false",
    @select='select($event)'
  )
  div(id="multiselect__values")
</template>

<script>
import Multiselect from 'vue-multiselect'
export default {
  components: { 
    Multiselect 
  },
  props: {
      practices: { type: String, required: true }
  },
  data () {
    const practicesId = JSON.parse(this.practices)
    const practicesName = practicesId.map(practice => practice[0]) // props の practices が this.practices で参照できる

    return {
      selected: null,
      options: practicesName,
      practicesId: practicesId
    }
  },
  methods: {
    select(e) {
      for(const practice of this.practicesId) {
        if(practice[0] === e) {
          const valueBox = document.getElementById("multiselect__values")
          const valueInput = document.createElement("input")
          valueInput.name = "report[practice_ids][]"
          valueInput.value = practice[1]
          valueInput.type = "hidden"
          valueBox.appendChild(valueInput)
        };
      };
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
