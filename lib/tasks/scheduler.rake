namespace :scheduler do
  desc "Remind user and send notification every one hour for item which rent time to users"
  task :reminder_one_hour => :environment do
    checkout_items = CheckoutItem.reminder_one_hour
  end

  desc "Remind user and send notification every four hours to users based on rent duration"
  task :reminder_four_hours => :environment do
    checkout_items = CheckoutItem.reminder_four_hours
  end 

  desc "Remind user and send notification every one day to users based on rent duration"
  task :reminder_one_day => :environment do
    checkout_items = CheckoutItem.reminder_one_day
  end 

  desc "Remind user and send notification every one week to users based on rent duration"
  task :reminder_one_week => :environment do
    checkout_items = CheckoutItem.reminder_one_week
  end 

  desc "Remind user and send notification every one week to users based on rent duration"
  task :repost_reminder => :environment do
    checkout_items = Product.repost_reminder
  end  
end
