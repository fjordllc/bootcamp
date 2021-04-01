<template lang="pug">
   .thread-list-item-tags
    .thread-list-item-tags__label
    ul.thread-list-item-tags__items(v-if="!editing")
      li.thread-list-item-tags__item(v-for="tag in tags")
        a(:href="`/pages/tags/${tag.text}`")
          | {{ tag.text }}
      li.thread-list-item-tags__item
        .thread-list-item-tags__item-edit(@click="editTag")
          | タグ編集
    .thread-list-item-tags-edit(v-show="editing")
      vue-tags-input(
        v-model="inputTag"
        :tags="tags"
        :autocomplete-items="filteredTags"
        @tags-changed="update"
        placeholder=""
        @before-adding-tag="checkTag")
      input(type="hidden" :value="tagsValue" :name="tagsParamName")
      .thread-list-item-tags-edit__actions
        .thread-list-item-tags-edit__actions-item
          button.a-button.is-sm.is-warning(@click="updateTag")
            | 保存する
        .thread-list-item-tags-edit__actions-item
          button.a-button.is-sm.is-secondary(@click="cancel")
            | キャンセル
</template>

<script>
import VueTagsInput from '@johmun/vue-tags-input'
export default {
  props: ['tagsInitialValue','userId','tagsParamName'],
  components: { VueTagsInput },
  data() {
    return {
      inputTag: '',
      tags: [],
      tagsValue: '',
      autocompleteTags: [],
      editing: false,
    };
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
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
    },
    checkTag(obj) {
      if (obj.tag.text.includes(' ')) {
        alert('入力されたタグにスペースが含まれています')
      } else {
        obj.addTag()
      }
    },
    editTag() {
      this.editing = true;
    },
    updateTag () {
      let params = {
        user: {
          tag_list: this.tagsValue
        }
      }
      fetch(`/api/users/${this.userId}`, {
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
        .then(response => {
          this.editing = false;
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    },
    cancel() {
      this.tagsValue = this.tagsInitialValue
      this.tags = this.parseTags(this.tagsInitialValue)
      this.editing = false;
    }
  },
  mounted() {
    this.tagsValue = this.tagsInitialValue
    this.tags = this.parseTags(this.tagsInitialValue)
    fetch('/api/tags.json?taggable_type=user', {
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
</style>
