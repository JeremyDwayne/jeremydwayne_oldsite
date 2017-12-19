class PagesController < ApplicationController
  before_action :load_resume, only: [:resume]

  def home
  end

  # Only load variables here that are used on every single page load. IE. Custom Letter is used in the footer for contact info.
  def load_resume
    if ( $cache_time.nil?  || File.mtime("#{Rails.root}/files/resume.yml") < $cache_time || [$resume].any?(&:nil?) )
      $cache_time = Time.now
      $resume = YAML.load(File.read('files/resume.yml'))
    end
    @resume = $resume
  end

  def resume
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Jeremy_Winterberg_Resume",
            layout: "pdf",
            show_as_html: params.key?('debug')
      end

    end
  end

end
