<template lang="pug">
  .thread-timeline.a-card
    .thread-timeline__author
      a.thread-timeline__author-link(:href="timeline.user.path" itempro="url")
        img.thread-timeline__author-icon.a-user-icon(:src="timeline.user.avatar_url" :title="timeline.user.icon_title"  v-bind:class="userRole")
    .thread-timeline__body.a-card(v-if="!editing")
      header.thread-timeline__body-header
        a.thread-timeline__title-link(:href="timeline.user.path" itempro="url")
          | {{ timeline.user.login_name }}
        time.thread-timeline__created-at(:datetime="createdAt" pubdate="pubdate")
          | {{ createdAt }}
        .card-header-actions(v-if="this.timeline.user.id === this.currentUser.id")
          ul.card-header-actions__items
            li.card-header-actions__item
              button.card-header-actions__action.a-button(@click="editing = !editing")
                i.fas.fa-pen
                  | 編集
            li.card-header-actions__item
              button.card-header-actions__action.a-button(@click="deleteTimeline")
                i.fas.fa-trash-alt
                  | 削除
      .thread-timeline__description.js-target-blank.is-long-text(v-if="!editing" v-html="markdownDescription")
    .thread-timeline-form__form.a-card(v-show="editing")
      markdown-textarea(v-model="description" :class="classTimelineId" class="a-text-input js-warning-form thread-timeline-form__textarea js-timeline-markdown" name="timeline[description]")
      button(v-on:click="updateTimeline" v-bind:disabled="!validation")
        | 保存する
      button(v-on:click="cancel")
        | キャンセル
</template>
<script>
  import MarkdownTextarea from '../markdown-textarea'
  import MarkdownIt from 'markdown-it'
  import MarkdownItEmoji from 'markdown-it-emoji'
  import moment from 'moment'

  export default {
    props: ['timeline', 'currentUser'],
    components: {
      'markdown-textarea': MarkdownTextarea
    },
    data: () => {
      return {
        description: '',
        editing: false,
      }
    },
    created: function() {
      this.description = this.timeline.description;
    },
    mounted: function() {
      $('textarea').textareaAutoSize();
    },
    methods: {
      editTimeline: function() {
        this.editing = true;
      },
      cancel: function() {
        this.description = this.timeline.description;
        this.editing = false;
      },
      updateTimeline: function () {
        if (this.description.length < 1) { return null}
        let params = {
          'id' : this.timeline.id,
          'timeline' : { 'description': this.description }
        }
        this.$emit('update', params);
        this.editing = false;
      },
      deleteTimeline: function () {
        let params = {
          'id' : this.timeline.id
        }
        if (window.confirm('削除してよろしいですか？')) {
          this.$emit('delete', params);
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
        md.use(MarkdownItEmoji)
        return md.render(this.timeline.description);
      },
      classTimelineId: function() {
        return `timeline-id-${this.timeline.id}`
      },
      userRole: function(){
        return `is-${this.timeline.user.role}`
      },
      createdAt: function() {
        return moment(this.timeline.created_at).format('YYYY年MM月DD日(dd) HH:mm')
      },
      validation: function () {
        return this.description.length > 0
      }
    }
  }
</script>
