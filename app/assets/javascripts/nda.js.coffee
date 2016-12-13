$ ->
  if $('#user_nda').is(':checked')
    $('.js-sign-up-action').removeClass('is-disabled')
    $('.js-nda-action').addClass('is-checked')
  else
    $('.js-sign-up-action').addClass('is-disabled')
    $('.js-nda-action').removeClass('is-checked')
  $('#user_nda').change ->
    if $('#user_nda').is(':checked')
      $('.js-sign-up-action').removeClass('is-disabled')
      $('.js-nda-action').addClass('is-checked')
    else
      $('.js-sign-up-action').addClass('is-disabled')
      $('.js-nda-action').removeClass('is-checked')
