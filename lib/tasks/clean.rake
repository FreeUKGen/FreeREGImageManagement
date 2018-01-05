namespace :carrierwave do
  desc "Clean out temp CarrierWave files"
  task :clean,[:seconds] => :environment do |t, args|
    args.seconds.present? ? seconds = args.seconds  : seconds = 86400
    Dir.glob(File.join(Rails.root, 'public', 'carrierwave','*')).each do |dir|
      # generate_cache_id returns key formated TIMEINT-PID-COUNTER-RND
      time = dir.scan(/(\d+)-\d+-\d+-\d+/).first.map(&:to_i)
      time = Time.at(*time)
      if time < (Time.now.utc - 100)
        FileUtils.rm_rf(dir)
      end
    end
  end
end