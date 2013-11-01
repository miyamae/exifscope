# coding: utf-8

class ApplicationController < ActionController::Base

  PRODUCT_NAME = 'ExifScope'

  protect_from_forgery with: :exception

  before_filter :default_header

  def default_header
    headers['Cache-Control'] = 'no-cache'
    headers['P3P'] = "CP='UNI CUR OUR'"
  end

end
