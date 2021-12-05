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
  input(type="hidden", name="report[practice_ids][]", :value="value")
</template>

<script>
import Multiselect from 'vue-multiselect'
export default {
  components: { 
    Multiselect 
  },
  props: ['practices'],
  data () {
    const practicesId = JSON.parse(this.practices)
    const practicesName = practicesId.map(practice => practice[0]) // props の practices が this.practices で参照できる

    return {
      selected: null,
      value: null,
      options: practicesName,
      practicesId: practicesId
    }
  },
  methods: {
    select(e) {
      for(const practice of this.practicesId) {
        if(practice[0] === e) {
          return this.value = practice[1]
        };
      };
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
