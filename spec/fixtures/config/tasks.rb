desc "Task with arguments"
task :will_blend, [:thing] do |_t, args|
  puts "#{args.thing} will blend!"
end

desc "Default task"
task :meaning do
  p 42
end

desc "Task with an env variable"
task :foo do
  bar = ENV["FOO"] || 'bar'
  puts "variable = #{bar}."
end

task default: [:meaning]
