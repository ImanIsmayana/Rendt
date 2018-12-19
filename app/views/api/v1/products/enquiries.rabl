node(:error){ @error }
node(:errors){ @errors }
child @message_parents => :messages do
  attribute :id

  child :sent_messageable => :sender do
    attributes :id

    node :full_name do |sender|
      sender.full_name
    end
  end

  node :last_message do |message|
    message.conversation.first.body
  end

  node :created_at do |message|
    message.conversation.first.created_at.strftime("%B %d, %Y")
  end

  node :created_time_at do |message|
    message.conversation.first.created_at.strftime("%H:%M:%S")
  end

  child :documentable => :product do
    attributes :id
    node(:name){|p| p.name}
  end
  node(:status){ 200 }
end