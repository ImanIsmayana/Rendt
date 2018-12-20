if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 200 }
end
child @message do
  attribute :id, :body

  child :sent_messageable => :sender do
    attributes :id

    node :full_name do |sender|
      sender.full_name
    end
  end

  child :received_messageable => :receiver do
    attributes :id

    node :full_name do |receiver|
      receiver.full_name
    end
  end

  node :created_at do |message|
    message.conversation.first.created_at.strftime("%B %d, %Y")
  end

  node :created_time_at do |message|
    message.created_at.strftime("%H:%M:%S")
  end
end