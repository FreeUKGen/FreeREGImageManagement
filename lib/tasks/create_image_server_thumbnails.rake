desc "Create thumbnails"
task :create_image_server_thumbnails => :environment do

  file_for_warning_messages = "log/image_server_thumbnails.log"
  FileUtils.mkdir_p(File.dirname(file_for_warning_messages) )  unless File.exists?(file_for_warning_messages)
  message_file = File.new(file_for_warning_messages, "w")
  p "Started creation of thumbnails"
  message_file.puts  "Started creation of thumbnails"
  param = Hash.new
  param[:chapman_code] = 'all'
  process,chapman_codes = ManageFreeregImage.get_county_folders(param)
  if process
    chapman_codes.each do |chapman_code|
      p "Processing #{chapman_code}"
      message_file.puts  "Processing #{chapman_code}"
      process1, registers = ManageFreeregImage.get_register_folders(chapman_code)
      if process1
        registers.each do |register|
          process2,images,thumbnails = ManageFreeregImage.get_images_and_get_or_create_thumbnails(chapman_code,register)
          if process2 
            p "There are thumbnails for #{chapman_code} #{register}"
            message_file.puts  "There are thumbnails #{thumbnails} for #{chapman_code} #{register}"
          else
            p "No public folder for #{chapman_code} #{register}"
            message_file.puts  "No public folder for #{chapman_code} #{register}"
          end
        end
      else
        p "No registers for #{chapman_code}"
        message_file.puts  "No registers for #{chapman_code}"
      end
    end
  else
     p "No image directory"
     message_file.puts  "No image directory"
  end
  p "Finished"
  message_file.puts  "Finished"
end
