def run(*args)
    success = system './build.sh', *args
    puts(if success
      "\e[1;92mPASS\e[0m"
    else
      "\e[1;91mFAIL\e[0m"
    end)
end

def sep(f)
  puts "\033[93m#{Time.now}: #{File.basename f}\033[0m"
end

guard :shell do
  watch /^wasm\/(vim\.bc|runtime\.js|pre\.js)$/ do |m|
    sep m[0]
    run 'emcc'
  end
  watch /^wasm\/usr/ do |m|
    sep m[0]
    run 'emcc'
  end
  watch /^src\/[^\/]+\.[ch]$/ do |m|
    sep m[0]
    run 'make'
  end
  watch /^src\/configure\.ac$/ do |m|
    sep m[0]
    run 'configure'
  end
end
