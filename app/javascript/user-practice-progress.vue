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
  .completed-practices-progress__percentage-number
    | {{ roundedPercentage }}
</template>
<script>
export default {
  props: {
    user: { type: Object, required: true }
  },
  data() {
    return {
      percentage: this.user.cached_completed_percentage
    }
  },
  computed: {
    roundedPercentage() {
      return Math.round(this.percentage) + '%'
    }
  }
}
</script>
