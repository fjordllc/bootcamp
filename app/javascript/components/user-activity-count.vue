<template lang="pug">
.card-counts__item
  .card-counts__item-inner
    dt.card-counts__item-label
      | {{ activityName }}
    dd.card-counts__item-value(:class='activityCount == 0 ? "is-empty" : ""')
      span(v-if='activityCount == 0')
        | {{ activityCount }}
      a.a-text-link(v-else)(:href='activityUrl')
        | {{ activityCount }}
</template>
<script>
export default {
  props: {
    activityName: { type: Object, required: true },
    activityCount: { type: Object, required: true },
    activityUrl: { type: Object, required: true }
  }
}
</script>
