$ ->
  if $('body.practices_index').length > 0
    $('.practices').on 'click', '.practice .status button', {}, ->
      status = $(this).data('status')
      tr = $(this).parent().parent().parent()
      [x, practice_id] = tr[0].id.split('_')
      $.ajax "/practices/#{practice_id}/learning",
        type: 'PUT'
        data: "status=#{status}"
      .done =>
        $('.status button:disabled', tr).attr('disabled', false).removeClass('btn-success')
        $(this).attr('disabled', true).addClass('btn-success')
