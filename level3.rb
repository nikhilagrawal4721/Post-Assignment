require 'json'
require 'sinatra'

# Sample data (You would typically fetch data from a database)
$posts = [
  # Previous posts remain unchanged
]

# Method to find a post by ID
def find_post_by_id(post_id)
  $posts.find { |post| post[:id] == post_id }
end

# Method to find posts by author
def find_posts_by_author(author)
  $posts.select { |post| post[:author] == author }
end

# Method to find posts by topic
def find_posts_by_topic(topic)
  $posts.select { |post| post[:topic] == topic }
end

# Method to sort posts by a specific attribute (e.g., likes, comments, views)
def sort_posts_by_attribute(posts, attribute)
  posts.sort_by { |post| post[attribute] }.reverse
end

# Sinatra routes

# Top posts (based on the number of likes within a specific timeframe)
get '/posts/top' do
  content_type :json

  # Sample implementation: Top posts are sorted by likes in descending order
  top_posts = sort_posts_by_attribute($posts, :likes)
  top_posts.to_json
end

# Recommended posts (you can define your own recommendation logic here)
get '/posts/recommended' do
  content_type :json

  # Sample implementation: Recommended posts are sorted by views in descending order
  recommended_posts = sort_posts_by_attribute($posts, :views)
  recommended_posts.to_json
end

# More posts by a similar author
get '/authors/:id/posts' do
  content_type :json

  author_id = params[:id].to_i
  author_posts = find_posts_by_author(author_id)
  halt 404, 'Author not found' if author_posts.empty?

  author_posts.to_json
end

# Topic List page
get '/topics' do
  content_type :json

  # Sample implementation: Extract unique topics from posts
  topics = $posts.map { |post| post[:topic] }.uniq
  topics.to_json
end

# Sample usage:
# GET /posts/top - Get top posts
# GET /posts/recommended - Get recommended posts
# GET /authors/:id/posts - Get more posts by a similar author
# GET /topics - Get a list of available topics
