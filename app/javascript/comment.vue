<template lang="pug">
.thread-comment(:class='{ "is-latest": isLatest }')
  #latest-comment(v-if='isLatest')
  .thread-comment__start
    a.thread-comment__user-link(:href='comment.user.url')
      span(:class='["a-user-role", roleClass]')
        img.thread-comment__user-icon.a-user-icon(
          :src='comment.user.avatar_url',
          :title='comment.user.icon_title')
    a.thread-comment__company-link(
      v-if='comment.user.company && comment.user.adviser',
      :href='comment.user.company.url')
      img.thread-comment__company-logo(:src='comment.user.company.logo_url')
  .thread-comment__end
    .a-card(v-if='!editing')
      header.card-header
        h2.thread-comment__title
          a.thread-comment__title-user-link.is-hidden-md-up(
            :href='comment.user.url')
            img.thread-comment__title-user-icon.a-user-icon(
              :src='comment.user.avatar_url',
              :title='comment.user.icon_title',
              :class='[roleClass]')

          a.thread-comment__title-link.a-text-link(:href='comment.user.url')
            | {{ comment.user.login_name }}
        time.thread-comment__created-at(
          :class='{ "is-active": activating }',
          :datetime='commentableCreatedAt',
          @click='copyCommentURLToClipboard(comment.id)')
          | {{ updatedAt }}
      hr.a-border-tint
      .thread-comment__description
        a.thread-comment__company-link.is-hidden-md-up(
          v-if='comment.user.company && comment.user.adviser',
          :href='comment.user.company.url')
          img.thread-comment__company-logo(
            :src='comment.user.company.logo_url')
        .a-long-text.is-md(v-html='markdownDescription')
      hr.a-border-tint
      .thread-comment__reactions
        reaction(
          v-bind:reactionable='comment',
          v-bind:currentUser='currentUser',
          v-bind:reactionableId='reactionableId')
      hr.a-border-tint
      footer.card-footer(
        v-if='comment.user.id === currentUser.id || isRole("admin")')
        .card-main-actions
          ul.card-main-actions__items
            li.card-main-actions__item
              button.card-main-actions__action.a-button.is-sm.is-secondary.is-block(
                @click='editComment')
                i.fa-solid.fa-pen
                | 編集
            li.card-main-actions__item.is-sub
              button.card-main-actions__muted-action(@click='deleteComment')
                | 削除する
    .a-card(v-show='editing')
      .thread-comment-form__form
        .a-form-tabs.js-tabs
          .a-form-tabs__tab.js-tabs__tab(
            v-bind:class='{ "is-active": isActive("comment") }',
            @click='changeActiveTab("comment")')
            | コメント
          .a-form-tabs__tab.js-tabs__tab(
            v-bind:class='{ "is-active": isActive("preview") }',
            @click='changeActiveTab("preview")')
            | プレビュー
        .a-markdown-input.js-markdown-parent
          .a-markdown-input__inner.js-tabs__content(
            v-bind:class='{ "is-active": isActive("comment") }')
            .form-textarea
              .form-textarea__body
                textarea.a-text-input.a-markdown-input__textarea(
                  :id='`js-comment-${this.comment.id}`',
                  :data-preview='`#js-comment-preview-${this.comment.id}`',
                  :data-input='`.js-comment-file-input-${this.comment.id}`',
                  v-model='description',
                  name='comment[description]')
              .form-textarea__footer
                .form-textarea__insert
                  label.a-file-insert.a-button.is-xs.is-text-reversal.is-block
                    | ファイルを挿入
                    input(
                      :class='`js-comment-file-input-${this.comment.id}`',
                      type='file',
                      multiple)
          .a-markdown-input__inner.js-tabs__content(
            v-bind:class='{ "is-active": isActive("preview") }')
            .a-long-text.is-md.a-markdown-input__preview(
              :id='`js-comment-preview-${this.comment.id}`')
        hr.a-border-tint
        .card-footer
          .card-main-actions
            .card-main-actions__items
              .card-main-actions__item
                button.a-button.is-sm.is-primary.is-block(
                  @click='updateComment',
                  v-bind:disabled='!validation')
                  | 保存する
              .card-main-actions__item
                button.a-button.is-sm.is-secondary.is-block(@click='cancel')
                  | キャンセル
</template>
<script>
import CSRF from 'csrf'
import Reaction from 'reaction.vue'
import MarkdownInitializer from 'markdown-initializer'
import TextareaInitializer from 'textarea-initializer'
import confirmUnload from 'confirm-unload'
import autosize from 'autosize'
import dayjs from 'dayjs'
import ja from 'dayjs/locale/ja'
import role from 'role'

dayjs.locale(ja)

export default {
  components: {
    reaction: Reaction
  },
  mixins: [confirmUnload, role],
  props: {
    comment: { type: Object, required: true },
    currentUser: { type: Object, required: true },
    isLatest: { type: Boolean, required: true }
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
      return `is-${this.comment.user.primary_role}`
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
          'X-CSRF-Token': CSRF.getToken()
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
          console.warn(error)
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
