<template lang="pug">
section.a-card.is-memo.is-only-mentor
  header.card-header.is-sm(v-if='!editing && !productsMode')
    h2.card-header__title
      | メンター向けユーザーメモ
  hr.a-border-tint(v-if='!editing && !productsMode')
  .card-body(v-if='!editing')
    .card__description
      .a-long-text.is-md.a-placeholder(v-if='loading')
        p
        p
        p
        p
        p
        p
      .o-empty-message(v-else-if='memo.length === 0')
        .o-empty-message__icon
          i.fa-regular.fa-sad-tear
        .o-empty-message__text
          | ユーザーメモはまだありません。
      .a-long-text.is-md(v-else, v-html='markdownMemo')
  hr.a-border-tint(v-if='!editing')
  footer.card-footer(v-if='!editing')
    .card-main-actions
      .card-main-actions__items
        .card-main-actions__item
          button.card-footer-actions__action.a-button.is-sm.is-secondary.is-block(
            @click='editMemo')
            i.fa-solid.fa-pen
            | 編集
  .form-tabs.js-tabs(v-show='editing')
    .form-tabs__tab.js-tabs__tab(
      :class='{ "is-active": isActive("memo") }',
      @click='changeActiveTab("memo")')
      | メモ
    .form-tabs__tab.js-tabs__tab(
      :class='{ "is-active": isActive("preview") }',
      @click='changeActiveTab("preview")')
      | プレビュー
  .card-body(v-show='editing')
    .card__description
      .a-markdown-input.js-markdown-parent
        .a-markdown-input__inner.is-editor.js-tabs__content(
          :class='{ "is-active": isActive("memo") }')
          textarea.a-text-input.a-markdown-input__textarea(
            :id='`js-user-mentor-memo`',
            data-preview='#user-mentor-memo-preview',
            v-model='memo',
            name='user[memo]')
        .a-markdown-input__inner.is-preview.js-tabs__content(
          :class='{ "is-active": isActive("preview") }')
          .a-long-text.is-md.a-markdown-input__preview(v-html='markdownMemo')
  hr.a-border-tint(v-show='editing')
  .card-footer(v-show='editing')
    .card-main-actions
      .card-main-actions__items
        .card-main-actions__item
          button.a-button.is-sm.is-primary.is-block(@click='updateMemo')
            | 保存する
        .card-main-actions__item
          button.a-button.is-sm.is-secondary.is-block(@click='cancel')
            | キャンセル
</template>

<script>
import CSRF from 'csrf'
import TextareaInitializer from '../textarea-initializer'
import MarkdownInitializer from '../markdown-initializer'
import confirmUnload from '../confirm-unload'

export default {
  name: 'UserMentorMemo',
  mixins: [confirmUnload],
  props: {
    userId: { type: Number, required: true },
    productsMode: { type: Boolean, required: false }
  },
  data() {
    return {
      memo: '',
      tab: 'memo',
      editing: false,
      loading: true
    }
  },
  computed: {
    markdownMemo() {
      const markdownInitializer = new MarkdownInitializer()
      return markdownInitializer.render(this.memo)
    }
  },
  created() {
    fetch(`/api/users/${this.userId}.json`, {
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
        if (json.mentor_memo) {
          this.memo = json.mentor_memo
        }
        this.loading = false
      })
      .catch((error) => {
        console.warn(error)
      })
  },
  mounted() {
    TextareaInitializer.initialize('#js-user-mentor-memo')
  },
  methods: {
    isActive(tab) {
      return this.tab === tab
    },
    changeActiveTab(tab) {
      this.tab = tab
    },
    updateMemo() {
      const params = {
        user: {
          mentor_memo: this.memo
        }
      }
      fetch(`/api/mentor_memos/${this.userId}`, {
        method: 'PUT',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'Content-Type': 'application/json; charset=utf-8',
          'X-CSRF-Token': CSRF.getToken()
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params)
      })
        .then((response) => {
          this.editing = false
          return response
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    cancel() {
      fetch(`/api/users/${this.userId}.json`, {
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
          this.memo = json.mentor_memo
        })
        .catch((error) => {
          console.warn(error)
        })
      this.editing = false
    },
    editMemo() {
      this.editing = true
    }
  }
}
</script>
