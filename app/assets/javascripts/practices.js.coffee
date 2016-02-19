$ ->
  if $('body.practices_index').length > 0
    $('.category-practices').on 'click', '.js-practice-state', {}, ->
      status = $(this).data('status')
      tr = $(this).parents('.js-practice')
      [x, practice_id] = tr[0].id.split('_')
      $.ajax "/practices/#{practice_id}/learning",
        type: 'PUT'
        data: "status=#{status}"
      .done =>
        $('.js-practice-state:disabled', tr).attr('disabled', false).removeClass('btn-success').addClass('btn-secondary')
        $(this).attr('disabled', true).addClass('btn-success')
$ ->
  $(".js-target-blank a").click ->
    window.open @href, ""
    false
