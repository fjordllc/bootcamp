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
        .text('開始')

  $(document).on 'click', 'button.started', ->
    that = this
    practice_id = getPracticeId($(this))
    $.ajax "/practices/#{practice_id}/learnings",
      type: 'PUT'
    .done ->
      $(that)
        .attr({class: 'btn complete'})
        .text('完了')

  $(document).on 'click', 'button.complete', ->
    return unless confirm('未着手に戻してよろしいですか？')
    that = this
    practice_id = getPracticeId($(this))
    $.ajax "/practices/#{practice_id}/learnings",
      type: 'DELETE'
    .done ->
      $(that)
        .attr({class: 'btn unstarted'})
        .text('未着手')

  showCompletedPractice = (display) ->
    for practice in $('tr.practice.target')
      if (not display) and $(practice).find('.btn').hasClass('complete')
        $(practice).hide()
      else
        $(practice).show()

  $(document).on 'click', '#display-switch', ->
    if $(this).hasClass('on')
      $(this).removeClass('on')
      $(this).text('完了済みプラクティスも表示する')
      showCompletedPractice(false)
    else
      $(this).addClass('on')
      $(this).text('完了済みプラクティスを隠す')
      showCompletedPractice(true)

  $('#display-switch').click()
