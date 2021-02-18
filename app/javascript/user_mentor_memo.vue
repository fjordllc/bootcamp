<template lang="pug">
  .is-memo
    section.a-card(v-if="!editing")
      header.card-header.is-sm
        h2.card-header__title
          | メンター向けユーザーメモ
      .card-body
        .js-target-blank.is-long-text(
          v-html="markdownMemo")
      footer.card-footer
        .card-footer-actions
          button.card-footer-actions__action.a-button.is-md.is-primary.is-block(@click="editMemo")
            i.fas.fa-pen
            | 編集
    .thread-comment-form__form.a-card(v-show="editing")
      .thread-comment-form__tabs.js-tabs
        .thread-comment-form__tab.js-tabs__tab(
          :class="{'is-active': isActive('memo')}"
          @click="changeActiveTab('memo')")
          | メモ
        .thread-comment-form__tab.js-tabs__tab(
          :class="{'is-active': isActive('preview')}"
          @click="changeActiveTab('preview')")
          | プレビュー
      .thread-comment-form__markdown-parent.js-markdown-parent
        .thread-comment-form__markdown.is-editor.js-tabs__content(
          :class="{'is-active': isActive('memo')}")
          textarea.a-text-input.js-warning-form.thread-comment-form__textarea(
            :id="`js-user-mentor-memo`"
            data-preview="#user-mentor-memo-preview"
            v-model="memo"
            name="user[memo]"
            )
        .thread-comment-form__markdown.is-preview.js-tabs__content(
          :class="{'is-active': isActive('preview')}")
          .is-long-text.thread-comment-form__preview(v-html="markdownMemo")
      .card-footer
        .thread-comment-form__actions
          .thread-comment-form__action
            button.a-button.is-md.is-warning.is-block(@click="updateMemo")
              | 保存する
          .thread-comment-form__action
            button.a-button.is-md.is-secondary.is-block(@click="cancel")
              | キャンセル
</template>

<script>
import TextareaInitializer from './textarea-initializer'
import MarkdownInitializer from './markdown-initializer'

export default {
  props: ['userId'],
  data: () => {
    return {
      memo: '',
      tab: 'memo',
      editing: false
    }
  },
  created () {
    fetch(`/api/users/${this.userId}.json`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
    .then(response => {
      return response.json()
    })
    .then(json => {
      if (json['mentor_memo']){
        this.memo = json['mentor_memo']
      }
    })
    .catch(error => {
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
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    updateMemo () {
      let params = {
        user: {
          mentor_memo: this.memo
        }
      }
      fetch(`/api/users/${this.userId}`, {
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
        .then(response => {
          this.editing = false;
        })
        .catch(error => {
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
        .then(response => {
          return response.json()
        })
        .then(json => {
          this.memo = json['mentor_memo']
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
        this.editing = false;
    },
    editMemo () {
      this.editing = true;
    }
  },
  computed: {
    markdownMemo() {
      const markdownInitializer = new MarkdownInitializer()
      return markdownInitializer.render(this.memo)
    }
  }
}
</script>
