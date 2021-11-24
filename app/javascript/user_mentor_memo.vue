<template lang="pug">
section.a-card.is-memo.is-only-mentor
  header.card-header.is-sm(v-if='!editing && !productsMode')
    h2.card-header__title
      | メンター向けユーザーメモ
  .card-body(v-if='!editing')
    .js-target-blank.is-long-text(v-html='markdownMemo')
  footer.card-footer(v-if='!editing')
    .card-main-actions
      .card-main-actions__items
        .card-main-actions__item
          button.card-footer-actions__action.a-button.is-md.is-secondary.is-block(
            @click='editMemo'
          )
            i.fas.fa-pen
            | 編集
  .a-card__inner(v-show='editing')
    .form-tabs.js-tabs
      .form-tabs__tab.js-tabs__tab(
        :class='{ "is-active": isActive("memo") }',
        @click='changeActiveTab("memo")'
      )
        | メモ
      .form-tabs__tab.js-tabs__tab(
        :class='{ "is-active": isActive("preview") }',
        @click='changeActiveTab("preview")'
      )
        | プレビュー
    .a-markdown-input.js-markdown-parent
      .a-markdown-input__inner.is-editor.js-tabs__content(
        :class='{ "is-active": isActive("memo") }'
      )
        textarea.a-text-input.a-markdown-input__textarea(
          :id='`js-user-mentor-memo`',
          data-preview='#user-mentor-memo-preview',
          v-model='memo',
          name='user[memo]'
        )
      .a-markdown-input__inner.is-preview.js-tabs__content(
        :class='{ "is-active": isActive("preview") }'
      )
        .is-long-text.a-markdown-input__preview(v-html='markdownMemo')
    .card-footer
      .card-main-actions
        .card-main-actions__items
          .card-main-actions__item
            button.a-button.is-md.is-warning.is-block(@click='updateMemo')
              | 保存する
          .card-main-actions__item
            button.a-button.is-md.is-secondary.is-block(@click='cancel')
              | キャンセル
</template>

<script>
import TextareaInitializer from './textarea-initializer'
import MarkdownInitializer from './markdown-initializer'
import confirmUnload from './confirm-unload'

export default {
  mixins: [confirmUnload],
  props: {
    userId: { type: String, required: true },
    productsMode: { type: Boolean, required: true }
  },
  data() {
    return {
      memo: '',
      tab: 'memo',
      editing: false
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
      })
      .catch((error) => {
        console.warn('Failed to parsing', error)
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
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
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
          'X-CSRF-Token': this.token()
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
          console.warn('Failed to parsing', error)
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
          console.warn('Failed to parsing', error)
        })
      this.editing = false
    },
    editMemo() {
      this.editing = true
    }
  }
}
</script>
