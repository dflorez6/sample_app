# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Micropost < ActiveRecord::Base
  attr_accessible :content
  belongs_to :user                                              # A micropost belongs_to a user.

  validates :content, presence: true, length: { maximum: 140 }  # Validates content: not being blank & not being over 140 characters.
  validates :user_id, presence: true                            # A validation for the micropost’s user_id.

  default_scope order: 'microposts.created_at DESC'             #  Ordering the microposts with default_scope. DESC is SQL for “descending”, in descending order from newest to oldest.
end
