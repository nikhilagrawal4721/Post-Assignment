require 'json'
require 'sinatra'

$posts = [
  {
    id: 1,
    title: 'Post 1',
    topic: 'Technology',
    featured_image: 'https://example.com/image1.jpg',
    text: 'This is the content of Post 1.',
    published_at: '2023-08-05 12:00:00',
    author: 'John Doe',
    likes: 10,
    comments: 5
  },
  {
    id: 2,
    title: 'Post 2',
    topic: 'Science',
    featured_image: 'https://example.com/image2.jpg',
    text: 'This is the content of Post 2.',
    published_at: '2023-08-06 10:30:00',
    author: 'Jane Smith',
    likes: 15,
    comments: 3
  },
]

# Method to retrieve posts based on filters, sorting, and search
def get_posts(params)
  filtered_posts = $posts

  # Filter by author if provided
  if params[:author]
    author_name = params[:author]
    filtered_posts = filtered_posts.select { |post| post[:author] == author_name }
  end

  # Filter by date if provided
  if params[:date]
    date = params[:date]
    filtered_posts = filtered_posts.select { |post| post[:published_at].to_date == date.to_date }
  end

  # Sort by likes or comments if provided
  if params[:sort_by]
    sort_key = params[:sort_by].to_sym
    filtered_posts = filtered_posts.sort_by { |post| post[sort_key] }
  end

  # Search posts, author, or topic if provided
  if params[:search]
    search_query = params[:search].downcase
    filtered_posts = filtered_posts.select do |post|
      post.values.any? { |value| value.to_s.downcase.include?(search_query) }
    end
  end

  filtered_posts
end

# Sinatra routes
get '/posts' do
  content_type :json
  filtered_posts = get_posts(params)
  filtered_posts.to_json
end


# Method to find a post by ID
def find_post_by_id(post_id)
    $posts.find { |post| post[:id] == post_id }
  end


  # Method to add a new post
def add_post(params)
    new_post = {
      id: $posts.length + 1,
      title: params[:title],
      topic: params[:topic],
      featured_image: params[:featured_image],
      text: params[:text],
      published_at: params[:published_at],
      author_id: params[:author_id]
    }
    $posts << new_post
    new_post
  end


  
# Method to edit a post
def edit_post(post_id, params)
    post = find_post_by_id(post_id)
    return nil unless post
  
    post[:title] = params[:title] if params[:title]
    post[:topic] = params[:topic] if params[:topic]
    post[:featured_image] = params[:featured_image] if params[:featured_image]
    post[:text] = params[:text] if params[:text]
    post[:published_at] = params[:published_at] if params[:published_at]
    post
  end


  # Method to delete a post
def delete_post(post_id)
    $posts.reject! { |post| post[:id] == post_id }
  end


  # Add new post
post '/posts' do
    content_type :json
  
    post_params = JSON.parse(request.body.read, symbolize_names: true)
    new_post = add_post(post_params)
    new_post.to_json
  end


  
# Edit post
put '/posts/:id' do
    content_type :json
  
    post_id = params[:id].to_i
    post = edit_post(post_id, JSON.parse(request.body.read, symbolize_names: true))
    halt 404, 'Post not found' unless post
  
    post.to_json
  end
  
  # Delete post
  delete '/posts/:id' do
    post_id = params[:id].to_i
    delete_post(post_id)
    halt 204
  end


  # Sample usage:
# POST /posts - Add a new post (with request body as specified)
# PUT /posts/:id - Edit an existing post (with request body as specified)
# DELETE /posts/:id - Delete an existing post

# Sample usage:
# GET /posts - Returns all posts
# GET /posts?author=John Doe - Returns posts by author "John Doe"
# GET /posts?date=2023-08-05 - Returns posts published on "2023-08-05"
# GET /posts?sort_by=likes - Returns posts sorted by likes
# GET /posts?search=Technology - Returns posts containing "Technology" in any field
