<template>
  <div>Hello {{ id }}</div>
</template>
<script>
export default {
  name: 'hello',
  props: {
    id: { type: Number, required: true }
  }
}
</script>
