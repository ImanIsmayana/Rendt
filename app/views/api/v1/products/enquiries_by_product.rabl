if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 200 }

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
      message.created_at.strftime("%H:%M:%S")
    end
  end
  node(:product_name){@product.name} if @product
end