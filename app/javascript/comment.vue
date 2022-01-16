<template lang="pug">
.thread-comment
  .thread-comment__author
    a.thread-comment__user-link(:href='comment.user.url')
      img.thread-comment__user-icon.a-user-icon(
        :src='comment.user.avatar_url',
        :title='comment.user.icon_title',
        :class='[roleClass, daimyoClass]'
      )
  .thread-comment__body.a-card(v-if='!editing')
    header.thread-comment__body-header
      h2.thread-comment__title
        a.thread-comment__title-link(:href='comment.user.url')
          | {{ comment.user.login_name }}
      time.thread-comment__created-at(
        :class='{ "is-active": activating }',
        :datetime='commentableCreatedAt',
        @click='copyCommentURLToClipboard(comment.id)'
      )
        | {{ updatedAt }}
    .thread-comment__description.js-target-blank.is-long-text(
      v-html='markdownDescription'
    )
    reaction(
      v-bind:reactionable='comment',
      v-bind:currentUser='currentUser',
      v-bind:reactionableId='reactionableId'
    )
    footer.card-footer(
      v-if='comment.user.id === currentUser.id || currentUser.role[0] === "admin"'
    )
      .card-main-actions
        ul.card-main-actions__items
          li.card-main-actions__item
            button.card-main-actions__action.a-button.is-md.is-secondary.is-block(
              @click='editComment'
            )
              i.fas.fa-pen
              | 編集
          li.card-main-actions__item.is-sub
            button.card-main-actions__delete(@click='deleteComment')
              | 削除する
  .thread-comment-form__form.a-card(v-show='editing')
    .a-form-tabs.js-tabs
      .a-form-tabs__tab.js-tabs__tab(
        v-bind:class='{ "is-active": isActive("comment") }',
        @click='changeActiveTab("comment")'
      )
        | コメント
      .a-form-tabs__tab.js-tabs__tab(
        v-bind:class='{ "is-active": isActive("preview") }',
        @click='changeActiveTab("preview")'
      )
        | プレビュー
    .a-markdown-input.js-markdown-parent
      .a-markdown-input__inner.js-tabs__content(
        v-bind:class='{ "is-active": isActive("comment") }'
      )
        textarea.a-text-input.a-markdown-input__textarea(
          :id='`js-comment-${this.comment.id}`',
          :data-preview='`#js-comment-preview-${this.comment.id}`',
          v-model='description',
          name='comment[description]'
        )
      .a-markdown-input__inner.js-tabs__content(
        v-bind:class='{ "is-active": isActive("preview") }'
      )
        .is-long-text.a-markdown-input__preview(
          :id='`js-comment-preview-${this.comment.id}`'
        )
    .card-footer
      .card-main-actions
        .card-main-actions__items
          .card-main-actions__item
            button.a-button.is-md.is-warning.is-block(
              @click='updateComment',
              v-bind:disabled='!validation'
            )
              | 保存する
          .card-main-actions__item
            button.a-button.is-md.is-secondary.is-block(@click='cancel')
              | キャンセル
</template>
<script>
import Reaction from './reaction.vue'
import MarkdownInitializer from './markdown-initializer'
import TextareaInitializer from './textarea-initializer'
import confirmUnload from './confirm-unload'
import autosize from 'autosize'
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
dayjs.locale(ja)

export default {
  components: {
    reaction: Reaction
  },
  mixins: [confirmUnload],
  props: {
    comment: { type: Object, required: true },
    currentUser: { type: Object, required: true }
  },
  data() {
    return {
      description: '',
      editing: false,
      isCopied: false,
      tab: 'comment',
      activating: false
    }
  },
  computed: {
    commentableCreatedAt() {
      return dayjs(this.comment.commentable.created_at).format()
    },
    markdownDescription() {
      const markdownInitializer = new MarkdownInitializer()
      return markdownInitializer.render(this.description)
    },
    updatedAt() {
      return dayjs(this.comment.updated_at).format('YYYY年MM月DD日(dd) HH:mm')
    },
    roleClass() {
      return `is-${this.comment.user.role}`
    },
    daimyoClass() {
      return { 'is-daimyo': this.comment.user.daimyo }
    },
    validation() {
      return this.description.length > 0
    },
    reactionableId() {
      return `Comment_${this.comment.id}`
    }
  },
  created() {
    this.description = this.comment.description
  },
  mounted() {
    TextareaInitializer.initialize(`#js-comment-${this.comment.id}`)

    const commentAnchor = location.hash
    if (commentAnchor) {
      this.$nextTick(() => {
        location.replace(location.href)
      })
    }
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
    cancel() {
      this.description = this.comment.description
      this.editing = false
    },
    editComment() {
      this.editing = true
      this.$nextTick(function () {
        const textarea = document.querySelector(
          `#js-comment-${this.comment.id}`
        )
        autosize.update(textarea)
        $(`.comment-id-${this.comment.id}`).trigger('input')
      })
    },
    updateComment() {
      if (this.description.length < 1) {
        return null
      }
      const params = {
        comment: { description: this.description }
      }
      fetch(`/api/comments/${this.comment.id}`, {
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
          this.$emit('update', this.description, this.comment.id)
          this.editing = false
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    deleteComment() {
      if (window.confirm('削除してよろしいですか？')) {
        this.$emit('delete', this.comment.id)
      }
    },
    copyCommentURLToClipboard(commentId) {
      const commentURL = location.href.split('#')[0] + '#comment_' + commentId
      const textBox = document.createElement('textarea')
      textBox.setAttribute('type', 'hidden')
      textBox.textContent = commentURL
      document.body.appendChild(textBox)
      textBox.select()
      document.execCommand('copy')
      document.body.removeChild(textBox)
      this.activating = true
      setTimeout(() => {
        this.activating = false
      }, 4000)
    }
  }
}
</script>
