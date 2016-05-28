module ApplicationHelper
  def active_class(link_path) 
    if current_page? link_path
      "active"
    elsif request.fullpath.include? link_path
      if current_page? request.fullpath
        if link_path =~ /\/.+/
          "active"
        end
      end
    end
  end

  class HTMLwithPygments < Redcarpet::Render::HTML
    def block_code(code, language)
      Pygments.highlight(code, lexer: language)
    end
  end

  def markdown(content)
    renderer = HTMLwithPygments.new(hard_wrap: true, filter_html: true)
    options = {
      autolink: true,
      no_intra_emphasis: true,
      disable_indented_code_blocks: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true
    }

    Redcarpet::Markdown.new(renderer, options).render(content).html_safe
  end

  def link_if_admin(text, path)
    if user_signed_in? && current_user.admin?
        link_to text, path
    end
  end

end
