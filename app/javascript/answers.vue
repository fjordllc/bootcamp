<template lang="pug">
  .thread-comments-container
    h2.thread-comments-container__title 回答・コメント
    .thread-comments
      answer(v-for="(answer, index) in answers"
        :key="answer.id",
        :answer="answer",
        :currentUser="currentUser",
        :id="'answer_' + answer.id",
        :questionUser="questionUser",
        :correctAnswer="question.correctAnswer",
        :hasCorrectAnswer="hasCorrectAnswer",
        @delete="deleteAnswer",
        @bestAnswer="solveAnswer",
        @cancelBestAnswer="unsolveAnswer")
      .thread-comment-form
        .thread-comment__author
          img.thread-comment__author-icon.a-user-icon(:src="currentUser.avatar_url" :title="currentUser.icon_title")
        .thread-comment-form__form.a-card
          .thread-comment-form__tabs.js-tabs
            .thread-comment-form__tab.js-tabs__tab(:class="{'is-active': isActive('answer')}" @click="changeActiveTab('answer')")
              | コメント
            .thread-comment-form__tab.js-tabs__tab(:class="{'is-active': isActive('preview')}" @click="changeActiveTab('preview')")
              | プレビュー
          .thread-comment-form__markdown-parent.js-markdown-parent
            .thread-comment-form__markdown.js-tabs__content(:class="{'is-active': isActive('answer')}")
              markdown-textarea(v-model="description" id="js-new-comment" class="a-text-input js-warning-form thread-comment-form__textarea js-markdown" name="answer[description]")
            .thread-comment-form__markdown.js-tabs__content(:class="{'is-active': isActive('preview')}")
              .js-preview.is-long-text.thread-comment-form__preview(v-html="markdownDescription")
          .thread-comment-form__actions
            .thread-comment-form__action
              button#js-shortcut-post-comment.a-button.is-lg.is-warning.is-block(@click="createAnswer" :disabled="!validation || buttonDisabled")
                | コメントする
</template>
<script>
import Answer from "./answer.vue";
import MarkdownTextarea from "./markdown-textarea.vue";
import MarkdownIt from "markdown-it";
import MarkdownItEmoji from "markdown-it-emoji";
import MarkdownItMention from "./packs/markdown-it-mention";

export default {
  props: ["questionId", "type", "currentUserId"],
  components: {
    answer: Answer,
    "markdown-textarea": MarkdownTextarea
  },
  data: () => {
    return {
      currentUser: {},
      answers: [],
      description: "",
      tab: "answer",
      buttonDisabled: false,
      question: { correctAnswer: null },
      questionUser: {}
    };
  },
  created: function() {
    fetch(`/api/users/${this.currentUserId}.json`, {
      method: "GET",
      headers: {
        "X-Requested-With": "XMLHttpRequest"
      },
      credentials: "same-origin",
      redirect: "manual"
    })
      .then(response => {
        return response.json();
      })
      .then(json => {
        for (var key in json) {
          this.$set(this.currentUser, key, json[key]);
        }
      })
      .catch(error => {
        console.warn("Failed to parsing", error);
      });
    fetch(`/api/answers.json?question_id=${this.questionId}`, {
      method: "GET",
      headers: {
        "X-Requested-With": "XMLHttpRequest"
      },
      credentials: "same-origin",
      redirect: "manual"
    })
      .then(response => {
        return response.json();
      })
      .then(json => {
        for (var key in json) {
          this.$set(this.questionUser, key, json[key]);
        }
        json.forEach(c => {
          this.answers.push(c);
        });
      })
      .catch(error => {
        console.warn("Failed to parsing", error);
      });
  },
  mounted: function() {
    $("textarea").textareaAutoSize();
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]');
      return meta ? meta.getAttribute("content") : "";
    },
    isActive: function(tab) {
      return this.tab == tab;
    },
    changeActiveTab: function(tab) {
      this.tab = tab;
    },
    createAnswer: function(event) {
      if (this.description.length < 1) {
        return null;
      }
      this.buttonDisabled = true;
      let params = {
        answer: { description: this.description },
        question_id: this.questionId
      };
      fetch(`/api/answers`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": this.token()
        },
        credentials: "same-origin",
        redirect: "manual",
        body: JSON.stringify(params)
      })
        .then(response => {
          return response.json();
        })
        .then(json => {
          this.answers.push(json);
          this.description = "";
          this.tab = "answer";
          this.buttonDisabled = false;
        })
        .catch(error => {
          console.warn("Failed to parsing", error);
        });
    },
    deleteAnswer: function(id) {
      fetch(`/api/answers/${id}.json`, {
        method: "DELETE",
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": this.token()
        },
        credentials: "same-origin",
        redirect: "manual"
      })
        .then(response => {
          this.answers.forEach((answer, i) => {
            if (answer.id == id) {
              this.answers.splice(i, 1);
            }
          });
        })
        .catch(error => {
          console.warn("Failed to parsing", error);
        });
    },
    solveAnswer: function(id) {
      let params = {
        question_id: this.questionId
      }; 
      fetch(`/api/answers/${id}/correct_answer`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": this.token()
        },
        credentials: "same-origin",
        redirect: "manual",
        body: JSON.stringify(params)
      })
        .then(response => {
          return response.json();
        })
        .then(json => {
          this.answers.forEach((answer, i) => {
            if (answer.id == json.id) {
              answer.type = "CorrectAnswer";
            }
          });
        })
        .catch(error => {
          console.warn("Failed to parsing", error);
        });
    },
    unsolveAnswer: function(id) {
      let params = {
        question_id: this.questionId
      };
      fetch(`/api/answers/${id}/correct_answer`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": this.token()
        },
        credentials: "same-origin",
        redirect: "manual",
        body: JSON.stringify(params)
      })
        .then(response => {
          this.answers.forEach((answer, i) => {
            if (answer.id == id) {
              answer.type = "";
            }
          });
        })
        .catch(error => {
          console.warn("Failed to parsing", error);
        });
    }
  },
  computed: {
    markdownDescription: function() {
      const md = new MarkdownIt({
        html: true,
        breaks: true,
        linkify: true,
        langPrefix: "language-"
      });
      md.use(MarkdownItEmoji).use(MarkdownItMention);
      return md.render(this.description);
    },
    validation: function() {
      return this.description.length > 0;
    },
    hasCorrectAnswer: function() {
      return this.answers.some(answer => (answer.type === "CorrectAnswer"));
    }
  }
};
</script>
