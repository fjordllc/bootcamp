<template lang="pug">
  .thread-comments
    comment(v-for="(comment, index) in comments"
      v-bind:key="comment.id"
      v-bind:comment="comment")
</template>
<script>
  import Comment from "./comment.vue"

  export default {
    props: ["commentableId", "commentableType"],
    components: {
      "comment": Comment
    },
    data: () => {
      return {
        comments: [],
      }
    },
    created: function() {
      fetch(`/api/comments.json?commentable_type=${this.commentableType}&commentable_id=${this.commentableId}`, {
        method: this.method,
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
          json.forEach(c => { this.comments.push(c) });
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
    },
    mounted: function() {

    },
    methods: {
      review: function(event) { this.reviewing = true; },
      edit: function(event) { this.reviewing = false; },
      createComment: function(event) {

      },
      deleteComment: function(id) {

      },
    },
    computed: {
      HTML: function() {

      }
    }
  }
</script>
<style scoped>
</style>
