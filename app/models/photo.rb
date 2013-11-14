# coding: utf-8

class Photo

  def initialize(file)
    @file = file
  end

  def binary
    @file.read
  end

  def image(size)
    image = MiniMagick::Image.read(binary)
    image.resize "#{size}x#{size}>"
    image.to_blob
  end

  def exif
    @exif = EXIFR::JPEG.new(@file) unless @exif
    @exif
  end

  def xmp
    @xmp = XMP.parse(exif) unless @xmp
    @xmp
  end

  def meta
    unless @meta_hash
      @meta_hash = exif.to_hash
      xmp.namespaces.each do |namespace_name|
        namespace = xmp.send(namespace_name)
        namespace.attributes.each do |attr|
          @meta_hash["#{namespace_name}_#{attr.underscore}".to_sym] = namespace.send(attr) rescue nil
        end
      end
    end
    @meta_hash
  end

  def camma(num)
    num.to_s.reverse.gsub( /(\d{3})(?=\d)/, '\1,').reverse
  end

  def meta_value(key)
    pretty_meta[key][1] rescue nil
  end

  def pretty_meta
    unless @pretty_meta
      @pretty_meta = {}
      meta.each do |k, v|
        caption = (ExifTrans.fields[k.to_s] or k)
        begin
          value = case k
          when :width, :height, :image_width, :image_length, :pixel_x_dimension, :pixel_y_dimension
            "#{camma(v)} px"
          when :bits
            "#{v} bits"
          when :x_resolution, :y_resolution, :focal_plane_x_resolution, :focal_plane_y_resolution
            "#{camma(v.to_i)} dpi"
          when :exposure_time
            "#{v} \""
          when :f_number, :max_aperture_value, :aperture_value
            "f / #{v.to_f}"
          when :iso_speed_ratings
            "ISO #{v}"
          when :exposure_bias_value
            (v.to_f > 0 ? '+' : '') + "#{v.to_f.round(1)} EV"
          when :focal_length, :focal_length_in_35mm_film
            "#{v.to_i} mm"
          when :shutter_speed_value
            "#{v} sec"
          else
            ExifTrans.values[k.to_s][v.to_i] or v
          end
        rescue
          value = v
        end
        if value.is_a?(Array)
          value = value.join(', ')
        elsif value.is_a?(Fixnum)
          value = camma(value)
        elsif value.is_a?(Time)
          value = value.strftime('%Y/%-m/%-d %H:%M:%S')
        end
        @pretty_meta[k] = [caption, value.to_s.force_encoding('utf-8') ]
      end
    end
    @pretty_meta
  end

  def url
    @file.base_uri
  end

  def grouped_exif
    exif1 = {}
    exif2 = pretty_meta
    ExifTrans.major_fields.each do |key|
      exif1[key.to_sym] = exif2.delete(key.to_sym)
    end
    [exif1, exif2]
  end

end
