<template>
  <div>Hello {{ id }}</div>
</template>
<script>
export default {
  name: 'Hello',
  props: {
    id: { type: Number, required: true }
  }
}
</script>
