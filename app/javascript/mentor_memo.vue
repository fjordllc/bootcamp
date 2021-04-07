<template lang="pug">
  .practice-content.is-memo
    section.a-card(v-if="!editing")
      .practice-content__body
        .js-target-blank.is-long-text(
          v-html="markdownMemo")
      footer.card-footer
        .card-footer-actions
          ul.card-footer-actions__items
            li.card-footer-actions__item
              button.card-footer-actions__action.a-button.is-md.is-secondary.is-block(@click="editMemo")
                i.fas.fa-pen
                | 編集
    .a-card(v-show="editing")
      .practice-content__body
        .form-tabs.js-tabs
          .form-tabs__tab.js-tabs__tab(
            :class="{'is-active': isActive('memo')}"
            @click="changeActiveTab('memo')")
            | メモ
          .form-tabs__tab.js-tabs__tab(
            :class="{'is-active': isActive('preview')}"
            @click="changeActiveTab('preview')")
            | プレビュー
        .form-tabs-item__markdown-parent.js-markdown-parent
          .form-tabs-item__markdown.is-editor.js-tabs__content(
            :class="{'is-active': isActive('memo')}")
            textarea.a-text-input.js-warning-form.form-tabs-item__textarea(
              :id="`js-practice-memo`"
              data-preview="#practice-memo-preview"
              v-model="memo"
              name="practice[memo]"
              )
          .form-tabs-item__markdown.is-preview.js-tabs__content(
            :class="{'is-active': isActive('preview')}")
            .is-long-text.form-tabs-item__preview(v-html="markdownMemo")
      footer.card-footer
        .card-footer-actions
          ul.card-footer-actions__items
            li.card-footer-actions__item
              button.a-button.is-md.is-warning.is-block(@click="updateMemo")
                | 保存する
            li.card-footer-actions__item
              button.a-button.is-md.is-secondary.is-block(@click="cancel")
                | キャンセル
</template>
<script>
import TextareaInitializer from './textarea-initializer'
import MarkdownInitializer from './markdown-initializer'

export default {
  props: ['practiceId'],
  data: () => {
    return {
      memo: '',
      tab: 'memo',
      editing: false
    }
  },
  created() {
    fetch(`/api/practices/${this.practiceId}.json`, {
      method: 'GET',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
      },
      credentials: 'same-origin',
      redirect: 'manual'
    })
      .then(response => {
        return response.json()
      })
      .then(json => {
        if (json['memo']) {
          this.memo = json['memo']
        }
      })
      .catch(error => {
        console.warn('Failed to parsing', error)
      })
  },
  mounted() {
    TextareaInitializer.initialize('#js-practice-memo')
  },
  methods: {
    token () {
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
      fetch(`/api/practices/${this.practiceId}.json`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(response => {
          return response.json()
        })
        .then(json => {
          this.memo = json['memo']
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
        this.editing = false;
    },
    updateMemo () {
      let params = {
        practice: {
          memo: this.memo
        }
      }
      fetch(`/api/practices/${this.practiceId}`, {
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
        .then(response => {
          this.editing = false;
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
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
