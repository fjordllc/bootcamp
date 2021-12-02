<template lang="pug">
div
  multiselect(
    v-model="selected",
    :multiple="true",
    :options="options",
    placeholder="test"
  )
</template>

<script>
import Multiselect from 'vue-multiselect'
export default {
  components: { 
    Multiselect 
  },
  data () {
    return {
      selected: null,
      options: ['java', 'vue', 'go', 'c#', 'html']
    }
  },
  created() {
    console.log(1);
  }
}
</script>

<style src="vue-multiselect/dist/vue-multiselect.min.css">