$ ->
  if $('body.practices_index').length > 0

    $('.practices').on 'click', '.practice .status .not_complete', {}, ->
      tr = $(this).parent().parent().parent()
      [x, practice_id] = tr[0].id.split('_')
      $.ajax "/practices/#{practice_id}/learning",
        type: 'DELETE'
      .done =>
        console.log $('.status button', this)
        $('.status button', this).attr('disabled', true)

    $('.practices').on 'click', '.practice .status .started', {}, ->
      tr = $(this).parent().parent().parent()
      [x, practice_id] = tr[0].id.split('_')
      $.ajax "/practices/#{practice_id}/learning",
        type: 'PUT',
        data: "status=started"
      .done =>
        console.log $('.status button', this)
        $('.status .started', this).attr('disabled', true)



    # destroy
    #    $('.practices').on 'click', '.complete', {}, ->
    #      console.log 'destroy'
    #      [x, practice_id] = this.id.split('_')
    #      $.ajax "/practices/#{practice_id}/learning",
    #        type: 'DELETE'
    #      .done =>
    #        $("#practice_#{practice_id}").
    #          removeClass('complete').addClass('not_complete').
    #        $("#practice_#{practice_id} .status button").text('未完了')
