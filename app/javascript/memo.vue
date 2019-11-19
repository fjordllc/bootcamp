<template lang="pug">
  .memo
    .memo-form
      textarea(ref="sendBody" v-model="sendBody" name="memo[body]")
      button.a-button.is-md.is-primary.is-block(@click="createMemo")
        | 作成
      button.a-button.is-md.is-warning.is-block(@click="updateMemo")
        | 更新
      button.a-button.is-md.is-danger.is-block(@click="deleteMemo")
        | 削除
    .memo-body
      | {{ body }}
</template>
<script>
export default {
  props: ['memo', 'date'],
  data: () => {
    return {
      sendBody: '',
      id: '',
      body: ''
    }
  },
  created: function() {
    if(!(this.memo === undefined)){
      this.id = this.memo.id
      this.sendBody = this.memo.body
      this.body = this.memo.body
    }
  },
  methods: {
    token () {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    createMemo: function() {
      if (this.sendBody.length < 1) { return null }
      let params = {
        'date': this.date,
        'body': this.$refs.sendBody.value,
      }
      fetch(`/api/memos`, {
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
        .then(response => {
          return response.json();
        })
        .then(json => {
          if (json["status"] === 201) {
            this.id = json["id"];
            this.body = json["body"];
          }
        })
        .catch(error => {
          console.warn('Failed to parsing', error);
        })
    },
    updateMemo: function() {
      if (this.sendBody.length < 1) { return null }
      if (this.sendBody === this.body) { return null }

      let params = {
        'date': this.date,
        'body': this.$refs.sendBody.value,
      }
      fetch(`/api/memos/${this.id}`, {
        method: 'PATCH',
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
          return response.json();
        })
        .then(json => {
          if (json["status"] === 200) {
            this.id = json["id"];
            this.body = json["body"];
          }
        })
        .catch(error => {
          console.warn('Failed to parsing', error);
        })
    },
    deleteMemo: function() {
      fetch(`/api/memos/${this.id}.json`, {
        method: 'DELETE',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then(response => {
          return response.json();
        })
        .then(json => {
          if (json["status"] === 200) {
            this.id = json["id"];
            this.body = '';
          }
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    }
  },
  computed: {
  }
}
</script>
