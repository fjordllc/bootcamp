<template lang="pug">
  .thread-timeline-container
    .thread-timeline-form.a-card(v-show="currentUrl === '/timelines' || userId === currentUser.id")
      .thread-timeline__author
        img.thread-timeline__author-icon.a-user-icon(:src="currentUser.avatar_url" :title="currentUser.icon_title")
      .thread-timeline-form__form.a-card
        .thread-timeline-form__markdown-parent.js-markdown-parent
          markdown-textarea(v-model="description" id="js-new-timeline" class="a-text-input js-warning-form thread-timeline-form__textarea js-markdown" name="new_timeline[description]")
        .thread-timeline-form__actions
          .thread-timeline-form__action
            button(v-on:click="createTimeline" :disabled="!validation || buttonDisabled")
              | 投稿する
    .thread-timelines
      timeline(v-for="(timeline, index) in timelines"
        :key="timeline.id"
        :timeline="timeline"
        :currentUser="currentUser"
        @update="updateTimeline"
        @delete="deleteTimeline")
</template>
<script>
  import Timeline from './timeline.vue'
  import MarkdownTextarea from '../markdown-textarea'

  export default {
    components: {
      'timeline': Timeline,
      'markdown-textarea': MarkdownTextarea
    },
    data: () => {
      return {
        currentUser: {},
        description: '',
        timelines: [],
        timelinesChannel: null,
        buttonDisabled: false
      }
    },
    created () {
      this.timelinesChannel = this.$cable.subscriptions.create({channel: this.selectChannel(), user_id: this.userId}, {
        connected: () => {
          console.log('connected successfully');
        },

        received: (data) => {
          switch (data.event) {
            case 'subscribe':
              this.currentUser = data.current_user
              this.timelines = []
              data.timelines.forEach((timeline) => {
                this.timelines.unshift(timeline)
              });
              break
            case 'failed_to_subscribe':
              console.warn('Failed to subscribe');
              break
            case 'create_timeline':
              this.timelines.unshift(data.timeline);
              this.description = '';
              break
            case 'failed_to_create_timeline':
              console.warn('Failed to create timeline');
              break
            case 'update_timeline':
              this.timelines.forEach((timeline) => {
                if (timeline.id === data.timeline.id) {
                  timeline.description = data.timeline.description
                }
              });
              break
            case 'failed_to_update_timeline':
              console.warn('Failed to update timeline');
              break
            case 'delete_timeline':
              this.timelines.forEach((timeline, i) => {
                if (timeline.id === data.timeline.id) {
                  this.timelines.splice(i, 1)
                }
              });
              break
            case 'failed_to_delete_timeline':
              console.warn('Failed to delete timeline');
              break
          }
        }
      })
    },
    methods: {
      createTimeline: function () {
        if (this.description.length < 1) { return null }
        this.buttonDisabled = true;
        let params = {
          'timeline': { 'description': this.description },
        }
        this.timelinesChannel.perform('create_timeline', params);
        this.buttonDisabled = false;
      },
      updateTimeline: function (data) {
        this.timelinesChannel.perform('update_timeline', data);
      },
      deleteTimeline: function (data) {
        this.timelinesChannel.perform('delete_timeline', data);
      },
      selectChannel: function () {
        if (location.pathname === '/timelines') {
          return 'TimelinesChannel'
        } else {
          return 'Users::TimelinesChannel'
        }
      }
    },
    computed: {
      validation: function () {
        return this.description.length > 0
      },
      currentUrl: function () {
        return location.pathname
      },
      userId: function () {
        return parseInt(location.pathname.match(/[0-9]+/))
      }
    }
  }
</script>
