<template lang="pug">
.user-icons
    h3.user-icons__title 
    | 見たよ
    ul.user-icons__items
      .user-icons__item(v-for='item in arrayCountFirstThree', :key='item.id')
        a.user-icons__item-link(:href='`${item.userProfileUrl}`')
          img(
            :title='`${item.title}`',
            :alt='`${item.alt}`',
            :class='`${item.class}`',
            :src='`${item.imgSrc}`'  
          )

      .page-content-prev-next__item-link(
        v-if='(items.length >= 10) && isDisplay',
        @click="checkSad"
        )
        | その他{{ (items.length - 10) }}人
      ul.user-icons__items(v-else)
        .user-icons__item(v-for='item in arrayCountRest', :key='item.id')
          a.user-icons__item-link(:href='`${item.userProfileUrl}`')
            img(
               :title='`${item.title}`',
               :alt='`${item.alt}`',
               :class='`${item.class}`',
               :src='`${item.imgSrc}`'       
            )
</template>
<script>
export default {
  data() {
    return {
      isDisplay: true,
      items: [
        { 
          userProfileUrl: 'https://bootcamp.fjord.jp/users/1048' ,
          title: 'N4be (なべ)',
          alt: 'N4be (なべ)',
          class: 'a-user-icons__item-icon a-user-icon is-student',
          imgSrc: 'https://storage.googleapis.com/bootcamp-fjord-jp/lz0rarhoysdxom85a75268bg1es5'
        }, 
        { 
          userProfileUrl: 'https://bootcamp.fjord.jp/users/1048' ,
          title: 'N4be (なべ)',
          alt: 'N4be (なべ)',
          class: 'a-user-icons__item-icon a-user-icon is-student',
          imgSrc: 'https://storage.googleapis.com/bootcamp-fjord-jp/lz0rarhoysdxom85a75268bg1es5'
        },
        { 
          userProfileUrl: 'https://bootcamp.fjord.jp/users/1048' ,
          title: 'N4be (なべ)',
          alt: 'N4be (なべ)',
          class: 'a-user-icons__item-icon a-user-icon is-student',
          imgSrc: 'https://storage.googleapis.com/bootcamp-fjord-jp/lz0rarhoysdxom85a75268bg1es5'
        }, 
        { 
         userProfileUrl: 'https://bootcamp.fjord.jp/users/1048' ,
          title: 'N4be (なべ)',
          alt: 'N4be (なべ)',
          class: 'a-user-icons__item-icon a-user-icon is-student',
          imgSrc: 'https://storage.googleapis.com/bootcamp-fjord-jp/lz0rarhoysdxom85a75268bg1es5'
        },
        { 
         userProfileUrl: 'https://bootcamp.fjord.jp/users/1048' ,
          title: 'N4be (なべ)',
          alt: 'N4be (なべ)',
          class: 'a-user-icons__item-icon a-user-icon is-student',
          imgSrc: 'https://storage.googleapis.com/bootcamp-fjord-jp/lz0rarhoysdxom85a75268bg1es5'
        }, 
        { 
          userProfileUrl: 'https://bootcamp.fjord.jp/users/1048' ,
          title: 'N4be (なべ)',
          alt: 'N4be (なべ)',
          class: 'a-user-icons__item-icon a-user-icon is-student',
          imgSrc: 'https://storage.googleapis.com/bootcamp-fjord-jp/lz0rarhoysdxom85a75268bg1es5'
        },
        { 
          userProfileUrl: 'https://bootcamp.fjord.jp/users/1048' ,
          title: 'N4be (なべ)',
          alt: 'N4be (なべ)',
          class: 'a-user-icons__item-icon a-user-icon is-student',
          imgSrc: 'https://storage.googleapis.com/bootcamp-fjord-jp/lz0rarhoysdxom85a75268bg1es5'
        }, 
        { 
          userProfileUrl: 'https://bootcamp.fjord.jp/users/1048' ,
          title: 'N4be (なべ)',
          alt: 'N4be (なべ)',
          class: 'a-user-icons__item-icon a-user-icon is-student',
          imgSrc: 'https://storage.googleapis.com/bootcamp-fjord-jp/lz0rarhoysdxom85a75268bg1es5'
        },
        { 
          userProfileUrl: 'https://bootcamp.fjord.jp/users/1048' ,
          title: 'N4be (なべ)',
          alt: 'N4be (なべ)',
          class: 'a-user-icons__item-icon a-user-icon is-student',
          imgSrc: 'https://storage.googleapis.com/bootcamp-fjord-jp/lz0rarhoysdxom85a75268bg1es5'
        }, 
        { 
          userProfileUrl: 'https://bootcamp.fjord.jp/users/1048' ,
          title: 'N4be (なべ)',
          alt: 'N4be (なべ)',
          class: 'a-user-icons__item-icon a-user-icon is-student',
          imgSrc: 'https://storage.googleapis.com/bootcamp-fjord-jp/lz0rarhoysdxom85a75268bg1es5'
        },
        { 
          userProfileUrl: 'https://bootcamp.fjord.jp/users/1048' ,
          title: 'N4be (なべ)',
          alt: 'N4be (なべ)',
          class: 'a-user-icons__item-icon a-user-icon is-student',
          imgSrc: 'https://storage.googleapis.com/bootcamp-fjord-jp/lz0rarhoysdxom85a75268bg1es5'
        }, 
        { 
          userProfileUrl: 'https://bootcamp.fjord.jp/users/1048' ,
          title: 'N4be (なべ)',
          alt: 'N4be (なべ)',
          class: 'a-user-icons__item-icon a-user-icon is-student',
          imgSrc: 'https://storage.googleapis.com/bootcamp-fjord-jp/lz0rarhoysdxom85a75268bg1es5'
        }
      ]
    }
  },
  computed: {
  	arrayCountFirstThree (){
    	return this.items.slice(0, 10)
    },
    arrayCountRest (){
    	return this.items.slice(10)
    }
  },
  methods: {
    checkSad() {
      this.isDisplay = false
    }
  }
}
</script>