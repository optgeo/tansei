require 'digest/md5'
require 'fileutils'
require 'json'
require 'tmpdir'
require './constants'

def task_dir
  Dir.mktmpdir('tansei', '/var/tmp') {|task|
    yield task
  }
end

def prepare_list
  return if File.exist?(LIST_NAME)
  system <<-EOS
curl -o #{LIST_NAME} #{LIST_URL}
  EOS
end

def file_id 
  list = File.open(LIST_NAME).read.split("\r\n").shuffle
  list.each {|id|
    next if `mc ls #{OBST}/tansei/#{id}.copc.laz` != ''  
    yield id
  }
end

def download(task, id)
  url = "https://gic-shizuoka.s3.ap-northeast-1.amazonaws.com/" + 
    "2022/p/LP/LAS/#{id}.zip"
  system <<-EOS
curl -o #{task}/#{id}.zip #{url}
  EOS
  good = File.size("#{task}/#{id}.zip") > 300
  if good
    system <<-EOS
unzip -d #{task} #{task}/#{id}.zip
    EOS
  end
  system <<-EOS
rm #{task}/#{id}.zip
  EOS
  return good
end

def copc(task, id)
  pipeline = [
    "#{task}/#{id}.las",
    {
      :type => 'filters.reprojection',
      :in_srs => 'EPSG:6676',
      :out_srs => 'EPSG:3857'
    },
    {
      :type => 'writers.copc',
      :filename => "#{task}/#{id}.copc.laz"
    }
  ]
  system <<-EOS
echo '#{JSON.dump(pipeline)}' | pdal pipeline -s
  EOS
end

def move(task, id)
  system <<-EOS
mc mv #{task}/#{id}.copc.laz #{OBST}/tansei/#{id}.copc.laz
  EOS
  print "\n"
end

def open_geojsons(task) 
  filename = Digest::MD5.hexdigest(task)
  File.open("geojsons/#{filename}.geojsons", "w") {|w|
    yield w
  }
end

def extent(task, id, geojsons)
  boundary = JSON.parse(`pdal info --boundary #{task}/#{id}.copc.laz`)
  f = {
    :type => 'Feature',
    :geometry => boundary['boundary']['boundary_json'],
    :properties => {
      :id => id
    }
  }
  geojsons.print "\x1e#{JSON.dump(f)}\n"
  geojsons.flush
end

# main
prepare_list
task_dir do |task|
  file_id do |id|
    open_geojsons(task) do |geojsons|
      $stderr.print "[#{task}] #{id}\n"
      next if !download(task, id)
      copc(task, id)
      extent(task, id, geojsons)
      move(task, id)
    end
  end
end
