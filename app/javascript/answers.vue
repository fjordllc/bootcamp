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
        :hasCorrectAnswer="hasCorrectAnswer",
        @delete="deleteAnswer",
        @makeToBestAnswer="makeToBestAnswer",
        @cancelBestAnswer="cancelBestAnswer")
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
              textarea.a-text-input.js-warning-form.thread-comment-form__textarea(
                v-model="description"
                id="js-new-comment"
                name="answer[description]"
                data-preview="#new-comment-preview")
            .thread-comment-form__markdown.js-tabs__content(:class="{'is-active': isActive('preview')}")
              #new-comment-preview.is-long-text.thread-comment-form__preview
          .thread-comment-form__actions
            .thread-comment-form__action
              button#js-shortcut-post-comment.a-button.is-lg.is-warning.is-block(@click="createAnswer" :disabled="!validation || buttonDisabled")
                | コメントする
</template>
<script>
import Answer from "./answer.vue";
import TextareaInitializer from './textarea-initializer'

export default {
  props: ["questionId", "questionUser", "currentUser"],
  components: {
    answer: Answer
  },
  data: () => {
    return {
      answers: [],
      description: "",
      tab: "answer",
      buttonDisabled: false,
      question: { correctAnswer: null },
      defaultTextareaSize: null
    };
  },
  created: function() {
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
        json.forEach(c => {
          this.answers.push(c);
        });

        this.updateAnswerCount()
      })
      .catch(error => {
        console.warn("Failed to parsing", error);
      });
  },
  mounted: function() {
    TextareaInitializer.initialize('#js-new-comment')
    this.setDefaultTextareaSize()
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
      fetch(this.baseUrl, {
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
          this.resizeTextarea()
          this.updateAnswerCount()
        })
        .catch(error => {
          console.warn("Failed to parsing", error);
        });
    },
    deleteAnswer: function(id) {
      fetch(`${this.baseUrl}/${id}.json`, {
        method: "DELETE",
        headers: {
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": this.token()
        },
        credentials: "same-origin",
        redirect: "manual"
      })
        .then(() => {
          this.answers.some((answer, i) => {
            if (answer.id === id) {
              this.answers.splice(i, 1);

              if (answer.type === "CorrectAnswer") {
                this.$emit('cancelSolveQuestion')
              }

              return true
            }
          });

          this.updateAnswerCount()
        })
        .catch(error => {
          console.warn("Failed to parsing", error);
        });
    },
    requestSolveQuestion: function(id, isCancel) {
      let params = {
        question_id: this.questionId
      };

      return fetch(`${this.baseUrl}/${id}/correct_answer`, {
        method: isCancel ? "PATCH" : "POST",
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "X-Requested-With": "XMLHttpRequest",
          "X-CSRF-Token": this.token()
        },
        credentials: "same-origin",
        redirect: "manual",
        body: JSON.stringify(params)
      })
    },
    findAnswerById: function(id) {
      return this.answers.find(answer => answer.id === id)
    },
    makeToBestAnswer: function(id) {
      this.requestSolveQuestion(id, false)
        .then(response => {
          return response.json();
        })
        .then((answer) => {
          this.findAnswerById(answer.id).type = "CorrectAnswer"

          this.$emit('solveQuestion', answer)
        })
        .catch(error => {
          console.warn("Failed to parsing", error);
        });
    },
    cancelBestAnswer: function(id) {
      this.requestSolveQuestion(id, true)
        .then(() => {
          this.findAnswerById(id).type = ""

          this.$emit('cancelSolveQuestion')
        })
        .catch(error => {
          console.warn("Failed to parsing", error);
        });
    },
    updateAnswerCount: function() {
      this.$emit('updateAnswerCount', this.answers.length)
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
      return this.description.length > 0;
    },
    hasCorrectAnswer: function() {
      return this.answers.some(answer => (answer.type === "CorrectAnswer"));
    },
    baseUrl: function() {
      return '/api/answers'
    }
  }
};
</script>
