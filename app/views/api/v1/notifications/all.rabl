node(:error){ @error }
node(:errors){ @errors }
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
  node(:status){ 200 }
end