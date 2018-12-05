# == Schema Information
#
# Table name: messages
#
#  id                         :integer          not null, primary key
#  topic                      :string
#  body                       :text
#  received_messageable_id    :integer
#  received_messageable_type  :string
#  sent_messageable_id        :integer
#  sent_messageable_type      :string
#  opened                     :boolean          default("false")
#  recipient_delete           :boolean          default("false")
#  sender_delete              :boolean          default("false")
#  created_at                 :datetime
#  updated_at                 :datetime
#  ancestry                   :string
#  recipient_permanent_delete :boolean          default("false")
#  sender_permanent_delete    :boolean          default("false")
#  documentable_id            :integer
#  documentable_type          :string
#

class CustomMessage < ActsAsMessageable::Message
  def self.get_conversation_by_receiver(user_id, receiver_id)
    self.where('(messages.sent_messageable_id = ? AND messages.received_messageable_id = ?) 
      OR (messages.sent_messageable_id = ? AND messages.received_messageable_id = ?)', user_id, receiver_id, receiver_id, user_id)
      .last
  end
end
