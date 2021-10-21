<template lang="pug">
div
  button.a-button.is-md.is-primary.is-block(v-if='template !== ""' @click='replaceReport') テンプレート反映
  div(v-if='template !== ""')
    button.a-button.is-md.is-primary.is-block(@click='openModal') テンプレート変更
  div(v-else)
    button.a-button.is-md.is-primary.is-block(@click='openModal') テンプレート登録
  modal(
    v-on:closeModal='closeModal()'
    v-if='isEditingTemplate'
  )
</template>
<script>
import Modal from './report_template_modal.vue'
export default {
  components: {
    'modal' : Modal
  },
  props: {
    initialTemplate: {type: String, required: false, default: ''}
  },
  data() {
    return {
      isEditingTemplate: false,
      template: ''
    }
  },
  mounted() {
    this.template = this.initialTemplate
  },
  methods: {
    openModal() {
      event.preventDefault();
      this.isEditingTemplate = true
    },
    closeModal() {
      this.isEditingTemplate = false
    },
    replaceReport() {
      event.preventDefault();
      const report = document.querySelector('#report_description')
      if (report.value === '' || confirm('日報が上書きされますが、よろしいですか？')) {
        report.value = this.template
      }
    }
  }
}

</script>
