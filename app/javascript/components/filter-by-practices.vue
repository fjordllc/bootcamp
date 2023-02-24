<template lang='pug'>
div
  | {{practice.id}} - {{practice.title}}
</template>
<script>
export default {
  props: {
    practice: { type: Object, required: true }
  }
}
</script>
