<template lang="pug">
.filterDropdown
  .form-item.is-inline-md-up
    label.a-form-label(for='js-choices-single-select') {{ label }}
    select#js-choices-single-select(@change='updateValue')
      option(
        v-for='(option, index) in options',
        :value='option.id',
        :key='index') {{ option.title }}
</template>

<script>
export default {
  name: 'FilterDropdown',
  props: {
    label: {
      type: String,
      required: true
    },
    options: {
      type: Array,
      required: true
    }
  },
  methods: {
    updateValue(element) {
      this.$emit('input', element.target.value)
    }
  }
}
</script>
