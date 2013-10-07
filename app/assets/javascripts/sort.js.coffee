#$ ->
#  $('.practices tbody').sortable
#    axis: "y"
#    item: ".practice"
#    handle: ".handle"
#    update: (e, ui) ->
#      id = ui.item[0].id.split('_')[1]
#      position = ui.item.index()
#      console.log id
#      console.log position
#      $.ajax
#        type: 'PUT',
#        url: "/practices/#{id}.json",
#        dataType: 'json',
#        data: { practice: { row_order: position } }
