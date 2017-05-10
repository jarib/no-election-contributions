require 'scraperwiki'
require 'nokogiri'
require 'pry'
require 'fileutils'

FileUtils.rm_rf 'data.sqlite'

def scrape(id, url)
  doc = Nokogiri::HTML.parse(ScraperWiki.scrape(url))

  party = nil
  organization = nil

  doc.css('h2, h4, table').each do |node|
    case node.name
    when 'h2'
      party = node.text.split("/").first
    when 'h4'
      organization = node.text.split("/").first
    when 'table'
      rows = node.css('tr')[1..-1]

      rows.each do |row|
        type, name, address, amount = row.css('td').map(&:text)

        data = {
          :party               => party,
          :organization        => organization,
          :type                => id,
          :contributor_type    => type.split("/").first,
          :contributor_name    => name,
          :contributor_address => address,
          :contributor_amount  => Integer(amount.gsub(" ", ""))
        }

        # p data
        ScraperWiki.save_sqlite [:party, :organization, :type, :contributor_name], data
      end
    end
  end
end

scrape "vkb2015", "https://www.partifinansiering.no/a/vkb2015/index.html"
scrape "vkb2017", "https://www.partifinansiering.no/a/vkb2017/index.html"