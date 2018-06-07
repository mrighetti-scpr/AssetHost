namespace :resources do

  desc "Precompile resources"
  task precompile: :environment do
    puts "Precompiling resources."
    Dir.chdir("#{Dir.pwd}/frontend/") do
      if ENV["RAILS_ENV"] == "production"
        system "ember build -prod"
      else
        system "ember build"
      end
    end

  end

end
