<template lang="pug">
#comments.thread-comments.loading(v-if='loaded === false')
  commentPlaceholder(v-for='num in placeholderCount', :key='num')
#comments.thread-comments.loaded(v-else)
  .thread-comments-more(v-show='!loadedComment')
    .thread-comments-more__inner
      .thread-comments-more__action
        button.a-button.is-lg.is-text.is-block(@click='showComments')
          | コメント（{{ commentLimit }}）をもっと見る
  comment(
    v-for='(comment, index) in comments',
    :key='comment.id',
    :comment='comment',
    :currentUser='currentUser',
    :id='"comment_" + comment.id',
    @delete='deleteComment',
    @update='updateComment'
  )
  .thread-comment-form
    .thread-comment__author
      img.thread-comment__user-icon.a-user-icon(
        :src='currentUser.avatar_url',
        :class='[roleClass, daimyoClass]',
        :title='currentUser.icon_title'
      )
    .thread-comment-form__form.a-card
      .a-form-tabs.js-tabs
        .a-form-tabs__tab.js-tabs__tab(
          :class='{ "is-active": isActive("comment") }',
          @click='changeActiveTab("comment")'
        )
          | コメント
        .a-form-tabs__tab.js-tabs__tab(
          :class='{ "is-active": isActive("preview") }',
          @click='changeActiveTab("preview")'
        )
          | プレビュー
      .a-markdown-input.js-markdown-parent
        .a-markdown-input__inner.js-tabs__content(
          :class='{ "is-active": isActive("comment") }'
        )
          textarea#js-new-comment.a-text-input.js-warning-form.a-markdown-input__textarea(
            v-model='description',
            name='new_comment[description]',
            data-preview='#new-comment-preview',
            @input='editComment'
          )
        .a-markdown-input__inner.js-tabs__content(
          :class='{ "is-active": isActive("preview") }'
        )
          #new-comment-preview.is-long-text.a-markdown-input__preview
      .card-footer
        .card-main-actions
          .card-main-actions__items
            .card-main-actions__item
              button#js-shortcut-post-comment.a-button.is-md.is-primary.is-block(
                @click='createComment',
                :disabled='!validation || buttonDisabled'
              )
                | コメントする
            .card-main-actions__item.is-only-mentor(
              v-if='isRole("mentor") && commentType && !checkId'
            )
              button.a-button.is-md.is-danger.is-block(
                @click='commentAndCheck',
                :disabled='!validation || buttonDisabled'
              )
                i.fas.fa-check
                | 確認OKにする
</template>
<script>
import Comment from './comment.vue'
import TextareaInitializer from './textarea-initializer'
import CommentPlaceholder from './comment-placeholder'
import confirmUnload from './confirm-unload'
import toast from './toast'
import role from './role'
import checkMixin from './checkMixin.js'

export default {
  components: {
    comment: Comment,
    commentPlaceholder: CommentPlaceholder
  },
  mixins: [toast, confirmUnload, role, checkMixin],
  props: {
    commentableId: { type: String, required: true },
    commentableType: { type: String, required: true },
    currentUserId: { type: String, required: true },
    currentUser: { type: Object, required: true }
  },
  data() {
    return {
      comments: [],
      description: '',
      tab: 'comment',
      buttonDisabled: false,
      defaultTextareaSize: null,
      loaded: false,
      editing: false,
      placeholderCount: 3,
      commentLimit: 8,
      commentOffset: 0,
      commentTotalCount: null,
      loadedComment: false
    }
  },
  computed: {
    validation() {
      return this.description.length > 0
    },
    commentType() {
      return /^(Report|Product)$/.test(this.commentableType)
    },
    checkId() {
      return this.$store.getters.checkId
    },
    roleClass() {
      return `is-${this.currentUser.primary_role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.currentUser.daimyo }
    }
  },
  created() {
    this.showComments()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    isActive(tab) {
      return this.tab === tab
    },
    changeActiveTab(tab) {
      this.tab = tab
    },
    showComments() {
      fetch(
        `/api/comments.json?commentable_type=${this.commentableType}&` +
          `commentable_id=${this.commentableId}&comment_limit=${this.commentLimit}&` +
          `comment_offset=${this.commentOffset}`,
        {
          method: 'GET',
          headers: {
            'X-Requested-With': 'XMLHttpRequest'
          },
          credentials: 'same-origin',
          redirect: 'manual'
        }
      )
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          json.comments.forEach((c) => {
            this.comments.unshift(c)
          })
          this.commentTotalCount = json.comment_total_count
        })
        .catch((error) => {
          console.warn(error)
        })
        .finally(() => {
          if (this.loaded === false) {
            this.loaded = true
            this.$nextTick(() => {
              TextareaInitializer.initialize('#js-new-comment')
              this.setDefaultTextareaSize()
            })
          }
          this.loadedComment =
            this.commentLimit + this.commentOffset >= this.commentTotalCount
          if (this.loadedComment === false) {
            const commentLimit = this.commentLimit
            this.commentLimit =
              this.commentTotalCount - (this.commentLimit + this.commentOffset)
            this.commentOffset = commentLimit
          }
        })
    },
    createComment() {
      if (this.description.length < 1) {
        return null
      }
      this.buttonDisabled = true
      this.editing = false
      const params = {
        comment: { description: this.description },
        commentable_type: this.commentableType,
        commentable_id: this.commentableId
      }
      fetch(`/api/comments`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then((response) => {
          return response.json()
        })
        .then(async (comment) => {
          this.comments.push(comment)
          this.description = ''
          this.tab = 'comment'
          this.buttonDisabled = false
          this.resizeTextarea()
          this.toast('コメントを投稿しました！')
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    deleteComment(id) {
      fetch(`/api/comments/${id}.json`, {
        method: 'DELETE',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(() => {
          this.comments.forEach((comment, i) => {
            if (comment.id === id) {
              this.comments.splice(i, 1)
            }
          })
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    updateComment(description, id) {
      const updatedComment = this.comments.find((comment) => {
        return comment.id === id
      })
      updatedComment.description = description
    },
    setDefaultTextareaSize() {
      const textarea = document.getElementById('js-new-comment')
      this.defaultTextareaSize = textarea.scrollHeight
    },
    resizeTextarea() {
      const textarea = document.getElementById('js-new-comment')
      textarea.style.height = `${this.defaultTextareaSize}px`
    },
    commentAndCheck() {
      if (
        this.commentableType === 'Product' &&
        !window.confirm('提出物を確認済にしてよろしいですか？')
      ) {
        return null
      } else {
        this.createComment()
        this.check(this.commentableType, this.commentableId, '/api/checks', 'POST',  this.token())
      }
    },
    async fetchUncheckedProducts(page) {
      return fetch(`/api/products/unchecked?page=${page}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .catch((error) => {
          console.warn(error)
          return null
        })
    },
    editComment() {
      if (this.description.length > 0) {
        this.editing = true
      }
    }
  }
}
</script>
