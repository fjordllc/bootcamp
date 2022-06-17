import Vue from 'vue'
import Books from 'books.vue'

document.addEventListener('DOMContentLoaded', () => {
    const selector = '#js-books'
    const books = document.querySelector(selector)
    if (books) {
        new Vue({
            render: (h) => h(Books)
        }).$mount(selector)
    }
})
