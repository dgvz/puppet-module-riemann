guard :shell do
	watch(%r{^manifests/[^/#]+\.pp})      { |m| puts "Running for #{m[0]}"; system("rake") }
	watch(%r{^spec/.*/[^/#]+_spec\.rb})   { |m| puts "Running for #{m[0]}"; system("rake") }
end
