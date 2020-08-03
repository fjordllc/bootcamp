<template lang="pug">
  div
    Tags.a-xs-text-input(:initialValue="tagsInitialValue" :onChange="onTagsChange")
    input(type="hidden" :value="tagsValue" :name="tagsParamName")
</template>

<script>
import Tags from "@yaireo/tagify/dist/tagify.vue";

export default {
  props: ['tagsInitialValue', 'tagsParamName'],
  components: { Tags },
  data() {
    return {
      tagsValue: ''
    };
  },
  methods: {
    onTagsChange(e) {
      const changedValue = e.target.value
      this.tagsValue = changedValue !== '' ? this.parseTagsJSON(changedValue) : ''
    },
    parseTagsJSON(value) {
      return JSON.parse(value).map(tag => tag.value).join(',') 
    }
  },
  mounted() {
    this.tagsValue = this.tagsInitialValue
  }
};
</script>

<style lang="scss">

.tagify {
  margin-bottom: 3em;
  background-color: #ffffff;
}

</style>
