/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
require('chartkick')
require('chart.js')
require('./markdown.js')
require('./markdown-it.js')
require('./autosize.js')
require('../shortcut.js')
require('../check.js')
require('../check-stamp.js')
require('../unconfirmed-links-open.js')
require('../category-select.js')
require('../grass.js')
require('../fileinput.js')
require('../reaction.js')
require('../reservations.js')
require('../card.js')
require('../textarea-autocomplete.js')
require('../watch.js')
require('../checkBox.js')
require('../js-select2.js')
require('../learningTime.js')
require('../showHandle.js')
require('../warning.js')
require('../date-input-toggler')
require('../answers.js')

import comments from "../comments.vue"
import answers from "../answers.vue"
import memo from "../memo.vue"
import learning from '../learning.vue'
import learningStatus from '../learning-status.vue'
import Vue from 'vue/dist/vue.esm';

console.log(learning)
document.addEventListener('DOMContentLoaded', () => {
var app = new Vue({
    el: '.page-body',
    components: {
        comments,
        answers,
        memo,
        learning,
        learningStatus
    }

  })
})