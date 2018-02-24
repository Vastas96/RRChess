json.extract! user, :id, :nick_name, :rating, :state, :created_at, :updated_at
json.url user_url(user, format: :json)
