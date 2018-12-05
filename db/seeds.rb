#
# seeds for admin
#
AdminUser.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('admin_users')

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

#
# seeds for categories
#
Category.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('categories')

categories = []

["Electronic", "Wooden", "Hand Held"].each_with_index do |category, index|
  categories << {id: index + 1, name: category}
end

Category.create(categories)

SystemSetting.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('system_settings')

SystemSetting.create(name: 'Rendt Server', email_sender: 'info@rendt.com',
  listing_per_page: 10, maintenance_mode: false, maintenance_message: 'The website is under maintenance')

Page.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('pages')

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