$ ->
  getPracticeId = ($element) ->
    $element.attr('id').split('-')[1]

  $('button.unstarted').on 'click', ->
    return if $(this).hasClass('disabled')
    practice_id = getPracticeId($(this).parent())
    $.ajax "/practices/#{practice_id}/start",
      type: 'POST'
    .done ->
      $.each $("#practice-#{practice_id}").children(), (i, element)->
        if $(element).hasClass('active')
          $(element).removeClass('disabled')
        else
          $(element).addClass('disabled')

  $('button.active').on 'click', ->
    return if $(this).hasClass('disabled')
    practice_id = getPracticeId($(this).parent())
    $.ajax "/practices/#{practice_id}/finish",
      type: 'PUT'
    .done ->
      $.each $("#practice-#{practice_id}").children(), (i, element)->
        if $(element).hasClass('complete')
          $(element).removeClass('disabled')
        else
          $(element).addClass('disabled')

  $('button.complete').on 'click', ->
    return if $(this).hasClass('disabled')
    practice_id = getPracticeId($(this).parent())
    $.ajax "/practices/#{practice_id}/destroy",
      type: 'DELETE'
    .done ->
      $.each $("#practice-#{practice_id}").children(), (i, element)->
        if $(element).hasClass('unstarted')
          $(element).removeClass('disabled')
        else
          $(element).addClass('disabled')
