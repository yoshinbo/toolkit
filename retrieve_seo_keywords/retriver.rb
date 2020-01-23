require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'kconv'

class SeoKeywordsRetriever
  RELATED_KEYWORDS_URL_BASE = 'https://www.related-keywords.com/'
  SEARCH_URL_BASE = 'https://www.google.com/search?hl=jp&gl=JP&q='

  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3864.0 Safari/537.36'
  REFERER = 'https://www.google.com/'
  PAGE_AMOUNT = 1
  GOOGLE_GET_TITLE_XPATH = '//div[@class="r"]/a'

  FORMAT_TITLE = "\ttitle\t%s"
  FORMAT_URL = "\turl\t%s"
  FORMAT_ELEMENT = "\t\t%s"
  FORMAT_ELEMENT_TEXT = "\t\t\t%s"

  def initialize
    @keyword = URI.encode("#{ARGV[0]}")
  end

  def retrive
    exit unless @keyword
    fetch_urls_from_google
  end

  private
  def fetch_urls_from_google
    escaped_keyword = CGI.escapeHTML(@keyword)
    referer = REFERER

    PAGE_AMOUNT.times do |i|
      search_url = SEARCH_URL_BASE + escaped_keyword
      search_url += "&ei=123&start=#{i * 10}" unless i.zero?
      charset = nil

      html = open(search_url, { 'User-Agent' => USER_AGENT, 'Referer' => referer }) do |f|
        charset = f.charset
        f.read
      end
      doc = Nokogiri::HTML.parse(html, nil, charset)
      doc.xpath(GOOGLE_GET_TITLE_XPATH).each do |d|
        puts(FORMAT_TITLE % d.xpath('h3').text)
        fetch_indexes(d.attribute('href').to_s)
      end
      sleep(rand(5..10))
      referer = search_url
    end
  end

  def fetch_indexes(url)
    puts(FORMAT_URL % url)
    charset = nil
    html = open(url, { 'User-Agent' => USER_AGENT }) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    show_retrive_elements(doc, 'h1')
    show_retrive_elements(doc, 'h2')
    show_retrive_elements(doc, 'h3')
    puts '----------'
  end

  def show_retrive_elements(doc, element)
    puts(FORMAT_ELEMENT % element)
    doc.css(element).each do |e|
      puts(FORMAT_ELEMENT_TEXT % e.text)
    end
  end
end

exit unless __FILE__ == $0
p "retriving..."
SeoKeywordsRetriever.new.retrive
