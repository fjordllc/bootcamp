<template lang="pug">
  div
    Tags.a-xs-text-input(:initialValue="initialTagList" :onChange="onTagsChange")
    input(type="hidden" :value="tagListValues" name="page[tag_list]")
</template>

<script>
import Tags from "@yaireo/tagify/dist/tagify.vue";

export default {
  props: ['initialTagList'],
  components: { Tags },
  data() {
    return {
      tagListValues: ''
    };
  },
  methods: {
    onTagsChange(e) {
      const changedValue = e.target.value
      this.tagListValues = changedValue !== '' ? this.parseTagListJSON(changedValue) : ''
    },
    parseTagListJSON(value) {
      return JSON.parse(value).map(tag => tag.value).join(',') 
    }
  },
  mounted() {
    this.tagListValues = this.initialTagList
  }
};
</script>

<style lang="scss">

.tagify {
  margin-bottom: 3em;
  background-color: #ffffff;
}

</style>
