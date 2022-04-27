require_relative 'tiktok_liked'
require 'bundler'
Bundler.require

@liked = liked

puts "Starting run with #{ @liked.length} video links"

@liked.each_with_index do |url, i|


  splat  = url.split("/")
  username = splat[-3].gsub("@", "")
  video_id = splat[-1]
  file_name = username + "_" + video_id

  if File.exist?("images/" + file_name + ".jpg")
    puts "Skipping existing #{ file_name }"
    next
  end

  puts "Getting video page #{ i + 1 } of #{ @liked.length }..."

  response = HTTParty.get(url)
  nokogiri_page = Nokogiri::HTML(response.body)
  img_tag = nokogiri_page.css('.tiktok-1itcwxg-ImgPoster')

  begin
    src = img_tag.first["src"]
  rescue NoMethodError
    puts "ERROR thank u next"
    puts "Sleep 1..."
    sleep 1
    next
  end

  puts "Downloading image for #{ file_name }..."

  File.open("images/" + file_name + ".jpg", "w") do |file|
    file.binmode
    HTTParty.get(src, stream_body: true, follow_redirects: true) do |fragment|
      file.write(fragment)
    end


  end

  puts "Downloaded! Waiting 1s to do more."
  sleep 1

end

puts "Done with #{ @liked.length} video links"
