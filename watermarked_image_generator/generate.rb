require 'rmagick'

# NOTE: ウォーターマーク付きの画像を生成するツール
# $ bundle exec ruby ./generate.rb
class WatermarkedImageGenerator
  INPUT_PATH = "./input/*.{jpg,png}"

  EYECATCH_PATH = "./eyecatch/"
  EYECATCH_WIDTH = 750
  EYECATCH_HEIGHT = 464
  EYECATCH_VERTICAL_WIDTH = 464
  EYECATCH_VERTICAL_HEIGHT = 750

  NORMAL_PATH = "./normal/"
  NORMAL_WIDTH = 650
  NORMAL_HEIGHT = 402
  NORMAL_VERTICAL_WIDTH = 402
  NORMAL_VERTICAL_HEIGHT = 650

  WATERMARK_PATH = "./watermark.png"
  WATERMARK_OFFSET_X = 0
  WATERMARK_OFFSET_Y = 5
  
  def initialize
    @watermark = Magick::ImageList.new(exec_path(WATERMARK_PATH))
    @need_watermark = true
    exit unless check_arg
  end

  def put_wartermark_with_resize(image, mode)
    width = width(image, mode)
    height = hight(image, mode)
    output_path = exec_path(mode == 'normal' ? NORMAL_PATH : EYECATCH_PATH)

    output_image = image.resize_to_fill(width, height)
    output_image.composite!(
      @watermark,
      Magick::SouthEastGravity,
      WATERMARK_OFFSET_X,
      WATERMARK_OFFSET_Y,
      Magick::OverCompositeOp
      #Magick::HardLightCompositeOp
    ) if @need_watermark
    output_image.write("#{output_path}#{filename(image.filename)}")
    output_image.destroy!
  end

  def generate
    Dir.glob(exec_path(INPUT_PATH)) { |path|
      image = Magick::ImageList.new(path)
      p "#{filename(image.filename)}"
      put_wartermark_with_resize(image, 'normal')
      put_wartermark_with_resize(image, 'eyecatch')
      image.destroy!
    }
  end

  def exec_path(name)
    return File.dirname(__FILE__) + "/" + name
  end
  
  def filename(path)
    return File.basename(path)
  end

  def width(image, mode)
    return is_vertical(image) \
      ? mode == 'normal' ? NORMAL_VERTICAL_WIDTH : EYECATCH_VERTICAL_WIDTH
      : mode == 'normal' ? NORMAL_WIDTH : EYECATCH_WIDTH
  end
  
  def hight(image, mode)
    return is_vertical(image) \
      ? mode == 'normal' ? NORMAL_VERTICAL_HEIGHT : EYECATCH_VERTICAL_HEIGHT
      : mode == 'normal' ? NORMAL_HEIGHT : EYECATCH_HEIGHT
  end

  def is_vertical(image)
    return image.columns < image.rows
  end

  def check_arg
    ret = true
    begin
      #unless ARGV[0]
      #  puts "Usage: ./generate.rb"
      #  ret = false
      #end
      unless ARGV[0].nil?
        @need_watermark = ARGV[0].to_i == 1 ? true : false
      end
      return ret
    rescue => e
      raise
    end
  end
end

exit unless __FILE__ == $0
p "generating..."
WatermarkedImageGenerator.new.generate
