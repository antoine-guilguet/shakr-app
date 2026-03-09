class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, presence: true
  validates :username, presence: true, uniqueness: { case_sensitive: false }

  before_validation :sync_password_confirmation, if: :will_save_change_to_encrypted_password?

  private

  def sync_password_confirmation
    self.password_confirmation ||= password
  end
end
