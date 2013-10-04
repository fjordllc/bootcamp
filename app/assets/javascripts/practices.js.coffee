$ ->
  getPracticeId = (element) ->
    element.attr('id').split('-')[1]

  $(document).on 'click', 'button.unstarted', ->
    that = this
    practice_id = getPracticeId($(this))
    $.ajax "/practices/#{practice_id}/learnings",
      type: 'POST'
    .done ->
      $(that)
        .attr({class: 'btn started'})
        .text('started')

  $(document).on 'click', 'button.started', ->
    that = this
    practice_id = getPracticeId($(this))
    $.ajax "/practices/#{practice_id}/learnings",
      type: 'PUT'
    .done ->
      $(that)
        .attr({class: 'btn complete'})
        .text('complete')

  $(document).on 'click', 'button.complete', ->
    return unless confirm('practice_status_reset_confirmation')
    that = this
    practice_id = getPracticeId($(this))
    $.ajax "/practices/#{practice_id}/learnings",
      type: 'DELETE'
    .done ->
      $(that)
        .attr({class: 'btn unstarted'})
        .text('unstarted')

  showCompletedPractice = (display) ->
    for practice in $('tr.practice.target')
      if (not display) and $(practice).find('.btn').hasClass('complete')
        $(practice).hide()
      else
        $(practice).show()

  $(document).on 'click', '#display-switch', ->
    if $(this).hasClass('on')
      $(this).removeClass('on')
      $(this).text('show_completed')
      showCompletedPractice(false)
    else
      $(this).addClass('on')
      $(this).text('hide_completed')
      showCompletedPractice(true)

  $('#display-switch').click()
