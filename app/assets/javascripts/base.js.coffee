$ ->
  smoothScroll.init()

  $('.js-marked').on 'click', ->
    console.log("aaaa")
    $('pre').addClass('line-numbers')
