# coding: utf-8

require 'open-uri'

class Page

  def initialize(url)
    @url = url
  end

  def open_url(url)
    open(url, 'Referer' => url)
  end

  def photos
    @file = open_url(@url)
    referer = @url
    if @file.content_type == 'image/jpeg'
      return [Photo.new(@file)]
    elsif @file.content_type == 'text/html'
      return find_jpegs.map {|url|
        Rails.logger.info 'JPEG URL: ' + url
        begin
          file = open_url(url)
          file.content_type == 'image/jpeg' ? Photo.new(file) : nil
         rescue
          Rails.logger.error $!
          nil
        end
      }.compact
    else
      return []
    end
  end

  def find_jpegs
    content = @file.read
    urls = []
    tmp = content.gsub(/<a .*?href=\"(.*?)\".*?>.*?<\/a>/im) {|m|
      url = $1
      if url =~ /\.(jpg|jpeg)(\?.*|)/i
        urls << url.gsub(' ', '%20')
        nil
      else
        m
      end
    }
    tmp.gsub(/<img .*?src=\"(.*?)\".*?>/im) {
      url = $1
      if url =~ /\.(jpg|jpeg)(\?.*|)/i
        urls << url.gsub(' ', '%20')
      end
    }
    urls.uniq.map do |url|
      (URI.parse(@url) + url).to_s
    end
  end

end
