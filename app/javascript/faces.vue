<template lang="pug">
  .faces__items
    .faces-item(v-for="(face, index) in faces")
      .faces-item__image
        img(:src="face.face" width="72" height="72")
      .faces-item__name {{ face.login_name }}
</template>
<script>
  import 'whatwg-fetch'

  export default {
    data: () => {
      return {
        faces: [],
      }
    },
    created: function() {
      this.fetchFaces();
      setInterval(this.fetchFaces, 30 * 1000);
    },
    mounted: function() {
    },
    methods: {
      fetchFaces: function(event) {
        fetch('/api/faces', {
          method: 'GET',
          headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
          },
          credentials: 'same-origin',
        }).then((response) => {
          return response.json();
        }).then((json) => {
          this.faces = json;
        }).catch((error) => {
          console.warn('parsing failed', error)
        })
      }
    },
    computed: {
    }
  }
</script>
<style scoped>
</style>
