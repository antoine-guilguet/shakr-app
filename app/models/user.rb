class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, presence: true

  before_validation :sync_password_confirmation, if: :will_save_change_to_encrypted_password?

  private

  def sync_password_confirmation
    self.password_confirmation ||= password
  end
end
