require './constants'
require 'json'
require 'tmpdir'

$n = 0

def task
  Dir.mktmpdir('update-extent', TMPDIR) {|dir|
    yield dir
  }
end

def files
  list = `mc ls #{OBST}/tansei`.split("\n").shuffle
  $n = list.size
  list.each {|l|
    yield l.split(' ')[-1]
  }
end

def write
  File.open(UPDATE_EXTENT_PATH, 'w') {|w|
    yield w
  }
end

# main
write do |w|
  task do |dir|
    ids = []
    count = 0
    files do |file|
      ids << File.basename(file, '.copc.laz')
    end 
    File.foreach(EXTENT_PATH) do |l|
      count += 1
      f = JSON.parse(l.sub("\x1e", ''))
      id = f['properties']['id']
      ids.delete(id)
      w.print l
      $stderr.print "[#{dir}] reused #{id} (#{count}/#{$n})\n"
    end
    ids.each do |id|
      count += 1
      $stderr.print "[#{dir}] calculate #{id} (#{count}/#{$n})\n"
      file = "#{id}.copc.laz"
      system <<-EOS
mc cp #{OBST}/tansei/#{file} #{dir}
      EOS
      $stderr.print "\n"
      g = JSON.parse(
        `pdal info #{dir}/#{file}`
      )['stats']['bbox']['EPSG:4326']['boundary']
      f = {
        :type => 'Feature',
        :geometry => g,
        :properties => {
          'id' => id
        }
      }
      w.print "\x1e#{JSON.dump(f)}\n"
      w.flush
      system <<-EOS
rm #{dir}/#{file}
      EOS
    end
  end
end
$stderr.print "Done. You may want to mv updated-extent.geojson extent.geojson\n"
