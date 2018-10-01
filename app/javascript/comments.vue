<template lang="pug">
  .page-content#comments
    .container.is-md
      .page-content__inner.commentables__inner.a-card
        header.page-content__header
          h1.page-content__title コメント
        .comments
          .comments__items
            transition-group(name="fade")
              comment(v-for="(comment, index) in comments"
                      v-bind:key="comment.id"
                      v-bind:comment="comment"
                      v-on:delete="deleteComment")
        #commment-form.page-content__action.comment-form(:class="{ 'is-loading': loading, 'is-error': error }")
          .comment-form__items
            .comment-form-item
              .comment-form__error(v-if="error" v-text="errorMessage")
              textarea.a-text-input.comment-form-item__textarea.js-autosize(placeholder="コメント" v-model="body")
          .comment-form-actions
            button.is-button-flat-md-primary.comment-form-actions__action(@click="createComment") コメント投稿
</template>
<script>
import 'whatwg-fetch'
import Comment from './comment.vue'

export default {
  props: ['commentableId'],
  components: {
    comment: Comment
  },
  data: () => {
    return {
      comments: [],
      commentable_id: '',
      body: '',
      loading: false,
      error: false,
      errorMessage: 'コメントを入力してください。'
    }
  },
  created: function () {
    fetch(`/api/reports/${this.commentableId}`)
      .then(response => {
        console.log(response)
        return response.json()
      })
      .then(json => {
        const responseKey = this.options['responseKey']
        const url = json[responseKey]
        this.textarea.value = this.textarea.value.replace(
          text,
          `![${file.name}](${url})\n`
        )
        this.applyPreview()
      })
      .catch(error => {
        console.warn('parsing failed', error)
      })
  },
  mounted: function () {},
  methods: {
    createComment: function (event) {},
    deleteComment: function (id) {},
    applyCount: function () {}
  }
}
</script>
<style scoped>
</style>
