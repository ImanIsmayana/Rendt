module PublicActivity
  class Activity < inherit_orm("Activity")
    #
    # aasm configuration
    #
    include AASM
    aasm do
      state :unread, :initial => true
      state :read

      event :mark_as_read do
        transitions :from => :read, :to => :unread
      end

      event :open do
        transitions :form => :unread, :to => :read
      end
    end

    #
    # create notificatin to public activity
    #
    def create_notification(**args)
      if args[:recipient].mobile_platform
        activity = args[:owner].create_activity(
          key: args[:key],
          owner: args[:owner],
          recipient: args[:recipient],
          parameters: {
            notification_type: args[:notification_type],
            title_message: args[:title_message],
            body_message: args[:body_message],
            another_parameters: args[:another_parameters]
          }
        )
        
        resource = args[:parameters][:another_parameters] if args[:parameters]

        activity.send_notification_to_mobile(
          args[:title_message],
          args[:body_message],
          args[:recipient].mobile_platform
          # args[:product_id]
        )
      else
        { error: 1, object: 'Mobile Platform' }
      end
    end

    #
    # send notif to mobile
    #
    def send_notification_to_mobile(title, body, platform, resource = nil)
      # can be an string or an array of strings containing the regIds of the devices you want to send
      device_id = platform.device_id 
      
      if platform.device_model.eql? 'android'
        GCM.key = ENV['API_KEY']

        # must be an hash with all values you want inside you notification
        data = { 
          title: title,
          message: body,
          resource: resource
        }
          # actions: [
          #   { "icon": "emailGuests", "title": "EMAIL GUESTS", "callback": "app.emailGuests", "foreground": true}
          # ]

        # Notification with custom information
        @response = GCM.send_notification(device_id, data)
      elsif platform.device_model.eql? 'ios'
        # this is the file you just created
        APNS.pass = '' 

        # Just in case your pem need a password
        APNS.pass = '' 

        n1 = APNS::Notification.new(device_id, title)
        n2 = APNS::Notification.new(device_id, :alert => title, :badge => 1, :sound => 'default')

        @response = APNS.send_notification([n1, n2])
        # @response = APNS.send_notification(device_id, :alert => title, :badge => 1, :sound => 'default')
      end

      logger.info @response
      @response.first
    end

    def self.get_notifications(recipient_id)
      self.order("created_at desc").where(recipient_id: recipient_id)
    end

    def self.update_state_to_read(recipient_id, current_state, new_state)
      activities = self.where(recipient_id: recipient_id, aasm_state: current_state)

      activities.update_all(aasm_state: new_state) if activities.exists?
    end

  end
end