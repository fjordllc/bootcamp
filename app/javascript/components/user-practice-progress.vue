<template lang="pug">
.completed-practices-progress
  .completed-practices-progress__bar-container
    .completed-practices-progress__bar
    .completed-practices-progress__percentage-bar(
      aria-valuemax='100',
      aria-valuemin='0',
      :aria-valuenow='ariaValuenow()',
      role='progressbar',
      :style='`width: ${roundedPercentage}`')
  .completed-practices-progress__counts
    input.a-toggle-checkbox(type='checkbox', :id='`userid_${this.user.id}`')
    label.completed-practices-progress__counts-inner(
      :for='`userid_${this.user.id}`')
      .completed-practices-progress__percentage
        | {{ roundedPercentage }}
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
      fraction: this.user.cached_completed_fraction
    }
  },
  computed: {
    roundedPercentage() {
      return this.user.graduated_on ? '100%' : Math.round(this.percentage) + '%'
    }
  },
  methods: {
    ariaValuenow() {
      return this.user.graduated_on ? 100 : this.percentage
    },
    completedPracticesProgressNumber() {
      return this.user.graduated_on ? '卒業' : this.fraction
    }
  }
}
</script>
