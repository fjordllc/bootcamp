<template lang="pug">
.overlay(@click.self='closeModal')
  .content
    h1
      | 日報テンプレート
      div
        | テンプレート
      div
        | プレビュー
      textarea(v-model='editingTemplate')
      div(v-if='!isTemplateRegisteredProp')
        button.a-button(:disabled='!validation' @click.prevent='registerTemplate') 登録
      div(v-else)
        button.a-button(:disabled='!validation' @click.prevent='updateTemplate') 変更
      div
        button.a-button(@click.prevent='closeModal') キャンセル
</template>
<script>
export default {
  props: {
    editingTemplateProp: {type: String, default: ''},
    isTemplateRegisteredProp: {type: Boolean, default: false},
    templateIdProp: {type: String, default: undefined}
  },
  data() {
    return {
      editingTemplate: '',
      isEditingTemplate : true,
      tab: 'template'
    }
  },
  computed: {
    validation() {
      return this.editingTemplate !== ''
    }
  },
  mounted() {
    this.editingTemplate = this.editingTemplateProp
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    closeModal() {
      this.$emit('closeModal', this.editingTemplate)
    },
    changeActiveTab(tab) {
      this.tab = tab
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
  z-index:1;

  position:fixed;
  top:0;
  left:0;
  width:100%;
  height:100%;
  background-color:rgba(0,0,0,0.5);

  display: flex;
  align-items: center;
  justify-content: center;
}

.content {
  z-index:2;
  width:50%;
  padding: 1em;
  background:#fff;
}
</style>
