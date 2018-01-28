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

  class CodeRayify < Redcarpet::Render::HTML
    def block_code(code, language)
      CodeRay.scan(code, language).div(line_numbers: :table, css: :class)
    end
  end

  def markdown(text)
    coderayified = CodeRayify.new(:filter_html => true, :hard_wrap => true)
    options = {
      :fenced_code_blocks => true,
      :no_intra_emphasis => true,
      :autolink => true,
      :strikethrough => true,
      :lax_html_blocks => true,
      :superscript => true
    }
    markdown_to_html = Redcarpet::Markdown.new(coderayified, options)
    postprocess(markdown_to_html.render(text)).html_safe
  end

  def postprocess(full_document)
    Regexp.new(/\A<p>(.*)<\/p>\Z/m).match(full_document)[1] rescue full_document
  end

  def link_if_admin(text, path, method="get", css="")
    if user_signed_in? && current_user.admin?
      link_to text, path, method: method, class: css
    end
  end

  def html_dash_replace(string)
    string.gsub("-", "%")
  end

end
