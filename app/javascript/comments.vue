<template lang="pug">
#comments.thread-comments.loading(v-if='loaded === false')
  commentPlaceholder(v-for='num in placeholderCount', :key='num')
#comments.thread-comments.loaded(v-else)
  .thread-comments-more(v-show='!loadedComment')
    .thread-comments-more__inner
      .thread-comments-more__action
        button.a-button.is-lg.is-text.is-block(@click='showComments')
          | 前のコメント（ {{ nextCommentAmount }} ）
  header.thread-comments__header
    h2.thread-comments__title(
      v-if='commentableType === "RegularEvent" || commentableType === "Event"')
      | 質問・連絡・コメント
    h2.thread-comments__title(
      v-else-if='commentableType === "Announcement" || commentableType === "Page"')
      | 質問・コメント
    h2.thread-comments__title(v-else-if='commentableType === "Talk"')
      | 連絡・返信
    h2.thread-comments__title(v-else)
      | コメント
  .thread-comments__items
    comment(
      v-for='(comment, index) in comments',
      :key='comment.id',
      :comment='comment',
      :currentUser='currentUser',
      :id='"comment_" + comment.id',
      :isLatest='index === comments.length - 1',
      @delete='deleteComment',
      @update='updateComment')
  .thread-comment-form
    #latest-comment(v-if='comments.length === 0')
    .thread-comment__start
      span(:class='["a-user-role", roleClass]')
        img.thread-comment__user-icon.a-user-icon(
          :src='currentUser.avatar_url',
          :title='currentUser.icon_title')
    .thread-comment__end
      .thread-comment-form__form.a-card
        .a-form-tabs.js-tabs
          .a-form-tabs__tab.js-tabs__tab(
            :class='{ "is-active": isActive("comment") }',
            @click='changeActiveTab("comment")')
            | コメント
          .a-form-tabs__tab.js-tabs__tab(
            :class='{ "is-active": isActive("preview") }',
            @click='changeActiveTab("preview")')
            | プレビュー
        .a-markdown-input.js-markdown-parent
          .a-markdown-input__inner.js-tabs__content(
            :class='{ "is-active": isActive("comment") }')
            .form-textarea
              .form-textarea__body
                textarea#js-new-comment.a-text-input.js-warning-form.a-markdown-input__textarea(
                  v-model='description',
                  name='new_comment[description]',
                  data-preview='#new-comment-preview',
                  data-input='.new-comment-file-input',
                  @input='editComment')
              .form-textarea__footer
                .form-textarea__insert
                  label.a-file-insert.a-button.is-xs.is-text-reversal.is-block
                    | ファイルを挿入
                    input.new-comment-file-input(type='file', multiple)
          .a-markdown-input__inner.js-tabs__content(
            :class='{ "is-active": isActive("preview") }')
            #new-comment-preview.a-long-text.is-md.a-markdown-input__preview
        .card-footer
          .card-main-actions
            .card-main-actions__items
              .card-main-actions__item
                button#js-shortcut-post-comment.a-button.is-sm.is-primary.is-block(
                  @click='postComment',
                  :disabled='!validation || buttonDisabled')
                  | コメントする
              .card-main-actions__item.is-only-mentor(
                v-if='isRole("mentor") && commentType && !checkId')
                button.a-button.is-sm.is-danger.is-block(
                  @click='commentAndCheck',
                  :disabled='!validation || buttonDisabled')
                  i.fa-solid.fa-check
                  | {{ checkButtonLabel }}
</template>
<script>
import CSRF from 'csrf'
import Comment from 'comment.vue'
import TextareaInitializer from 'textarea-initializer'
import CommentPlaceholder from 'comment-placeholder'
import confirmUnload from 'confirm-unload'
import toast from 'toast'
import role from 'role'
import checkable from 'checkable.js'
import { setWatchable } from './setWatchable.js'

export default {
  components: {
    comment: Comment,
    commentPlaceholder: CommentPlaceholder
  },
  mixins: [toast, confirmUnload, role, checkable],
  props: {
    commentableId: { type: String, required: true },
    commentableType: { type: String, required: true },
    currentUserId: { type: Number, required: true },
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
      loadedComment: false,
      nextCommentAmount: null,
      incrementCommentSize: 8
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
    productCheckerId() {
      return this.$store.getters.productCheckerId
    },
    checkButtonLabel() {
      const path = window.location.pathname
      if (path.includes('/products/')) {
        return '合格にする'
      } else {
        return '確認OKにする'
      }
    }
  },
  created() {
    this.showComments()
  },
  methods: {
    isActive(tab) {
      return this.tab === tab
    },
    changeActiveTab(tab) {
      this.tab = tab
    },
    displayMoreComments() {
      this.loadedComment =
        this.commentLimit + this.commentOffset >= this.commentTotalCount
      if (!this.loadedComment) {
        this.commentOffset += this.commentLimit
      }
      const commentRemaining = this.commentTotalCount - this.commentOffset

      if (commentRemaining > this.incrementCommentSize) {
        this.nextCommentAmount = `${this.incrementCommentSize} / ${commentRemaining}`
      } else {
        this.nextCommentAmount = commentRemaining
      }
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
          this.displayMoreComments()
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
        })
    },
    createComment({ toastMessage } = {}) {
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
          'X-CSRF-Token': CSRF.getToken()
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
          this.clearPreview('new-comment-preview')
          this.tab = 'comment'
          this.buttonDisabled = false
          this.resizeTextarea()
          this.displayToast(toastMessage)
          setWatchable(this.commentableId, this.commentableType)
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
          'X-CSRF-Token': CSRF.getToken()
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
        !window.confirm('提出物を合格にしてよろしいですか？')
      ) {
        return null
      } else {
        this.createComment({ toastMessage: this.toastMessage() })
        this.check(
          this.commentableType,
          this.commentableId,
          '/api/checks',
          'POST',
          CSRF.getToken()
        )
      }
    },
    postComment() {
      if (this.commentableType === 'Report' && this.isRole('mentor')) {
        const notChecked = !this.checkId
        if (
          notChecked &&
          !window.confirm('日報を確認済みにしていませんがよろしいですか？')
        ) {
          return
        }
      }
      this.createComment()
      if (this.isUnassignedAndUnchekedProduct) {
        this.checkProduct(
          this.commentableId,
          this.currentUserId,
          '/api/products/checker',
          'PATCH',
          CSRF.getToken(),
          true
        )
      }
    },
    async fetchUncheckedProducts(page) {
      return fetch(`/api/products/unchecked?page=${page}`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': CSRF.getToken()
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
    },
    clearPreview(elementId) {
      const parent = document.getElementById(elementId)
      while (parent.lastChild) {
        parent.removeChild(parent.lastChild)
      }
    }
  }
}
</script>
