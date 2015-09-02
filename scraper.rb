require 'scraperwiki'
require 'open-uri'
require 'nokogiri'
require 'pry'

doc = Nokogiri::HTML.parse(open("http://www.partifinansiering.no/a/vkb2015/index.html").read)

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
        :party        => party,
        :organization => organization,
        :type         => type.split("/").first,
        :name         => name,
        :address      => address,
        :amount       => Integer(amount.gsub(" ", ""))
      }

      ScraperWiki.save_sqlite [:party, :organization, :name], data, 'vkb2015'
    end
  end  
end

#