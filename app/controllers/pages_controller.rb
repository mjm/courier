class PagesController < ApplicationController
  before_action :ensure_logged_in

  def index; end

  def feeds; end

  private

  def ensure_logged_in
    redirect_to '/auth/twitter' unless session[:user]
  end
end
