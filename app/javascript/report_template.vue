<template lang="pug">
.form-item-actions
  ul.form-item-actions__items
    li.form-item-actions__item(v-if='registeredTemplate !== ""')
      a.form-item-actions__text-link.is-danger(@click.prevent='replaceReport')
        | テンプレートを反映する
    li.form-item-actions__item(v-if='registeredTemplate !== ""')
      button.a-button.is-sm.is-secondary.is-block(@click.prevent='openModal') テンプレート変更
    li.form-item-actions__item(v-else)
      button.a-button.is-sm.is-secondary.is-block(@click.prevent='openModal') テンプレート登録
    modal(
      v-on:closeModal='closeModal'
      v-on:registerTemplate='registerTemplate'
      v-if='showModal'
      :editingTemplateProp='editingTemplate'
      :isTemplateRegisteredProp='isTemplateRegistered'
      :templateIdProp='templateIdProp'
    )
</template>
<script>
import Modal from './report_template_modal.vue'
import toast from './toast'

export default {
  components: {
    modal: Modal
  },
  mixins: [toast],
  props: {
    registeredTemplateProp: { type: String, required: false, default: '' },
    templateIdProp: { type: String, required: false, default: undefined }
  },
  data() {
    return {
      registeredTemplate: '',
      editingTemplate: '',
      showModal: false,
      isTemplateRegistered: false
    }
  },
  mounted() {
    const report = document.querySelector('#report_description')
    if (report.value === '') report.value = this.registeredTemplateProp
    this.registeredTemplate = this.registeredTemplateProp
    this.editingTemplate = this.registeredTemplateProp
    if (this.registeredTemplate !== '') this.isTemplateRegistered = true
  },
  methods: {
    openModal() {
      this.showModal = true
    },
    closeModal(editingTemplate) {
      this.editingTemplate = editingTemplate
      this.showModal = false
    },
    replaceReport() {
      const report = document.querySelector('#report_description')
      if (
        report.value === '' ||
        confirm('日報が上書きされますが、よろしいですか？')
      ) {
        report.value = this.registeredTemplate
      }
    },
    registerTemplate(template) {
      this.registeredTemplate = template
      this.toast('テンプレートを登録しました！')
    }
  }
}
</script>
