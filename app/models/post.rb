class Post < ApplicationRecord
  include DynamicSearch

  extend FriendlyId
  friendly_id :title, use: :slugged

  def normalize_friendly_id(string)
    super[0..139]
  end

  def to_param
    slug
  end

end
