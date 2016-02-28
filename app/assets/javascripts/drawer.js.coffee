$ ->
  $('.js-open-drawer-trigger').click ->
    trigger = $(this)
    target = $('.js-drawer-target')
    wrapper = $('.js-open-drawer-wrapper')
    if $(trigger).hasClass('is-active')
      $(target).removeClass('is-active')
      $(wrapper).removeClass('is-opened-drawer')
      $(trigger).removeClass('is-active')
    else
      $(trigger).addClass('is-active')
      $(wrapper).addClass('is-opened-drawer')
      $(target).before("<div class='is-overlay close-drawer-overlay js-close-drawer-trigger'></div>")
      $(target).addClass('is-active')

  $(document).on 'click', '.js-close-drawer-trigger', ->
    trigger = $(this)
    openTrigger = $('.js-open-drawer-trigger')
    target = $('.js-drawer-target')
    wrapper = $('.js-open-drawer-wrapper')
    $(trigger).remove()
    $(target).removeClass('is-active')
    $(wrapper).removeClass('is-opened-drawer')
    $(openTrigger).removeClass('is-active')
