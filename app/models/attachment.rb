# == Schema Information
#
# Table name: attachments
#
#  id              :integer          not null, primary key
#  name            :string
#  attachable_id   :integer
#  attachable_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Attachment < ActiveRecord::Base
  #
  # relations
  #
  belongs_to :attachable, polymorphic: true

  #
  # validations
  #
  validates :name, presence: true

  #
  # uploader configuration
  #
  mount_uploader :name, AttachmentUploader
end
