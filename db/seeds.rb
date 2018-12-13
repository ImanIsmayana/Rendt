#
# seeds for admin
#
AdminUser.destroy_all
# ActiveRecord::Base.connection.reset_pk_sequence!('admin_users')

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
AdminUser.create!(email: 'joe@example.com', password: 'admin123', password_confirmation: 'admin123')


#
# seeds for categories
#
Category.destroy_all
# ActiveRecord::Base.connection.reset_pk_sequence!('categories')

categories = []

["Electronic", "Wooden", "Hand Held"].each_with_index do |category, index|
  categories << {id: index + 1, name: category}
end

Category.create(categories)

SystemSetting.destroy_all
# ActiveRecord::Base.connection.reset_pk_sequence!('system_settings')

SystemSetting.create(name: 'Rendt Server', email_sender: 'info@rendt.com',
  listing_per_page: 10, maintenance_mode: false, maintenance_message: 'The website is under maintenance')

Page.destroy_all
# ActiveRecord::Base.connection.reset_pk_sequence!('pages')

Page.create(heading: 'Sample Content', url: 'about-us', meta_title: 'Sample Content',
  meta_description: 'This is description for Sample Content page',
  short_intro: 'This is sample short intro for Sample Content page',
  content: '<p align="justify">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
    tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
    quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
    consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
    cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
    proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>',
  menu_title: 'Sample Content', menu_position: 'top', menu_sort_order: 1, active: true);

1.upto(5) do |n|
  Page.create(heading: "Sample Content #{n}", url: 'about-us', meta_title: "Sample Content #{n}",
    meta_description: 'This is description for Sample Content page',
    short_intro: 'This is sample short intro for Sample Content page',
    content: '<p align="justify">Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
      tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
      quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
      consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
      cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
      proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p>',
    menu_title: "Sample Content #{n}", menu_position: 'top', menu_sort_order: 1, active: true);
 end

User.create!(email: 'mino@example.com', password: 'mino123456', password_confirmation: 'mino123456', first_name: "mino", last_name: "taur", address: "new york", latitude: "40.712776", longitude: "-74.005974", phone_number: "02179187686")
User.create!(email: 'jhon@example.com', password: 'jhon123456', password_confirmation: 'jhon123456', first_name: "jhon", last_name: "son", address: "new york", latitude: "40.712776", longitude: "-74.005974", phone_number: "02179187686")

Home.create!(title: 'Example', app_description: 'Lorem ipsum dolor sit amet',
  google_play_url: "https://play.google.com/store/apps/details?id=com.whatsapp.w4b&hl=en",
  features_one_title: 'foto', features_one_description: 'to take foto',
  features_two_title: 'video', features_two_description: 'to play video',
  features_three_title: 'film', features_three_description: 'to show film',
  features_four_title: 'document', features_four_description: 'to read doc',
  application_information_title: 'example',
  application_information_description: 'lorem ipsum dolor sit amet');