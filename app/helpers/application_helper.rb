module ApplicationHelper
  def active_class(link_path) current_page?(link_path) ? "active" : ""
  end

  def user_is_admin?
    current_user.admin
  end
end
