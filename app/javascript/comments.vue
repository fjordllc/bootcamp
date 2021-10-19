<template lang="pug">
#comments.thread-comments(v-if='loaded === false')
  commentPlaceholder(v-for='num in placeholderCount', :key='num')
#comments.thread-comments(v-else)
  .thread-comments-more(v-show='!loadedComment')
    .thread-comments-more__inner
      .thread-comments-more__action
        button#js-shortcut-post-comment.a-button.is-lg.is-text.is-block(
          @click='showComments'
        )
          | 古いコメントを表示する
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
      .thread-comment-form__tabs.js-tabs
        .thread-comment-form__tab.js-tabs__tab(
          :class='{ "is-active": isActive("comment") }',
          @click='changeActiveTab("comment")'
        )
          | コメント
        .thread-comment-form__tab.js-tabs__tab(
          :class='{ "is-active": isActive("preview") }',
          @click='changeActiveTab("preview")'
        )
          | プレビュー
      .thread-comment-form__markdown-parent.js-markdown-parent
        .thread-comment-form__markdown.js-tabs__content(
          :class='{ "is-active": isActive("comment") }'
        )
          textarea#js-new-comment.a-text-input.js-warning-form.thread-comment-form__textarea(
            v-model='description',
            name='new_comment[description]',
            data-preview='#new-comment-preview',
            @keyup="editComment"
          )
        .thread-comment-form__markdown.js-tabs__content(
          :class='{ "is-active": isActive("preview") }'
        )
          #new-comment-preview.is-long-text.thread-comment-form__preview
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
              v-if='(currentUser.role == "admin" || currentUser.role == "adviser") && commentType && !checkId'
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
import CommentPleaceholder from './comment-placeholder'
import confirmUnload from './confirm-unload'
import toast from './toast'

export default {
  components: {
    comment: Comment,
    commentPlaceholder: CommentPleaceholder
  },
  mixins: [toast, confirmUnload],
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
      return `is-${this.currentUser.role}`
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
          console.warn('Failed to parsing', error)
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

          if (
            this.commentableType === 'Product' &&
            this.isProductAssignableUser(this.currentUser.role) &&
            (await this.fetchProductAssign(Number(this.commentableId))) ===
              false
          ) {
            this.toggleProductAssignment()
          }
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
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
          console.warn('Failed to parsing', error)
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
      }
      const check = document.getElementById('js-shortcut-check')
      this.createComment()
      check.click()
    },
    isProductAssignableUser(userRole) {
      return /^(admin|mentor)$/.test(userRole)
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
          console.warn('Failed to parsing', error)
          return null
        })
    },
    async fetchProductAssign(productId) {
      for (let pageNumber = 1; ; pageNumber++) {
        const response = await this.fetchUncheckedProducts(pageNumber)
        if (response === null) {
          return null
        }
        const product = response.products.find(
          (product) => product.id === productId
        )
        if (product !== undefined) {
          return product.checker_id !== null
        }
      }
    },
    toggleProductAssignment() {
      const params = {
        product_id: this.commentableId,
        current_user_id: this.currentUserId
      }
      fetch('/api/products/checker', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
    },
    editComment() {
      this.editing = true
    }
  }
}
</script>
