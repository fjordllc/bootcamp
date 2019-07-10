<template lang="pug">
  textarea(ref="textarea" :value="value" @keyup="update($event.target.value)" @change="update($event.target.value)" @drop="drop" @paste="paste")
</template>
<script>
import 'textarea-autosize/dist/jquery.textarea_autosize.min'

export default {
  props: ['value'],
  created: function() {
    let meta = document.querySelector('meta[name="csrf-token"]')
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    update: function(value) {
      this.$emit('input', value);
    },
    drop: function(event) {
      event.preventDefault();
      const files = event.dataTransfer.files;
      for (let i = 0; i < files.length; i++) {
        this.upload(files[i]);
      }
    },
    paste: function(event) {
      const files = event.clipboardData.files;
      if (files.length > 0) {
        event.preventDefault();
        for (let i = 0; i < files.length; i++) {
          this.upload(files[i]);
        }
      }
    },
    upload: function(file) {
      const textarea = this.$refs.textarea;
      const reader = new FileReader();
      reader.readAsText(file);
      reader.onload = (event) => {
        const text = `![${file.name}をアップロード中]()`;
        const beforeRange = textarea.selectionStart;
        const afterRange = text.length;
        const beforeText = textarea.value.substring(0, beforeRange);
        const afterText = textarea.value.substring(beforeRange, textarea.value.length);
        textarea.value = beforeText + text + afterText;
        this.$emit('input', textarea.value);
        let params = new FormData();
        params.append('file', file);

        fetch(`/api/image.json`, {
          method: 'POST',
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
          },
          credentials: 'same-origin',
          redirect: 'manual',
          body: params
        })
          .then(response => {
            return response.json()
          })
          .then(json => {
            const path = json.url
            textarea.value = textarea.value.replace(`![${file.name}をアップロード中]()`, `![${file.name}](${path})\n`);
            this.$emit('input', textarea.value);
          })
          .catch(error => {
            console.warn('Failed to parsing', error)
          })
      }
    }
  }
}
</script>
<style scoped>
</style>
