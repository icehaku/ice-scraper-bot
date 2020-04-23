json.free_games @games do |game|
  json.name game[0]
  json.image game[1]
  json.link game[2]
  json.date_from game[3]
  json.date_to game[4]
end
