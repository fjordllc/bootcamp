<template lang="pug">
  .thread-timeline-container
    .thread-timeline-form.a-card(v-show="currentUrl === '/timelines' || userId === currentUser.id")
      .thread-timeline__author
        img.thread-timeline__author-icon.a-user-icon(:src="currentUser.avatar_url" :title="currentUser.icon_title")
      .thread-timeline-form__form.a-card
        .thread-timeline-form__markdown-parent.js-markdown-parent
          #js-new-timeline.a-text-input.js-warning-form.thread-timeline-form__textarea.js-markdown(v-model="description" name="new_timeline[description]")
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

export default {
  components: {
    'timeline': Timeline,
  },
  data: () => {
    return {
      currentUser: {},
      description: '',
      timelines: [],
      timelinesChannel: null,
      buttonDisabled: false,
      loading: false,
      subscribed: false
    }
  },
  mounted () {
    window.addEventListener('scroll', this.handleScroll, true)
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
              this.timelines.push(timeline)
            });
            this.subscribed = true
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
          case 'send_past_timelines':
            if (data.timelines.length === 0) {
              window.removeEventListener('scroll', this.handleScroll, true)
            } else {
              data.timelines.forEach((timeline) => {
                this.timelines.push(timeline)
              })
            }
            this.$nextTick(() => {
              this.loading = false
            })
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
    },
    handleScroll: function () {
      if (!this.loading && this.subscribed) {
        /*
          「次の等価式は、要素がスクロールの終点にあると true になり、それ以外は false になります。
          element.scrollHeight - element.scrollTop === element.clientHeight」

          Element.scrollHeight - Web API | MDN (https://developer.mozilla.org/ja/docs/Web/API/Element/scrollHeight)
        */
        if (document.documentElement.scrollHeight - document.documentElement.scrollTop === document.documentElement.clientHeight) {
          this.loading = true
          let oldest_timeline_on_timelines_page = { id: this.timelines.slice(-1)[0].id }
          this.timelinesChannel.perform('send_past_timelines', oldest_timeline_on_timelines_page)
        }
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
