<template lang="pug">
  .category-practices-item.js-practice
    a.category-practices-item__anchor(:id="`practice_${category.id}`")
    header.category-practices-item__header(v-for="practices in category.practices")
      .category-practices-item__title
        a.category-practices-item__title-link(:href="practices.url")
          | {{practices.title}}
          //| {{status_by_learnings(practices.id)}}
          //ここもリンクまだ
      //if current_user
        a.practice-status category-practices-item__status is-status(:practice.id)

      .category-practices-item__learning-time
        | 所要時間の目安:
        | （平均:
      .m-user-icons
        .m-user-icons__items
</template>


<script>

export default {
  props: ['courseId','currentUserId','category','learnings',],
  data: () => {
    return {
      currentPage: 1,
      totalPages: null,
    }
  },
  methods: {
    status_by_learnings(practices){
      let le = this.learnings.find(element => practices === element.practice_id);
      if(!le) return 'unstarted';
      return le.status
    }
  }
}

</script>