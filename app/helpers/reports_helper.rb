module ReportsHelper
  def sliced(description, word)
    description.gsub!(/(\r\n|\r|\n)/, " ")
    description.slice(/#{word}.{0,300}/)
  end
end
