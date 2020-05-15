<template lang="pug">
  .thread-comment(:class=" answer1 ? 'is-correct_answer' : '' ")
    .thread-comment__author
      a.thread-comment__author-link(:href="answer.user.url" itempro="url")
        img.thread-comment__author-icon.a-user-icon(:src="answer.user.avatar_url" :title="answer.user.icon_title"  v-bind:class="userRole")
    .thread-comment__body.a-card(v-if="!editing")
      //- .answer-badge(v-if="answer == correctAnswer")
      .answer-badge(v-if="correctAnswer")
        .answer-badge__icon
          i.fas.fa-star
        .answer-badge__label ベストアンサー
      header.thread-comment__body-header
        h2.thread-comment__title
          a.thread-comment__title-link(:href="answer.user.url" itempro="url")
            | {{ answer.user.login_name }}
        time.thread-comment__created-at(:datetime="answerCreatedAt" pubdate="pubdate" @click="copyAnswerURLToClipboard(answer.id)")
          | {{ updatedAt }}
      .thread-comment__description.js-target-blank.is-long-text(v-html="markdownDescription")
      reaction(
        v-bind:reactionable="answer",
        v-bind:currentUser="currentUser")
      footer.card-footer(v-if="answer.user.id == currentUser.id || currentUser.role == 'admin'")
        .card-footer-actions
          ul.card-footer-actions__items
            //- li.card-footer-actions__item(v-show="answer != correctAnswer && (currentUser.role == question.user || 'admin')")
            //- answer.type != correctAnswerかも
            li.card-footer-actions__item(v-if="!correctAnswer && answer != correctAnswer && (currentUser.role == question.user || 'admin')")
              button.card-footer-actions__action.a-button.is-md.is-warning.is-block(@click="solveAnswer")
                | 解決にする
            li.card-footer-actions__item(v-if="answer.user.id == currentUser.id || currentUser.role == 'admin'")
              button.card-footer-actions__action.a-button.is-md.is-primary.is-block(@click="editAnswer")
                i.fas.fa-pen
                  | 内容修正
            li.card-footer-actions__item(v-if="answer.user.id == currentUser.id || currentUser.role == 'admin'")
              button.card-footer-actions__action.a-button.is-md.is-danger.is-block(@click="deleteAnswer")
                i.fas.fa-trash-alt
                  | 削除
            //- li.card-footer-actions__item(v-if="typeof correctAnswer !== 'undefined' && answer == correctAnswer")
            //- answer.type == correctAnswerかも
            li.card-footer-actions__item(v-if="correctAnswer && answer == correctAnswer && (currentUser.role == question.user || 'admin')")
              button.card-footer-actions__action.a-button.is-md.is-warning.is-block(@click="unsolveAnswer")
                | ベストアンサーを取り消す
    .thread-comment-form__form.a-card(v-show="editing")
      .thread-comment-form__tabs.js-tabs
        .thread-comment-form__tab.js-tabs__tab(v-bind:class="{'is-active': isActive('answer')}" @click="changeActiveTab('answer')")
          | コメント
        .thread-comment-form__tab.js-tabs__tab(v-bind:class="{'is-active': isActive('preview')}" @click="changeActiveTab('preview')")
          | プレビュー
      .thread-comment-form__markdown-parent.js-markdown-parent
        .thread-comment-form__markdown.js-tabs__content(v-bind:class="{'is-active': isActive('answer')}")
          markdown-textarea(v-model="description" :class="classAnswerId" class="a-text-input js-warning-form thread-comment-form__textarea js-comment-markdown" name="answer[description]")
        .thread-comment-form__markdown.js-tabs__content(v-bind:class="{'is-active': isActive('preview')}")
          .js-preview.is-long-text.thread-comment-form__preview(v-html="markdownDescription")
      .thread-comment-form__actions
        .thread-comment-form__action
          button.a-button.is-md.is-warning.is-block(@click="updateAnswer" v-bind:disabled="!validation")
            | 保存する
        .thread-comment-form__action
          button.a-button.is-md.is-secondary.is-block(@click="cancel")
            | キャンセル
</template>
<script>
import Reaction from "./answer-reaction.vue";
import MarkdownTextarea from "./markdown-textarea.vue";
import MarkdownIt from "markdown-it";
import MarkdownItEmoji from "markdown-it-emoji";
import MarkdownItMention from "./packs/markdown-it-mention";
import Tribute from "tributejs";
import TextareaAutocomplteEmoji from "classes/textarea-autocomplte-emoji";
import TextareaAutocomplteMention from "classes/textarea-autocomplte-mention";
import moment from "moment";

