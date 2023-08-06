require 'json'
require 'sinatra'

# Sample data (You would typically fetch data from a database)
$users = [
  {
    id: 1,
    username: 'user1',
    email: 'user1@example.com',
    password: 'password1',
    posts: [
      { id: 1, title: 'Post 1', topic: 'Technology', likes: 10, comments: 5, views: 100 },
      # Add more user's posts here
    ]
  },
  {
    id: 2,
    username: 'user2',
    email: 'user2@example.com',
    password: 'password2',
    posts: [
      { id: 2, title: 'Post 2', topic: 'Science', likes: 15, comments: 3, views: 200 },
      # Add more user's posts here
    ]
  },
  # Add more users here
]

# Method to find a user by email
def find_user_by_email(email)
  $users.find { |user| user[:email] == email }
end

# Method to find a user by username
def find_user_by_username(username)
  $users.find { |user| user[:username] == username }
end

# Method to create a new user
def create_user(params)
  new_user = {
    id: $users.length + 1,
    username: params[:username],
    email: params[:email],
    password: params[:password],
    posts: []
  }
  $users << new_user
  new_user
end

# Sinatra routes

# User Registration
post '/users' do
  content_type :json

  user_params = JSON.parse(request.body.read, symbolize_names: true)
  existing_user = find_user_by_email(user_params[:email])
  halt 409, 'User already exists' if existing_user

  new_user = create_user(user_params)
  new_user.to_json
end

# User Login
post '/login' do
  content_type :json

  login_params = JSON.parse(request.body.read, symbolize_names: true)
  user = find_user_by_email(login_params[:email])
  halt 401, 'Invalid credentials' unless user && user[:password] == login_params[:password]

  user.to_json
end

# Profile
get '/users/:id' do
  content_type :json

  user_id = params[:id].to_i
  user = $users.find { |u| u[:id] == user_id }
  halt 404, 'User not found' unless user

  user.to_json
end

# My Posts (with stats)
get '/users/:id/posts' do
  content_type :json

  user_id = params[:id].to_i
  user = $users.find { |u| u[:id] == user_id }
  halt 404, 'User not found' unless user

  user[:posts].to_json
end

# Follow other authors
post '/users/:id/follow' do
  content_type :json

  user_id = params[:id].to_i
  user = $users.find { |u| u[:id] == user_id }
  halt 404, 'User not found' unless user

  follow_params = JSON.parse(request.body.read, symbolize_names: true)
  author_to_follow = find_user_by_username(follow_params[:author])
  halt 404, 'Author not found' unless author_to_follow

  # Here you can implement the logic to add the author_to_follow to the user's following list
  # For this example, we'll just return a success message.
  { message: "You are now following #{author_to_follow[:username]}" }.to_json
end

# Other Author's profile view
get '/authors/:id' do
  content_type :json

  author_id = params[:id].to_i
  author = $users.find { |u| u[:id] == author_id }
  halt 404, 'Author not found' unless author

  author.to_json
end

# Sample usage:
# POST /users - Create a new user (with request body as specified)
# POST /login - Login (with request body as specified)
# GET /users/:id - Get user's profile by ID
# GET /users/:id/posts - Get user's posts with stats
# POST /users/:id/follow - Follow another author (with request body as specified)
# GET /authors/:id - Get other author's profile by ID
