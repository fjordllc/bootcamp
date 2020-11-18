<template lang="pug">
  .tag-links
    .form(v-if="editing")
      .form__items
        .form-item
          vue-tags-input(v-model="inputTag" :tags="tags" :autocomplete-items="filteredTags" @tags-changed="update" placeholder="" @before-adding-tag="checkTag")
          input(type="hidden" :value="tagsValue" :name="tagsParamName" id="user_tag_list")
    ul.tag-links__items(v-if="!editing")
      li.tag-links__item(v-for="tag in tags")
        a.tag-links__item-link(:href="`/users/tags/${tag.text}`")
          | {{ tag.text }}
</template>

<script>
import VueTagsInput from '@johmun/vue-tags-input'

export default {
  props: [
    'tagsInitialValue',
    'tagsParamName',
    'userId',
    'editable'
  ],
  components: {
    VueTagsInput
  },
  data() {
    return {
      inputTag: '',
      tags: [],
      tagsValue: '',
      autocompleteTags: [],
      editing: false
    }
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
      if (value === '') return []

      return value.split(',').map(value => {
        return {
          text: value,
          tiClasses: ["ti-valid"]
        }
      })
    },
    parseTagsError(error) {
      console.warn('Failed to parsing', error)
    },
    checkTag(obj) {
      if (obj.tag.text.includes(' ')) {
        alert('入力されたタグにスペースが含まれています')
      } else {
        obj.addTag()
      }
    },
    editTag() {

    },    
  },
  async mounted() {
    this.tagsValue = this.tagsInitialValue
    this.tags = this.parseTags(this.tagsInitialValue)
    this.editing = this.editable

    const response = await fetch(`/api/tags.json?taggable_type=${this.taggableType}`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin',
      redirect: 'manual'
    }).catch(this.parseTagsError)
    const json = await response.json().catch(this.parseTagsError)
    const suggestions = json.map(tag => {
      return {
        text: tag.value
      }
    })
    this.autocompleteTags.length = 0
    this.autocompleteTags.push(...suggestions)
  },
  computed: {
    taggableType() {
      return 'User'
    },
    filteredTags() {
      return this.autocompleteTags.filter(tag => {
        return tag.text.toLowerCase().indexOf(this.inputTag.toLowerCase()) !== -1
      })
    }
  }
}
</script>

<style>
  .vue-tags-input {
    max-width: 100% !important;
    background-color: transparent !important;
  }

  .vue-tags-input .ti-input {
    padding: .25rem .375rem;
    background-color: #f7f7f7;
    border: solid 1px #c1c5b9;
    border-radius: .25rem;
    transition: border-bottom 200ms ease;
  }

  .vue-tags-input .ti-autocomplete {
    z-index: 1;
    margin-top: -.25rem;
    padding-top: .1875rem;
    border: solid 1px #c1c5b9;
    border-top: none;
    border-radius: .25rem;
    border-top-right-radius: 0;
    border-top-left-radius: 0;
    background-color: #f7f7f7;
    line-height: 1.5;
  }

  .vue-tags-input .ti-item {
    padding: .25rem .375rem;
  }

  .vue-tags-input .ti-item:first-child {
    border-top: solid 1px #c1c5b9;
  }

  .vue-tags-input .ti-item:not(:last-child) {
    border-bottom: dashed 1px #eaeaea;
  }

  .vue-tags-input .ti-item.ti-selected-item {
    background: #4638a0;
    opacity: 0.8;
    color: #ffffff;
    padding: .25rem .375rem;
  }

  .vue-tags-input .ti-tag {
    position: relative;
    background: #edebf6;
    color: #4638a0;
    padding: .375rem .375rem .375rem .625rem;
    border: 1px solid #4638a0;
    border-radius: .25rem;
    font-size: .875rem;
  }

  .vue-tags-input .ti-new-tag-input {
    font-size: 1rem;
  }

  .vue-tags-input .ti-invalid {
    color: red;
  }

  .vue-tags-input .ti-tag:after {
    transition: transform .2s;
    position: absolute;
    content: '';
    height: .125rem;
    width: 108%;
    left: -4%;
    top: calc(50% - 1px);
    background-color: #000;
    transform: scaleX(0);
  }

  .vue-tags-input .ti-deletion-mark {
    background: #edebf6 !important;
  }

  .vue-tags-input .ti-deletion-mark:after {
    transform: scaleX(1);
  }
</style>