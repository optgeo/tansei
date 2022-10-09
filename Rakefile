task :fgb do
  sh <<-EOS
ogr2ogr -f FlatGeobuf docs/tansei.fgb extent.geojsons
  EOS
end

task :host do
  sh <<-EOS
budo -d docs
  EOS
end