moment.locale("ja");

export default {
  props: ["answer", "currentUser", "availableEmojis", "correctAnswer"],
  components: {
    reaction: Reaction,
    "markdown-textarea": MarkdownTextarea
  },
  data: () => {
    return {
      description: "",
      editing: false,
      isCopied: false,
      tab: "answer",
      question: ""
      // correctAnswer: this.correctAnswer
      // correctAnswer: false
      // correctAnswer: null
    };
  },
  created: function() {
    this.description = this.answer.description;
    this.question = this.answer.question;
    this.correctAnswer = this.question.correctAnswer;
    console.log(this.answer);
    // console.log(this.question);
    // console.log(this.correctAnswer);
    // そもそもanswerにcorrectAnswerが入っていない
  },
  mounted: function() {
    this.correctAnswer = this.question.correctAnswer;
    $("textarea").textareaAutoSize();
    const textareas = document.querySelectorAll(`.answer-id-${this.answer.id}`);
    const emoji = new TextareaAutocomplteEmoji();
    const mention = new TextareaAutocomplteMention();

    mention.fetchValues(json => {
      mention.values = json;
      const collection = [emoji.params(), mention.params()];
      const tribute = new Tribute({ collection: collection });
      tribute.attach(textareas);
    });

    const answerAnchor = location.hash;
    if (answerAnchor) {
      this.$nextTick(() => {
        location.href = location.href;
      });
    }
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
    cancel: function() {
      this.description = this.answer.description;
      this.editing = false;
    },
    editAnswer: function() {
      this.editing = true;
      this.$nextTick(function() {
        $(`.answer-id-${this.answer.id}`).trigger("input");
      });
    },
    // editComment: function() {
    //   this.editing = true;
    //   this.$nextTick(function() {
    //     $(`.comment-id-${this.comment.id}`).trigger('input');
    //   })
    // },
    solveAnswer: function() {
      // this.correctAnswer = this.answer;
      
      // this.correctAnswer = true;

      // this.$nextTick(function() {
      //   if (window.confirm("本当に宜しいですか？")) {
      //     this.$emit("post", this.answer.id);
      //   }
      // });
      if (window.confirm("本当に宜しいですか？")) {
        this.correctAnswer = this.answer;
        this.$emit("post", this.answer.id);
      }
    },
    unsolveAnswer: function() {
      // 先に
      // this.correctAnswer = null;
      // this.$nextTick(function() {
      //   if (window.confirm("本当に宜しいですか？")) {
      //     this.$emit("patch", this.answer.id);
      //   }
      // });
      if (window.confirm("本当に宜しいですか？")) {
        this.correctAnswer = null;
        this.$emit("patch", this.answer.id);
      }
    },
    updateAnswer: function() {
      if (this.description.length < 1) {
        return null;
      }
      let params = {
        answer: { description: this.description }
      };
      fetch(`/api/answers/${this.answer.id}`, {
        method: "PUT",
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
          this.editing = false;
        })
        .catch(error => {
          console.warn("Failed to parsing", error);
        });
    },
    deleteAnswer: function() {
      if (window.confirm("削除してよろしいですか？")) {
        this.$emit("delete", this.answer.id);
      }
    },
    copyAnswerURLToClipboard(answerId) {
      const answerURL = location.href.split("#")[0] + "#answer_" + answerId;
      const textBox = document.createElement("textarea");
      textBox.setAttribute("type", "hidden");
      textBox.textContent = answerURL;
      document.body.appendChild(textBox);
      textBox.select();
      document.execCommand("copy");
      document.body.removeChild(textBox);
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
    answerCreatedAt: function() {
      return moment(this.answer.question.created_at).format();
    },
    updatedAt: function() {
      return moment(this.answer.updated_at).format("YYYY年MM月DD日(dd) HH:mm");
    },
    userRole: function() {
      return `is-${this.answer.user.role}`;
    },
    answer1() {
      return this.answer.question.correctAnswer;
    },
    test() {
      // これは機能している
      return (
        (this.correctAnswer &&
          this.answer != this.correctAnswer &&
          this.currentUser.role == this.question.user) ||
        "admin"
      );
    },
    // checkId() {
    //   return this.$store.getters.checkId
    // },
    // buttonLabel() {
    //   return this.checkableLabel + (this.checkId ? 'の確認を取り消す' : 'を確認')
    // },
    classAnswerId: function() {
      return `answer-id-${this.answer.id}`;
    },
    validation: function() {
      return this.description.length > 0;
    }
  }
};
</script>
