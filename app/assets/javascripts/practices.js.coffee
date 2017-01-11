$ ->
  if $('body.practices-index').length > 0
    $('.js-category-practices').on 'click', '.js-practice-state', {}, ->
      console.log("ffff")
      status = $(this).data('status')
      tr = $(this).parents('.js-practice')
      [x, practice_id] = tr[0].id.split('_')
      $.ajax "/practices/#{practice_id}/learning",
        type: 'PUT'
        data: "status=#{status}"
        console.log("iiii")
      .done =>
        $('.js-practice-state:disabled', tr).attr('disabled', false).removeClass('is-button-standard-xs-primary').addClass('is-button-standard-xs-secondary')
        $(this).attr('disabled', true).addClass('is-button-standard-xs-primary')
        console.log("66666")
$ ->
  $(".js-target-blank a").click ->
    window.open @href, ""
    false
