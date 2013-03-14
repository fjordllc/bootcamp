$ ->
  getPracticeId = ($element) ->
    $element.attr('id').split('-')[1]

  $(document).on 'click', '.status.unstarted', ->
    that = this
    practice_id = getPracticeId($(this))
    $.ajax "/practices/#{practice_id}/start",
      type: 'POST'
    .done ->
      $(that).attr({ class: 'status active' })
      $(that).children().attr({ class: 'btn btn-info' }).text 'active'

  $(document).on 'click', '.status.active', ->
    that = this
    practice_id = getPracticeId($(this))
    $.ajax "/practices/#{practice_id}/finish",
      type: 'PUT'
    .done ->
      $(that).attr({ class: 'status complete' })
      $(that).children().attr({ class: 'btn btn-success' }).text 'complete'

  $(document).on 'click', '.status.complete', ->
    that = this
    practice_id = getPracticeId($(this))
    $.ajax "/practices/#{practice_id}/destroy",
      type: 'DELETE'
    .done ->
      $(that).attr({ class: 'status unstarted' })
      $(that).children().attr({ class: 'btn' }).text 'unstarted'

