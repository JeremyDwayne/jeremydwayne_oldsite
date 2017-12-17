class PagesController < ApplicationController

  def home
  end

  def resume
    @resume = YAML.load(File.read('resume.yml'))
  end

end
