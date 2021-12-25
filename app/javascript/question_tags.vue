<template lang="pug">
.tag-links
  ul.tag-links__items(v-if='!editing')
    li.tag-links__item(v-for='tag in tags')
      a.tag-links__item-link(
        :href='`/questions/tags/${encodeURIComponent(tag.text)}?all=true`'
      )
        | {{ tag.text }}
    li.tag-links__item
      .tag-links__item-edit(@click='editTag')
        | タグ編集
  .form(v-show='editing')
    .form__items
      .form-item
        vue-tags-input(
          v-model='inputTag',
          :tags='tags',
          :autocomplete-items='filteredTags',
          @tags-changed='update',
          placeholder='',
          @before-adding-tag='validateTagName'
        )
        input(type='hidden', :value='tagsValue', :name='tagsParamName')
    .form-actions
      ul.form-actions__items
        li.form-actions__item.is-main
          button.a-button.is-warning.is-block.is-md(@click='updateTag')
            | 保存する
        li.form-actions__item
          button.a-button.is-secondary.is-block.is-sm(@click='cancel')
            | キャンセル
</template>

<script>
import VueTagsInput from '@johmun/vue-tags-input'
import validateTagName from './validate-tag-name'

export default {
  components: { VueTagsInput },
  mixins: [validateTagName],
  props: {
    tagsInitialValue: { type: Array, required: true },
    questionId: { type: Number, required: true },
    tagsParamName: { type: String, required: true }
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
  computed: {
    filteredTags() {
      return this.autocompleteTags.filter((tag) => {
        return (
          tag.text.toLowerCase().indexOf(this.inputTag.toLowerCase()) !== -1
        )
      })
    }
  },
  mounted() {
    this.tagsValue = this.tagsInitialValue
    this.tags = this.parseTags(this.tagsInitialValue)

    fetch('/api/tags.json?taggable_type=Question', {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then((response) => {
        return response.json()
      })
      .then((json) => {
        const suggestions = json.map((tag) => {
          return {
            text: tag.value
          }
        })
        this.autocompleteTags.length = 0
        this.autocompleteTags.push(...suggestions)
      })
      .catch((error) => {
        console.warn('Failed to parsing', error)
      })
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    update(newTags) {
      this.tags = newTags
      this.tagsValue = this.joinTags(newTags)
    },
    joinTags(value) {
      return value.map((tag) => tag.text).join(',')
    },
    parseTags(value) {
      if (value === '') return []

      return value.map((value) => {
        return {
          text: value,
          tiClasses: ['ti-valid']
        }
      })
    },
    editTag() {
      this.editing = true
    },
    updateTag() {
      const params = {
        question: {
          tag_list: this.tagsValue
        }
      }
      fetch(`/api/questions/${this.questionId}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then(() => {
          this.editing = false
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    cancel() {
      this.tagsValue = this.tagsInitialValue
      this.tags = this.parseTags(this.tagsInitialValue)
      this.editing = false
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
  padding: 0.25rem 0.375rem;
  background-color: #f7f7f7;
  border: solid 1px #c1c5b9;
  border-radius: 0.25rem;
  transition: border-bottom 200ms ease;
}

.vue-tags-input .ti-autocomplete {
  z-index: 1;
  margin-top: -0.25rem;
  padding-top: 0.1875rem;
  border: solid 1px #c1c5b9;
  border-top: none;
  border-radius: 0.25rem;
  border-top-right-radius: 0;
  border-top-left-radius: 0;
  background-color: #f7f7f7;
  line-height: 1.5;
}

.vue-tags-input .ti-item {
  padding: 0.25rem 0.375rem;
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
  padding: 0.25rem 0.375rem;
}

.vue-tags-input .ti-tag {
  position: relative;
  background: #edebf6;
  color: #4638a0;
  padding: 0.375rem 0.375rem 0.375rem 0.625rem;
  border: 1px solid #4638a0;
  border-radius: 0.25rem;
  font-size: 0.875rem;
}

.vue-tags-input .ti-new-tag-input {
  font-size: 1rem;
}

.vue-tags-input .ti-invalid {
  color: red;
}

.vue-tags-input .ti-tag:after {
  transition: transform 0.2s;
  position: absolute;
  content: '';
  height: 0.125rem;
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
