<template lang="pug">
div
  button.a-button.is-md.is-primary.is-block(
    v-if='registeredTemplate !== ""',
    @click.prevent='replaceReport'
  ) テンプレート反映
  div(v-if='registeredTemplate !== ""')
    button.a-button.is-md.is-primary.is-block(@click.prevent='openModal') テンプレート変更
  div(v-else)
    button.a-button.is-md.is-primary.is-block(@click.prevent='openModal') テンプレート登録
  modal(
    v-on:closeModal='closeModal',
    v-on:registerTemplate='registerTemplate',
    v-if='showModal',
    :editingTemplateProp='editingTemplate',
    :isTemplateRegisteredProp='isTemplateRegistered',
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
