class GrassArrangement
  def initialize(svg)
    @svg = svg
  end
  def arrange_wday_label
    count = 0
    wdays = ["日", "月", "火", "水", "木", "金", "土"]
    @svg.css("text.wday").map do |wday|
      wday[:style] = ""
      wday[:dy] = 12 + (15 * count)
      wday.children = wdays[count]
      count += 1
    end
  end
  def arrange_month_label
    months = { Jan: "1", Feb: "2", Mar: "3", Apr: "4",
              May: "5", Jun: "6", Jul: "7", Aug: "8",
              Sep: "9", Oct: "10", Nov: "11", Dec: "12" }
    @svg.css("text.month").map do |month|
      month.children = months[month.children.text.to_sym]
    end
  end
end
