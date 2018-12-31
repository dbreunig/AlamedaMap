require 'fileutils'

basedir = '.'
files = Dir.glob("*.gif").sort_by { | x | x }
start = 60
files.each do | f | 
    name = "map#{start}.gif"
    FileUtils.cp(f,"#{basedir}/#{name}")
    start -= 1
end