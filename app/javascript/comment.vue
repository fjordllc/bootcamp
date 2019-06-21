<template lang="pug">
  .thread-comment
    .thread-comment__author
      a.thread-comment__author-link(:href="comment.user.url" itempro="url")
        img.thread-comment__author-icon(:src="comment.user.avatar_image" v-bind:class="userRole(comment.user)")
    .thread-comment__body.a-card(v-if="!editing")
      header.thread-comment__body-header
        h2.thread-comment__title
          a.thread-comment__title-link(:href="comment.user.url" itempro="url")
            | {{ comment.user.login_name }}
        time.thread-comment__created-at(:datetime="commentableCreatedAt" pubdate="pubdate")
          | {{ updatedAt }}
      .thread-comment__description.js-target-blank.is-long-text(v-html="markdownDescription")
      reaction(
        v-bind:reactionable="comment",
        v-bind:currentUser="currentUser")
      footer.card-footer(v-if="comment.user.id == currentUser.id")
        .card-footer-actions
          ul.card-footer-actions__items
            li.card-footer-actions__item
              button.card-footer-actions__action.a-button.is-md.is-primary.is-block(@click="editComment")
                i.fas.fa-pen
                | 編集
            li.card-footer-actions__item
              button.card-footer-actions__action.a-button.is-md.is-danger.is-block(@click="deleteComment")
                i.fas.fa-trash-alt
                | 削除
    .thread-comment-form__form.a-card(v-if="editing")
      .thread-comment-form__tabs.js-tabs
        .thread-comment-form__tab.js-tabs__tab(v-bind:class="{'is-active': isActive('comment')}" @click="changeActiveTab('comment')")
          | コメント
        .thread-comment-form__tab.js-tabs__tab(v-bind:class="{'is-active': isActive('preview')}" @click="changeActiveTab('preview')")
          | プレビュー
      .thread-comment-form__markdown-parent.js-markdown-parent
        .thread-comment-form__markdown.js-tabs__content(v-bind:class="{'is-active': isActive('comment')}")
          .thread-comments-form__error(v-if="error" v-text="errorMessage")
          markdown-textarea(v-model="description" class="a-text-input js-warning-form thread-comment-form__textarea js-markdown" required="required" name="comment[description]")
        .thread-comment-form__markdown.js-tabs__content(v-bind:class="{'is-active': isActive('preview')}")
          .js-preview.is-long-text.thread-comment-form__preview(v-html="markdownDescription")
      .thread-comment-form__action
        button.a-button.is-lg.is-warning.is-block(@click="updateComment")
          | 保存する
        button.a-button.is-block(@click="cancel")
          | キャンセル
</template>
<script>
  import Reaction from "./reaction.vue"
  import MarkdownTextarea from "./markdown-textarea.vue"
  import moment from "moment"
  import MarkdownIt from 'markdown-it'
  moment.locale("ja");

  export default {
    props: ["comment", "currentUser", "availableEmojis"],
    components: {
      "reaction": Reaction,
      "markdown-textarea": MarkdownTextarea
    },
    data: () => {
      return {
        description: "",
        editing: false,
        error: false,
        errorMessage: "コメントを入力してください。",
        tab: "comment"
      }
    },
    created: function() {
      this.description = this.comment.description;
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
      userRole: function(user){
        return `is-${user.role}`
      },
      cancel: function() {
        this.description = this.comment.description;
        this.editing = false;
      },
      editComment: function() {
        this.editing = true;
      },
      updateComment: function() {
        if (this.description.length < 1) {
          this.error = true;
          return null;
        } else {
          this.error = false;
        }

        let params = {"comment": {"description": this.description,
          "commentable_type": this.comment.commentable_type,
          "commentable_id": this.comment.commentable_id}}
        fetch(`/api/comments/${this.comment.id}`, {
          method: 'PUT',
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
            this.editing = false;
          })
          .catch(error => {
            console.warn('Failed to parsing', error)
          })
      },
      deleteComment: function() {
        if (window.confirm("削除してよろしいですか？")) {
          this.loading = true;
          this.$emit("delete", this.comment.id);
        }
      }
    },
    computed: {
      markdownDescription: function() {
        let md = new MarkdownIt({
          html: true,
          breaks: true,
          langPrefix: true,
          linkify: true
        });
        return md.render(this.description);
      },
      commentableCreatedAt: function() {
        return moment(this.comment.commentable.created_at).format()
      },
      updatedAt: function() {
        return moment(this.comment.updated_at).format("YYYY年MM月DD日(dd) HH:mm")
      }
    }
  }
</script>
<style scoped>
</style>
