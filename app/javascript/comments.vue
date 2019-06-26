<template lang="pug">
  .thread-comments-container
    h2.thread-comments-container__title コメント
    .thread-comments
      comment(v-for="(comment, index) in comments"
        v-bind:key="comment.id"
        v-bind:comment="comment",
        v-bind:currentUser="currentUser",
        v-on:delete="deleteComment")
      .thread-comment-form
        .thread-comment__author
          img.thread-comment__author-icon(:src="currentUser.avatar_image")
        .thread-comment-form__form.a-card
          .thread-comment-form__tabs.js-tabs
            .thread-comment-form__tab.js-tabs__tab(v-bind:class="{'is-active': isActive('comment')}" @click="changeActiveTab('comment')")
              | コメント
            .thread-comment-form__tab.js-tabs__tab(v-bind:class="{'is-active': isActive('preview')}" @click="changeActiveTab('preview')")
              | プレビュー
          .thread-comment-form__markdown-parent.js-markdown-parent
            .thread-comment-form__markdown.js-tabs__content(v-bind:class="{'is-active': isActive('comment')}")
              .thread-comments-form__error(v-if="error" v-text="errorMessage")
              markdown-textarea(v-model="description" id="js-new-comment" class="a-text-input js-warning-form thread-comment-form__textarea js-markdown" name="comment[description]")
            .thread-comment-form__markdown.js-tabs__content(v-bind:class="{'is-active': isActive('preview')}")
              .js-preview.is-long-text.thread-comment-form__preview(v-html="markdownDescription")
          .thread-comment-form__action
            button.a-button.is-lg.is-warning.is-block(@click="createComment")
              | コメントする
</template>
<script>
  import Comment from "./comment.vue"
  import MarkdownTextarea from "./markdown-textarea.vue"
  import MarkdownIt from 'markdown-it'
  import MarkdownItEmoji from 'markdown-it-emoji'
  import MarkdownItMention from './packs/markdown-it-mention'

  export default {
    props: ["commentableId", "commentableType", "currentUserId"],
    components: {
      "comment": Comment,
      "markdown-textarea": MarkdownTextarea
    },
    data: () => {
      return {
        currentUser: {},
        comments: [],
        description: "",
        error: false,
        errorMessage: "コメントを入力してください。",
        tab: "comment"
      }
    },

    created: function() {
      fetch(`/api/users/${this.currentUserId}.json`, {
        method: 'GET',
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
          for(var key in json){
            this.$set(this.currentUser, key, json[key])
          }
        })
        .catch(error => {
          console.warn('Failed to parsing', error)
        })
      
      fetch(`/api/comments.json?commentable_type=${this.commentableType}&commentable_id=${this.commentableId}`, {
        method: 'GET',
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
      $("textarea").textareaAutoSize();
    },
    methods: {
      token () {
        const meta = document.querySelector('meta[name="csrf-token"]')
        return meta ? meta.getAttribute('content') : ''
      },
      isActive: function(tab) {
        return this.tab == tab
      },
      changeActiveTab: function(tab) {
        this.tab = tab
      },
      createComment: function(event) {
        if (this.description.length <= 1) {
          this.error = true;
          return null;
        } else {
          this.error = false;
        }
        let params = {"comment": {"description": this.description,
          "commentable_type": this.commentableType,
          "commentable_id": this.commentableId
          },"commentable_type": this.commentableType,
          "commentable_id": this.commentableId}

        fetch(`/api/comments`, {
          method: 'POST',
          headers: {
            "Content-Type": "application/json; charset=utf-8",
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
          },
          credentials: 'same-origin',
          redirect: 'manual',
          body: JSON.stringify(params)
        })
          .then(response => {
            return response.json()
          })
          .then(json=> {
            this.comments.push(json);
            this.description = "";
          })
          .catch(error => {
            console.warn('Failed to parsing', error)
          })
      },
      deleteComment: function(id) {
        fetch(`/api/comments/${id}.json`, {
          method: 'DELETE',
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': this.token()
          },
          credentials: 'same-origin',
          redirect: 'manual'
        })
          .then(response => {
            this.comments.forEach((comment, i) => {
              if (comment.id == id) { this.comments.splice(i, 1); }
            });
          })
          .catch(error => {
            console.warn('Failed to parsing', error)
          })
      },
      changeActiveTab: function(tab) {
      if (this.commentIsActive == true && tab == 'preview') {
        this.commentIsActive = false
      } else if (this.commentIsActive == false && tab == 'comment') {
        this.commentIsActive = true
      }
      }
    },
    computed: {
      markdownDescription: function() {
        const md = new MarkdownIt({
          html: true,
          breaks: true,
          linkify: true,
          langPrefix: 'language-'
        });
        md.use(MarkdownItEmoji).use(MarkdownItMention)
        return md.render(this.description);
      }
    }
  }
</script>
<style scoped>
</style>
