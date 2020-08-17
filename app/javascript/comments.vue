<template lang="pug">
  .thread-comments-container
    h2.thread-comments-container__title コメント
    .thread-comments
      comment(v-for="(comment, index) in comments"
        :key="comment.id"
        :comment="comment",
        :currentUser="currentUser",
        :id="'comment_' + comment.id",
        @delete="deleteComment")
      .thread-comment-form
        .thread-comment__author
          img.thread-comment__author-icon.a-user-icon(:src="currentUser.avatar_url" :title="currentUser.icon_title")
        .thread-comment-form__form.a-card
          .thread-comment-form__tabs.js-tabs
            .thread-comment-form__tab.js-tabs__tab(:class="{'is-active': isActive('comment')}" @click="changeActiveTab('comment')")
              | コメント
            .thread-comment-form__tab.js-tabs__tab(:class="{'is-active': isActive('preview')}" @click="changeActiveTab('preview')")
              | プレビュー
          .thread-comment-form__markdown-parent.js-markdown-parent
            .thread-comment-form__markdown.js-tabs__content(:class="{'is-active': isActive('comment')}")
              textarea(
                v-model="description"
                id="js-new-comment"
                class="a-text-input js-warning-form thread-comment-form__textarea js-markdown"
                name="new_comment[description]"
                data-preview="#new-comment-preview")
            .thread-comment-form__markdown.js-tabs__content(:class="{'is-active': isActive('preview')}")
              #new-comment-preview.is-long-text.thread-comment-form__preview
          .thread-comment-form__actions
            .thread-comment-form__action
              button#js-shortcut-post-comment.a-button.is-lg.is-warning.is-block(@click="createComment" :disabled="!validation || buttonDisabled")
                | コメントする
</template>
<script>
import Comment from './comment.vue'
import TextareaInitializer from './textarea-initializer'

export default {
  props: ['commentableId', 'commentableType', 'currentUserId'],
  components: {
    'comment': Comment
  },
  data: () => {
    return {
      currentUser: {},
      comments: [],
      description: '',
      tab: 'comment',
      buttonDisabled: false,
      defaultTextareaSize: null
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
    TextareaInitializer.initialize('#js-new-comment')

    $("textarea").textareaAutoSize();
    this.setDefaultTextareaSize()
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
      if (this.description.length < 1) { return null }
      this.buttonDisabled = true
      let params = {
        'comment': { 'description': this.description },
        'commentable_type': this.commentableType,
        'commentable_id': this.commentableId
      }
      fetch(`/api/comments`, {
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
          return response.json()
        })
        .then(json=> {
          this.comments.push(json);
          this.description = '';
          this.tab = 'comment';
          this.buttonDisabled = false
          this.resizeTextarea()
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
    setDefaultTextareaSize: function () {
      const textarea = document.getElementById('js-new-comment')
      this.defaultTextareaSize = textarea.scrollHeight
    },
    resizeTextarea: function () {
      const textarea = document.getElementById('js-new-comment')
      textarea.style.height = `${this.defaultTextareaSize}px`
    }
  },
  computed: {
    validation: function() {
      return this.description.length > 0
    }
  }
}
</script>
