<template lang="pug">
.completed-practices-progress
  .completed-practices-progress__bar-container
    .completed-practices-progress__bar
    .completed-practices-progress__percentage-bar(
      aria-valuemax='100',
      aria-valuemin='0',
      :aria-valuenow='percentage',
      role='progressbar',
      :style='`width: ${roundedPercentage}`'
    )
  .completed-practices-progress__number
    | {{ fraction }}
</template>
<script>
export default {
  props: {
    user: { type: Object, required: true }
  },
  data() {
    if (this.user.role === 'graduate') {
      return {
        percentage: 100,
        fraction: '卒業'
      }
    } else {
      return {
        percentage: this.user.cached_completed_percentage,
        fraction: this.user.completed_fraction
      }
    }
  },
  computed: {
    roundedPercentage() {
      return Math.round(this.percentage) + '%'
    }
  }
}
</script>
