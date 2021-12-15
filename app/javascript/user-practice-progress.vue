<template lang="pug">
.completed-practices-progress
  .completed-practices-progress__bar-container
    .completed-practices-progress__bar
    .completed-practices-progress__percentage-bar(
      aria-valuemax='100',
      aria-valuemin='0',
      :aria-valuenow='ariaValuenow()',
      role='progressbar',
      :style='`width: ${roundedPercentage}`'
    )
  .completed-practices-progress__number
    | {{ completedPracticesProgressNumber() }}
</template>
<script>
export default {
  props: {
    user: { type: Object, required: true }
  },
  data() {
    return {
      percentage: this.user.cached_completed_percentage,
      fraction: this.user.completed_fraction
    }
  },
  computed: {
    roundedPercentage() {
      return this.user.role === 'graduate'
        ? '100%'
        : Math.round(this.percentage) + '%'
    }
  },
  methods: {
    ariaValuenow() {
      return this.user.role === 'graduate' ? 100 : this.percentage
    },
    completedPracticesProgressNumber() {
      return this.user.role === 'graduate' ? '卒業' : this.fraction
    }
  }
}
</script>
