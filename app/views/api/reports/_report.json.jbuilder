json.id report.id
json.title truncate(raw(report.title), length: 46)
json.reportedOn l(report.reported_on)
json.url report_url(report)
json.editURL edit_report_path(report)
json.newURL new_report_path(id: report)
json.wip report.wip?
