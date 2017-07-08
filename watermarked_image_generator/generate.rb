require 'rmagick'

# NOTE: ウォーターマーク付きの画像を生成するツール
# $ bundle exec ruby ./generate.rb
class WatermarkedImageGenerator
  INPUT_PATH = "./input/*.jpeg"

  EYECATCH_PATH = "./eyecatch/"
  EYECATCH_WIDTH = 750
  EYECATCH_HEIGHT = 464

  NORMAL_PATH = "./normal/"
  NORMAL_WIDTH = 650
  NORMAL_HEIGHT = 402

  WATERMARK_PATH = "./watermark.png"
  WATERMARK_OFFSET_X = 0
  WATERMARK_OFFSET_Y = 5
  
  def initialize
    #exit unless check_arg
    @watermark = Magick::ImageList.new(exec_path(WATERMARK_PATH))
  end

  def put_wartermark_with_resize(image, mode)
    width = mode == 'normal' ? NORMAL_WIDTH : EYECATCH_WIDTH
    height = mode == 'normal' ? NORMAL_HEIGHT : EYECATCH_HEIGHT
    output_path = exec_path(mode == 'normal' ? NORMAL_PATH : EYECATCH_PATH)

    output_image = image.resize_to_fill(width, height)
    output_image.composite!(
      @watermark,
      Magick::SouthEastGravity,
      WATERMARK_OFFSET_X,
      WATERMARK_OFFSET_Y,
      Magick::HardLightCompositeOp
    )
    output_image.write("#{output_path}#{filename(image.filename)}")
    output_image.destroy!
  end

  def generate
    Dir.glob(exec_path(INPUT_PATH)) { |path|
      p "#{filename(image.filename)}"
      image = Magick::ImageList.new(path)
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

  def check_arg
    ret = true
    begin
      unless ARGV[0]
        puts "Usage: ./generate.rb"
        ret = false
      end
      @mode = ARGV[0]
      return ret
    rescue => e
      raise
    end
  end
end

exit unless __FILE__ == $0
p "generating..."
WatermarkedImageGenerator.new.generate
