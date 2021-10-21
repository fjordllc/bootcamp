<template lang="pug">
.overlay(@click.self='closeModal()')
  .content
    h1
      | 日報テンプレート
      h2
        | テンプレート
      h2
        | プレビュー
      textarea

      div
        | 登録
      div
        | キャンセル
</template>
<script>
export default {
  data() {
    return {
      isEditingTemplate : true
    }
  },
  methods: {
    closeModal() {
      this.$emit('closeModal')
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
