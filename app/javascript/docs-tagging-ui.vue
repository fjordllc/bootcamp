<template>
  <div>
    <Tags v-bind:settings="tagifySettings" initialValue="a,b,c" :onChange="onTagsChange"/>
  </div>
</template>

<script>
import Tags from "@yaireo/tagify/dist/tagify.vue";


export default {
  name: "App",
  components: { Tags },
  data() {
    return {
      tagifySettings: {
        whitelist: [],
        callbacks: {
          add(e) {
            console.log("tag added:", e.detail);
          }
        }
      },
      suggestions: []
    };
  },
  methods: {
    onTagsChange(e) {
      console.log("tags changed:", e.target.value);
    }
  },
  mounted() {
    // simulate fetchign async data and updating the sugegstions list
    // do not create a new Array, but use the SAME ONE
    setTimeout(() => {
      this.suggestions = [
        { value: "ironman", code: "im" },
        { value: "antman", code: "am" },
        { value: "captain america", code: "ca" },
        { value: "thor", code: "th" },
        { value: "spiderman", code: "sm" }
      ];

      this.tagifySettings.whitelist.length = 0;
      this.tagifySettings.whitelist.push(...this.suggestions);
    }, 1000);
  }
};
</script>

<style lang="scss">

.tagify {
  margin-bottom: 3em;
  background-color: #ffffff;
}

</style>
