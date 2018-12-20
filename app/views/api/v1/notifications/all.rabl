if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 200 }

  child @notifications, object_root: false do
    attributes :id, :owner_id, :owner_type, :recipient_id, :recipient_type,
      :aasm_state, :parameters, :created_at, :trackable

    node do |activity|
      if activity.trackable
        { trackable: true }
      else
        { trackable: false }
      end
    end
  end
end