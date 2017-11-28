# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all
Post.destroy_all
Like.destroy_all
Comment.destroy_all
Friendship.destroy_all
FriendRequest.destroy_all

p "Creating users..."
User.create!(first_name: 'Jean-Claude',
             last_name: 'Van Damne',
             email: 'jeanclaude@vandamne.com',
             about: 'I now truly believe it is impossible for me to make a bad movie.',
             picture: File.open("app/assets/images/vandamne-picture.jpg"),
             cover: File.open("app/assets/images/vandamne-cover.jpg"),             
             password: 'kickboxer',
             password_confirmation: 'kickboxer')

User.create!(first_name: 'Chuck',
             last_name: 'Norris',
             email: 'chuck@norris.com',
             about: "I don't initiate violence, I retaliate.",
             picture: File.open("app/assets/images/chuck-picture.jpeg"),
             cover: File.open("app/assets/images/chuck-cover.jpg"), 
             password: 'deltaforce',
             password_confirmation: 'deltaforce')

15.times do |index|
  password = Faker::Internet.password
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  full_name = first_name + "." + last_name
  email = Faker::Internet.email(full_name)
  about = Faker::Lorem.sentence
  picture = Faker::LoremPixel.image("400x400")
  cover = Faker::LoremPixel.image("700x500")

  User.create!(first_name: first_name,
               last_name: last_name,
               email: email,
               about: about,
               remote_picture_url: picture,
               remote_cover_url: cover,
               password: password,
               password_confirmation: password)
end
p "Created #{User.count} users"

p "Creating posts..."
User.all.each do |user|
  10.times do
    post = user.posts.build(body: Faker::Lorem.paragraph(10),
                            created_at: Faker::Date.between(20.days.ago, Time.now))
    post.save!
  end
end
p "Posts created"

p "Creating comments..."
Post.all.each do |post|
  rand(0..7).times do
    comment = post.comments.build(user_id: User.pluck(:id).sample,
                                  body: Faker::Lorem.paragraph)
    comment.save!
  end
end
p "Comments created"

p "Creating friend requests..."
User.all.each do |user|
  num_requests = rand(0..10)
  all_friends_ids = User.where.not(id: user.id).pluck(:id)
  until user.pending_friends.count == num_requests
    new_friend = User.find(all_friends_ids.shuffle!.pop)
    unless user.pending_requests.find_by(user_id: new_friend.id)
      user.friend_requests.create(friend_id: new_friend.id)
    end
  end
end
p "Friend requests created"

p "Creating friendships..."
FriendRequest.all.each do |friend_request|
  confirm = [true, false].sample
  if confirm
    friend_request.accept
  end
end
p "Friendships created"

p "Creating post likes..."
Post.all.each do |post|
  all_user_ids = User.pluck(:id)
  (rand 0..10).times do
    like = post.likes.build(user_id: all_user_ids.shuffle!.pop)
    like.save!
  end
end
p "Post likes created"

p "Creating comment likes..."
Comment.all.each do |comment|
  all_user_ids = User.pluck(:id)
  (rand 0..10).times do
    like = comment.likes.build(user_id: all_user_ids.shuffle!.pop)
    like.save!
  end
end
p "Comment likes created"
