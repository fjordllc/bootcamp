<template lang="pug">
.overlay(@click.self='closeModal')
  .a-card.is-modal
    header.card-header.is-sm
      h1.card-header__title
        | 日報テンプレート
    .a-form-tabs.js-tabs
      .a-form-tabs__tab.js-tabs__tab(
        v-bind:class='{ "is-active": isActive("template") }'
        @click='changeActiveTab("template")'
      )
        | テンプレート
      .a-form-tabs__tab.js-tabs__tab(
        v-bind:class='{ "is-active": isActive("preview") }'
        @click='changeActiveTab("preview")'
      )
        | プレビュー
    .a-markdown-input.js-markdown-parent
      .a-markdown-input__inner.js-tabs__content(
        v-bind:class='{ "is-active": isActive("template") }'
      )
        textarea.a-text-input.a-markdown-input__textare(
          :id='`js-template-content`'
          :data-preview='`#js-template-preview`'
          v-model='editingTemplate'
        )
      .a-markdown-input__inner.js-tabs__content(
        v-bind:class='{ "is-active": isActive("preview") } '
      )
        .is-long-text.a-markdown-input__preview(
          :id='`js-template-preview`'
        )
    footer.card-footer
      .card-main-actions
        ul.card-main-actions__items
          li.card-main-actions__item(v-if='!isTemplateRegisteredProp')
            button.a-button.is-primary.is-md.is-block(:disabled='!validation' @click.prevent='registerTemplate') 登録
          li.card-main-actions__item(v-else)
            button.a-button.is-primary.is-md.is-block(:disabled='!validation' @click.prevent='updateTemplate') 変更
          li.card-main-actions__item.is-sub
            .card-main-actions__delete(@click.prevent='closeModal') キャンセル
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
    TextareaInitializer.initialize(`#js-template-content`)
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
<style>
.overlay {
  z-index: 1;

  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);

  display: flex;
  align-items: center;
  justify-content: center;
}

.content {
  z-index: 2;
  width: 50%;
  padding: 1em;
  background: #fff;
}
</style>
