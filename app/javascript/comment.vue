<template lang="pug">
  .thread-comment
    .thread-comment__author
    .thread-comment__body.a-card
      header.thread-comment__body-header
        h2.thread-comment__title
          a.thread-comment__title-link()
            | username
        time.thread-comment__created-at(datetime="" pubdate="pubdate")
          | {{ comment.updated_at }}
      .thread-comment__description.js-target-blank.is-long-text
        | {{ comment.description }}
</template>
<script>
  import moment from "moment"
  moment.locale("ja");

  export default {
    props: ["comment", "userId"],
    components: {
    },
    data: () => {
      return {
        body: "",
        currentUserID: null,
        mine: false,
        author: false,
        editing: false,
        loading: false,
        error: false,
        errorMessage: "コメントを入力してください。"
      }
    },
    created: function() {

    },
    methods: {
      currentUserId: function() {
        return window.currentUserId;
      },
      cancel: function() {
        this.body = this.comment.body;
        this.editing = false;
      },
      editComment: function() {
        this.editing = true;
      },
      updateComment: function() {
      },
      deleteComment: function() {
      },
    },
    computed: {
      HTML: function() {
        return marked(this.body, { breaks: true });
      },
      createdAt: function() {
        return moment(this.comment.created_at).format("LLL")
      }
    }
  }
</script>
<style scoped>
</style>
