json.free_games @games do |game|
  json.image game[0]
  json.name game[1]
  json.link game[2]
end
