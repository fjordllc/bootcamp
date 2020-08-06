<template lang="pug">
  div
    Tags.a-xs-text-input(:initialValue="tagsInitialValue" :onChange="onTagsChange" :settings="this.tagifySettings")
    input(type="hidden" :value="tagsValue" :name="tagsParamName")
</template>

<script>
import Tags from '@yaireo/tagify/dist/tagify.vue'

export default {
  props: ['tagsInitialValue', 'tagsParamName', 'taggableType'],
  components: { Tags },
  data() {
    return {
      tagsValue: '',
      tagifySettings: {
        whitelist: [],
        dropdown: {
          enabled: 1,
          fuzzySearch: true,
          position: 'text',
          caseSensitive: false
        }
      },
      suggestions: []
    };
  },
  methods: {
    onTagsChange(e) {
      const changedValue = e.target.value
      this.tagsValue = changedValue !== '' ? this.parseTagsJSON(changedValue) : ''
    },
    parseTagsJSON(value) {
      return JSON.parse(value).map(tag => tag.value).join(',')
    },
  },
  mounted() {
    this.tagsValue = this.tagsInitialValue

    fetch(`/api/tags.json?taggable_type=${this.taggableType}`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then(response => {
        return response.json()
      })
      .then(json => {
        this.suggestions = json

        this.tagifySettings.whitelist.length = 0;
        this.tagifySettings.whitelist.push(...this.suggestions);
      })
      .catch(error => {
        console.warn('Failed to parsing', error)
      })
  },
};
</script>

<style lang="scss">
.tagify {
  margin-bottom: 3em;
  background-color: #ffffff;
}
</style>
