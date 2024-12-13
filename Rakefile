require 'net/http'

BASE_URL = 'https://adventofcode.com/2024'
SESSION = ENV['AOC_SESSION']

namespace :run do
  desc 'Test against example input'
  task :example, [:day, :part] do |t, args|
    day = args[:day]
    part = args[:part]
    puts `ruby solutions/day#{day}/part#{part}.rb spec/fixtures/day#{day}/part#{part}/example.input`
  end

  desc 'Test against actual input'
  task :actual, [:day, :part] do |t, args|
    day = args[:day]
    part = args[:part]
    puts `ruby solutions/day#{day}/part#{part}.rb spec/fixtures/day#{day}/part#{part}/actual.input`
  end
end

namespace :inputs do
  desc 'Download all inputs'
  task :download do
    day = Time.now.strftime('%Y-%m') == '2024-12' ? Time.now.day : 25
    effective_day = [day, 25].min

    (1..effective_day).each do |day|
      (1..2).each do |part|
        download_input(day, part)
      end
    end
  end
end

def download_input(day, part)
  if File.exist?("spec/fixtures/day#{day}/part#{part}/actual.input")
    puts "Day #{day} part #{part} already exists"
    return
  end

  uri = URI("#{BASE_URL}/day/#{day}/input")
  puts "Downloading day #{day} part #{part} input from #{uri}"

  req = Net::HTTP::Get.new(uri)
  req['Cookie'] = "session=#{SESSION}"
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end

  if response.is_a?(Net::HTTPSuccess)
    FileUtils.mkdir_p("spec/fixtures/day#{day}/part#{part}")
    File.write("spec/fixtures/day#{day}/part#{part}/actual.input", response.body)
    puts "Downloaded day #{day} part #{part}"
  else
    puts "Failed to download day #{day} part #{part}"
  end
end
