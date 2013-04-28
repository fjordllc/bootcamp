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
        .text(I18n.t('started'))

  $(document).on 'click', 'button.started', ->
    that = this
    practice_id = getPracticeId($(this))
    $.ajax "/practices/#{practice_id}/learnings",
      type: 'PUT'
    .done ->
      $(that)
        .attr({class: 'btn complete'})
        .text(I18n.t('complete'))

  $(document).on 'click', 'button.complete', ->
    return unless confirm(I18n.t('practice_status_reset_confirmation'))
    that = this
    practice_id = getPracticeId($(this))
    $.ajax "/practices/#{practice_id}/learnings",
      type: 'DELETE'
    .done ->
      $(that)
        .attr({class: 'btn unstarted'})
        .text(I18n.t('unstarted'))

  showCompletedPractice = (display) ->
    for practice in $('tr.practice.target')
      if (not display) and $(practice).find('.btn').hasClass('complete')
        $(practice).hide()
      else
        $(practice).show()

  $(document).on 'click', '#display-switch', ->
    if $(this).hasClass('on')
      $(this).removeClass('on')
      $(this).text(I18n.t('show_completed'))
      showCompletedPractice(false)
    else
      $(this).addClass('on')
      $(this).text(I18n.t('hide_completed'))
      showCompletedPractice(true)

  $('#display-switch').click()
