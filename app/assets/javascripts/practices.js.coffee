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
