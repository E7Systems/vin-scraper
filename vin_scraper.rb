require 'bundler'
Bundler.require

class VinScraper
  ROOT_URL = 'https://www.instavin.com/vehicles'
  YEARS = 1953..2014
  INCLUDED_MAKES = {"acura" => true, "aston martin" => true, "audi" => true, "bentley" => true, "bmw" => true, "buick" => true, "cadillac" => true, "chevrolet" => true, "chrysler" => true, "daewoo" => true, "dodge" => true, "ford" => true, "gmc" => true, "infiniti" => true, "international" => true, "isuzu" => true, "jaguar" => true, "jeep" => true, "kia" => true, "lamborghini" => true, "land rover" => true, "lexus" => true, "lincoln" => true, "lotus" => true, "maserati" => true, "maybach" => true, "mazda" => true, "mercedes-benz" => true, "mercury" => true, "mini" => true, "mitsubishi" => true, "nissan" => true, "pontiac" => true, "porsche" => true, "rolls-royce" => true, "saab" => true, "saturn" => true, "scion" => true, "sterling" => true, "subaru" => true, "suzuki" => true, "toyota" => true, "triumph" => true, "volkswagen" => true, "volvo" => true}
  CONTAINER_CSS_PATH = 'div.mainframe h1.page-title+div table a'

  def initialize(debug=false)
    @debug = debug
    @db = Mysql2::Client.new(:host => 'localhost', :username => 'root', database: 'vin_data')
    @agent = Mechanize.new
  end

  def scrape
    YEARS.each do |year|
      @agent.get("#{ROOT_URL}/#{year}") do |makes_page|
        makes_page.search(CONTAINER_CSS_PATH).each do |make_anchor|

          first_make_child = make_anchor.children.first
          next if first_make_child.nil?
          make_name = first_make_child.text
          next if !INCLUDED_MAKES[make_name.downcase]

          @agent.get("#{ROOT_URL}/#{year}/#{make_name}") do |models_page|
            models_page.search(CONTAINER_CSS_PATH).each do |model_anchor|

              first_model_child = model_anchor.children.first
              next if first_model_child.nil?
              model_name = first_model_child.text

              puts "#{year} #{make_name} #{model_name}" if @debug

              @agent.get("#{ROOT_URL}/#{year}/#{make_name}/#{model_name}") do |vins_page|
                vins_page.search(CONTAINER_CSS_PATH).each do |vin_anchor|
                  vin_anchor_child = vin_anchor.children.first
                  next if vin_anchor_child.nil?

                  insert_vin_record year, make_name, model_name, vin_anchor_child.text
                end
              end

            end
          end
        end
      end
    end
  end

  private
  def insert_vin_record(year, make, model, vin)
    insert_query = <<-eos
      INSERT INTO vins
      (year, make, model, vin)
      VALUES
      (#{year.to_i}, '#{make.downcase}', '#{model.downcase}', '#{vin.downcase}')
    eos

    begin
      @db.query(insert_query)
    rescue => e
      puts e.message if @debug
    end
  end
end

VinScraper.new(true).scrape