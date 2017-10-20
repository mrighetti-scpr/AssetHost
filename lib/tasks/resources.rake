namespace :resources do

  desc "Precompile resources with non-digested symlinks."
  task precompile: :environment do
    Rake::Task['assets:precompile'].invoke

    Dir.glob(File.join(Rails.root, 'public/resources/**/*'))
      .select { |f| f =~ /\-[a-z0-9]{64}\.[a-z]{2,3}/ }
      .each do |client_path|
        FileUtils.ln_s(client_path, client_path.gsub(/\-[a-z0-9]{64}/, ""), :force => true)
      end

  end

end
