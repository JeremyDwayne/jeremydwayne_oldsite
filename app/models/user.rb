class User < ApplicationRecord
  enum role: [:user, :moderator, :admin]
  after_initialize :set_default_role, if: :new_record?

  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  private
    def set_default_role
      self.role ||= :user
    end
end
