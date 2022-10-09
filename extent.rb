require './constants'
require 'json'
require 'tmpdir'

$n = 0

def task
  Dir.mktmpdir('extent', TMPDIR) {|dir|
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
  File.open(GEOJSONS_PATH, 'w') {|w|
    yield w
  }
end

# main
write do |w|
  task do |dir|
    count = 0
    files do |file|
      count += 1
      id = File.basename(file, '.copc.laz')
      $stderr.print "#{id} (#{count}/#{$n})\n"
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
