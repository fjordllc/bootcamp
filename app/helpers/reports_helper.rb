module ReportsHelper

	def slice_description(report)
	  report.description.gsub!(/(\r\n|\r|\n)/, "")
	  remained_count = report.description.length - params[:word].length - report.description.index(params[:word])
	  report.description.slice(/#{params[:word]}.{#{remained_count}}/)
	end
end
