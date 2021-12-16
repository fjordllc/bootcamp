<template lang="pug">
div
  multiselect#select(
    v-model='selected',
    :options='options',
    placeholder='',
    label='name'
  )
  input(:value='selected.id', name='product[checker_id]', type='hidden' )
</template>

<script>
import Multiselect from 'vue-multiselect'
export default {
  components: {
    Multiselect
  },
  props: {
    checkers: { type: String, required: true },
    checker: { type: String, require: false, default: null }
  },
  data() {
    const jsonCheckers = JSON.parse(this.checkers)
    const checkers = jsonCheckers.map((checker) => {
      const robj = { name: checker[0], id: checker[1] }
      return robj
    })
    console.log(this.checker)
    return {
      selected: [],
      options: checkers,
    }
  },
  mounted() {
    for(const checker of this.options) {
      if(this.checker === String(checker.id)){
        this.selected.push(checker)
      }
    } 
  }
}
</script>

<style scoped>
.multiselect {
  position: initial;
}
</style>
