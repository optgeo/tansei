desc 'create FlatGeobuf file from GeoJSON extent file'
task :fgb do
  sh <<-EOS
ogr2ogr -f FlatGeobuf docs/tansei.fgb extent.geojsons
  EOS
end

desc 'host the site locally'
task :host do
  sh <<-EOS
budo -d docs
  EOS
end

