json.footprints do
  json.array! @footprints do |footprint|
    json.partial! "api/footprints/footprint", footprint: footprint
  end
end

json.footprint_total_count @footprint_total_count