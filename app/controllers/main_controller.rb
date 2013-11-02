# coding: utf-8

class MainController < ApplicationController

  def index
    if params[:url] =~ /^https?:\/\//
      render :index
    else
      render :top
    end
  end

  def content
    if params[:url] =~ /^https?:\/\//
      if params[:url] =~ /^#{Regexp.escape(root_url)}/
        raise
      end
      @photos = Page.new(params[:url]).photos
    end
    render layout: nil
  end

  def image
    photo = Page.new(params[:url]).photos.first
    size = params[:size] ? params[:size] : 800
    send_data photo.image(size), type: 'image/jpeg', disposition: 'inline'
  end

end
