<template lang="pug">
  .comments-item
    .comments-item__inner(:class="{ 'is-loading': loading, 'is-error': error }")
      .comments-item__user-image-container
          a.comments-item__link(:href="comment.user.url")
            img.comments-item__user-image(:src="comment.user.avatar_url")
      .comments-item__viewer(v-show="!editing")
        .comments-item__viewer-header
          h2.comments-item__user
            span.comments-item__user-name(v-text="comment.user.name")
            span.comments-item__user-company(v-text="comment.user.company.name")
          time.comments-item__created-at(:datetime="comment.created_at" v-text="createdFromNow")
        .comments-item__body(style="white-space: pre-wrap" v-text="body")
        .comments-item-actions(v-if="comment.user.id == currentUserId()")
          ul.comments-item-actions__items
            li.comments-item-actions__item
              .comments-item-actions__item-action(@click="editComment")
                i.fa.fa-pencil
            li.reviews-item-actions__item
              .comments-item-actions__item-action(@click="deleteComment")
                i.fa.fa-trash-o

      .comments-item__editor(v-show="editing")
        .comments-item__error(v-if="error" v-text="errorMessage")
        textarea.a-text-input.comment-form-item__textarea.js-autosize(v-model="body")

        .comments-item-actions
          ul.comments-item-actions__items
            li.comments-item-actions__item
              button.comments-item-actions__item-link.is-cancel(@click="cancel") キャンセル
            li.comments-item-actions__item
              button.is-button-flat-md-primary.comments-item-actions__item-link(@click="updateComment") 内容変更
</template>
<script>
import 'whatwg-fetch'

export default {
  props: ['comment'],
  data: () => {
    return {
      body: '',
      editing: false,
      loading: false,
      error: false,
      errorMessage: 'コメントを入力してください。'
    }
  },
  created: function () {
    this.body = this.comment.body
  },
  mounted: function () {
    $('textarea.js-autosize').textareaAutoSize()
  },
  methods: {
    currentUserId: function () {
      return window.currentUserId
    },
    cancel: function () {
      this.body = this.comment.body
      this.editing = false
    },
    editComment: function () {
      this.editing = true
    },
    updateComment: function () {
      // Validation
      if (this.body.length <= 1) {
        this.error = true
        return null
      } else {
        this.error = false
      }

      this.loading = true
      const params = new URLSearchParams()
      params.append('body', this.body)
    },
    deleteComment: function () {
      if (window.confirm('削除してよろしいですか？')) {
        this.loading = true
        this.$emit('delete', this.comment.id)
      }
    }
  },
  computed: {
    createdFromNow: function () {
      return moment(this.comment.created_at).fromNow()
    }
  }
}
</script>
<style scoped>
</style>
