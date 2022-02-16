<template lang="pug">
.a-overlay.is-vue(@click.self='closeModal')
  .a-card.is-modal
    header.card-header.is-sm
      h1.card-header__title
        | 日報テンプレート
    .a-form-tabs.js-tabs
      .a-form-tabs__tab.js-tabs__tab(
        v-bind:class='{ "is-active": isActive("template") }',
        @click='changeActiveTab("template")'
      )
        | テンプレート
      .a-form-tabs__tab.js-tabs__tab(
        v-bind:class='{ "is-active": isActive("preview") }',
        @click='changeActiveTab("preview")'
      )
        | プレビュー
    .a-markdown-input.js-markdown-parent
      .a-markdown-input__inner.js-tabs__content(
        v-bind:class='{ "is-active": isActive("template") }'
      )
        textarea.a-text-input.a-markdown-input__textare.has-max-height(
          :id='`js-template-content`',
          :data-preview='`#js-template-preview`',
          v-model='editingTemplate',
          name='report_template[description]'
        )
      .a-markdown-input__inner.js-tabs__content.is-long-text.a-markdown-input__preview(
        v-bind:class='{ "is-active": isActive("preview") }',
        v-html='markdownDescription'
      )
        #js-template-preview
    footer.card-footer
      .card-main-actions
        ul.card-main-actions__items
          li.card-main-actions__item(v-if='!isTemplateRegisteredProp')
            button.a-button.is-primary.is-md.is-block(
              :disabled='!validation',
              @click.prevent='registerTemplate'
            ) 登録
          li.card-main-actions__item(v-else)
            button.a-button.is-primary.is-md.is-block(
              :disabled='!validation',
              @click.prevent='updateTemplate'
            ) 変更
          li.card-main-actions__item.is-sub
            .card-main-actions__muted-action(@click.prevent='closeModal') キャンセル
</template>
<script>
import MarkdownInitializer from './markdown-initializer'
import TextareaInitializer from './textarea-initializer'

export default {
  props: {
    editingTemplateProp: { type: String, default: '' },
    isTemplateRegisteredProp: { type: Boolean, default: false },
    templateIdProp: { type: String, default: undefined }
  },
  data() {
    return {
      editingTemplate: '',
      isEditingTemplate: true,
      tab: 'template'
    }
  },
  computed: {
    validation() {
      return this.editingTemplate !== ''
    },
    markdownDescription() {
      const markdownInitializer = new MarkdownInitializer()
      return markdownInitializer.render(this.editingTemplate)
    }
  },
  mounted() {
    TextareaInitializer.initialize('#js-template-content')
    this.editingTemplate = this.editingTemplateProp
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
    closeModal() {
      this.$emit('closeModal', this.editingTemplate)
    },
    registerTemplate() {
      if (this.editingTemplate === '') {
        return null
      }
      const params = {
        report_template: { description: this.editingTemplate }
      }
      fetch('/api/report_templates', {
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
        .then(() => {
          this.$emit('registerTemplate', this.editingTemplate)
          this.closeModal()
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    updateTemplate() {
      if (this.editingTemplate === '') {
        return null
      }
      const params = {
        report_template: { description: this.editingTemplate }
      }
      fetch(`/api/report_templates/${this.templateIdProp}`, {
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
          this.$emit('registerTemplate', this.editingTemplate)
          this.closeModal()
        })
        .catch((error) => {
          console.warn(error)
        })
    }
  }
}
</script>
