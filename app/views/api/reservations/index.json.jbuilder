json.array! @reservations do |reservation|
  json.partial! "api/reservations/reservation", reservation: reservation  
end
