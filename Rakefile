desc 'create FlatGeobuf file from GeoJSON extent file'
task :fgb do
  sh <<-EOS
sort extent.geojsons | uniq | grep -v 08nd5180 > tmp.geojsons
ogr2ogr -f FlatGeobuf docs/tansei.fgb tmp.geojsons
rm tmp.geojsons
  EOS
end

desc 'host the site locally'
task :host do
  sh <<-EOS
budo -d docs
  EOS
end

