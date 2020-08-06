<template lang="pug">
  div
    vue-tags-input(v-model="inputTag" :tags="tags" :autocomplete-items="filteredTags" @tags-changed="update" placeholder="")
    input(type="hidden" :value="tagsValue" :name="tagsParamName")
</template>

<script>
import VueTagsInput from '@johmun/vue-tags-input'

export default {
  props: ['tagsInitialValue', 'tagsParamName', 'taggableType'],
  components: { VueTagsInput },
  data() {
    return {
      inputTag: '',
      tags: [],
      tagsValue: '',
      autocompleteTags: [],
    };
  },
  methods: {
    update(newTags) {
      this.tags = newTags
      this.tagsValue = this.joinTags(newTags)
    },
    joinTags(value) {
      return value.map(tag => tag.text).join(',')
    },
    parseTags(value) {
      if (value === '') return [];
      
      return value.split(',').map(value => {
        return {
          text: value,
          tiClasses: ["ti-valid"]
        }
     })
    }
  },
  mounted() {
    this.tagsValue = this.tagsInitialValue
    this.tags = this.parseTags(this.tagsInitialValue)

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
        const suggestions = json.map(tag => { 
          return {
            text: tag.value 
          }
        })

        this.autocompleteTags.length = 0;
        this.autocompleteTags.push(...suggestions);
      })
      .catch(error => {
        console.warn('Failed to parsing', error)
      })
  },
  computed: {
    filteredTags() {
      return this.autocompleteTags.filter(tag => {
        return tag.text.toLowerCase().indexOf(this.inputTag.toLowerCase()) !== -1;
      });
    },
  },
};
</script>

<style>

  .vue-tags-input {
    max-width: 100% !important;
  }

  .vue-tags-input .ti-input {
    padding: 4px 10px;
    transition: border-bottom 200ms ease;
  }

  .vue-tags-input .ti-item {
    padding: 4px 6px;
  }

  .vue-tags-input .ti-item.ti-selected-item {
    background: #4638a0;
    color: #ffffff;
    padding: 4px 6px;
  }

  .vue-tags-input .ti-tag {
    position: relative;
    background: #dfdfdf;
    color: #000000;
    padding: 6px 10px;
  }

  .vue-tags-input .ti-tag:after {
    transition: transform .2s;
    position: absolute;
    content: '';
    height: 2px;
    width: 108%;
    left: -4%;
    top: calc(50% - 1px);
    background-color: #000;
    transform: scaleX(0);
  }

  .vue-tags-input .ti-deletion-mark:after {
    transform: scaleX(1);
  }
</style>
