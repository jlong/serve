def ok_failed(condition)
  if (condition)
    puts "OK"
  else
    puts "FAILED"
  end
end

namespace :website do
  
  desc "remove files in output directory"
  task :clean do
    puts "Removing output..."
    Dir["website/output/*"].each { |f| rm_rf(f) }
  end
  
  desc "generate website in output directory"
  task :generate => :clean do
    puts "Generating website..."
    system "bin/serve export website website/output"
  end
  
  desc "generate and deploy website"
  task :deploy => :generate do
    print "Deploying website..."
    ok_failed system("rsync -avz --delete --rsync-path=/usr/local/bin/rsync website/output/ wiseheart@wiseheartdesign.com:~/domains/get-serve.com/web/public")
  end
  
  desc "serve website using serve (how meta)"
  task :serve do
    puts "Serving website..."
    system "serve website"
  end
  
end
