class ManageFreeregImage
  include Mongoid::Document
  require 'chapman_code'
  require "mini_magick"

  field :chapman_code, type: String
  field :folder_name, type: String
  field :file_name,type: String
  mount_uploaders :freereg_images, FreeregImageUploader

  class << self
    def access_permitted?(access)
      self.crash unless Rails.application.config.image_server_access == access
      true
    end

    def check_chapman_code_folder?(chapman_code)
      process = true
      Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? image_directory = File.join(Rails.application.config.imagedirectory)  :image_directory = File.join(Rails.root,Rails.application.config.imagedirectory)
      process = false unless File.exist?(image_directory)
      if process
        counties = Dir.entries(image_directory)
        process = false unless counties.include?(chapman_code)
      end
      return process
    end

    def check_register?(chapman_code,register)
      process = true
      Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? county_directory = File.join(Rails.application.config.imagedirectory,chapman_code)  : county_directory = File.join(Rails.root,Rails.application.config.imagedirectory,chapman_code)
      process = false unless File.exist?(county_directory)
      if process
        registers = Dir.entries(county_directory)
        process = false unless registers.include?(register)
      end
      return process
    end

    def check_file?(chapman_code,register,file)
      process = true
      Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? register_directory = File.join(Rails.application.config.imagedirectory,chapman_code,register) : register_directory = File.join(Rails.root,Rails.application.config.imagedirectory,chapman_code,register)
      process = false unless File.exist?(register_directory)
      if process
        files = Dir.entries(register_directory)
        process = false unless files.include?(file)
      end
      return process
    end

    def check_or_create_chapman_code_folder(chapman_code)
      #Check the chapman folder; we assume chapman valid as it was taken from the place.
      Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? location = File.join(Rails.application.config.imagedirectory,chapman_code) : location =  File.join(Rails.root,Rails.application.config.imagedirectory,chapman_code)
      message = "#{chapman_code} existed and used."
      unless Dir.exist?(location)
        Dir.mkdir(location)
        message = "Created #{chapman_code}."
      end
      return true,message
    end

    def check_or_create_register_folder(chapman_code,folder_name)
      #check and create register folder
      Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? location = File.join(Rails.application.config.imagedirectory,chapman_code,folder_name) : location =  File.join(Rails.root,Rails.application.config.imagedirectory,chapman_code,folder_name)
      if Dir.exist?(location)
        proceed = false
        message = " Register folder for #{folder_name} in #{chapman_code} already exits."
      else
        Dir.mkdir(location)
        message = " Created register folder #{folder_name} for #{chapman_code}."
        proceed = true
      end
      return proceed,message
    end

    def check_parameters(param)
      # need to add check that id userid is valid
      process = true;   process0 = true;     process1  = true;        process2  = true;        process3  = true;        process4  = true
      message = ""
      ChapmanCode.value?(param[:chapman_code]) && process0 ?  process1 = true :  process1 = false
      message = "Invalid Chapman Code #{param[:chapman_code]}" if !process1
      (self.check_chapman_code_folder?(param[:chapman_code]) ? process2 = true :  process2 = false) if process1
      message = message + "There is no folder for chapman code #{param[:chapman_code]}" if !process2
      (self.check_register?(param[:chapman_code],param[:folder_name]) ? process3 = true : process3 = false) if process1 && process2
      message = message + "There is no folder for register #{param[:folder_name]}" if !process3
      (self.check_file?(param[:chapman_code],param[:folder_name],param[:image_file_name]) ? process4 = true : process4 = false) if process1 && process2 && process3
      message = message + "There is no file #{param[:image_file_name]}" if !process4
      process = false if !process0 || !process1 || !process2 || !process3 || !process4
      return process,message
    end

    def convert_extension(image_name,out)
      image_name_parts = image_name.split('.')
      image_name_parts[-1] = out
      new_image_name = image_name_parts.join('.')
      new_image_name
    end

    def create_county_and_register_folders(chapman_code,folder_name)
      #check if chapman exists if so use, if not create then create the register folder error if it does
      message1 = ""
      proceed1,message1 =  self.check_or_create_chapman_code_folder(chapman_code)
      proceed2 = false
      message2 = ""
      proceed2,message2 = self.check_or_create_register_folder(chapman_code,folder_name) if proceed1
      proceed1 && proceed2 ? proceed = true : proceed = false
      message = message1 + " " + message2
      return proceed, message
    end

    def create_file_location(param)
      process = true
      #we use the test to diferentiate between the operational environment and a cloud9 test environment
      Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? location = File.join(Rails.application.config.imagedirectory,param[:chapman_code],param[:folder_name],param[:image_file_name]) : location =  File.join(Rails.root,Rails.application.config.imagedirectory,param[:chapman_code],param[:folder_name],param[:image_file_name])
      process = false unless File.exist?(location)
      return process,location
    end

    def create_or_use_thumbnail_folders(chapman_code,register)
      #Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? chapman_folder = File.join('public/images',chapman_code) : chapman_folder = File.join(Rails.root,'public/images',chapman_code)
      #Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? register_output = File.join('public/images',chapman_code,register) : register_output = File.join(Rails.root,'public/images',chapman_code,register)
      chapman_folder = File.join(Rails.root,'public/images',chapman_code)
      register_output = File.join(Rails.root,'public/images',chapman_code,register)
      if !File.exist?(chapman_folder)
        Dir.mkdir( chapman_folder )
      end
      if !File.exist?(register_output)
        Dir.mkdir( register_output )
      end
      register_output
    end

    def create_return_url(host,register,folder_name,proceed,message)
      host = Rails.application.config.application_website
      proceed ? success = "Succeeded" : success = "Failed"
      URI.escape(host + 'registers/create_image_server_return?register=' + register + '&folder_name=' + folder_name + '&success=' + success + '&message=' + message)
    end

    def create_return_url_after_image_delete(host,image_server_group_id,image_file_name,message)
      host = Rails.application.config.application_website
      URI.escape(host + 'image_server_images/return_from_image_deletion?image_server_group_id=' + image_server_group_id + '&image_file_name=' + image_file_name + '&message=' + message)
    end


    def create_thumbnail(register_folder,register_output,my_image)
      image_location = File.join(register_folder,my_image)
      image = MiniMagick::Image.open(image_location)
      image.format "jpg"
      image.resize "100x100"
      image.format "jpg"
      my_image = self.convert_extension(my_image,'jpg')
      ouput_location = File.join(register_output,my_image)
      image.write ouput_location
      return my_image
    end

    def delete_image(param)
      Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? image_location = File.join(Rails.application.config.imagedirectory,param[:chapman_code],param[:folder_name],param[:image_file_name]) : image_location =  File.join(Rails.root,Rails.application.config.imagedirectory,param[:chapman_code],param[:folder_name],param[:image_file_name])
      message = 'No file'
      File.exist?(image_location) ?  process = true : process = false
      if process
        File.delete(image_location)
        message = 'File deleted'
      end
      return process,message
    end


    def get_county_folders(param)
      #we use the test to diferentiate between the operational environment and a cloud9 test environment
      Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? images_directory = File.join(Rails.application.config.imagedirectory) : images_directory = File.join(Rails.root,Rails.application.config.imagedirectory)
      File.exist?(images_directory) ?  process = true : process = false
      if process
        Dir.chdir(images_directory)
        param[:chapman_code] == 'all' ? pattern = '*' : pattern =  param[:chapman_code].to_s
        counties = Dir.glob(pattern, File::FNM_CASEFOLD).sort
      end
      return process,counties
    end


    def get_images_and_get_or_create_thumbnails(chapman_code,register)
      Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? register_folder = File.join(Rails.application.config.imagedirectory,chapman_code,register) : register_folder = File.join(Rails.root,Rails.application.config.imagedirectory,chapman_code,register)
      thumbnail_output = self.create_or_use_thumbnail_folders(chapman_code,register)
      File.exist?(register_folder) ? process = true : process = false
      if process
        Dir.chdir(register_folder)
        pattern = '*'
        images = Dir.glob(pattern, File::FNM_CASEFOLD).sort
        thumbnails = Hash.new
        images.each do |my_image|
          if self.valid_thumbnail_image?(my_image) &&  images.length < 750
            # we can have thumbnail
            if File.exist?( File.join(thumbnail_output,my_image))
              # file extists with original extension
              thumb = my_image
            else
              if  File.exist?( File.join(thumbnail_output,self.convert_extension(my_image,'jpg')))
                #file exists with jpg extension
                thumb = self.convert_extension(my_image,'jpg')
              else
                thumb = self.create_thumbnail(register_folder,thumbnail_output,my_image)
              end
            end
            thumbnails[ my_image ] = File.join(chapman_code,register,thumb)
          end
        end
      end
      return process,images,thumbnails
    end


    def get_register_folders(chapman_code)
      Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? register_folders = File.join(Rails.application.config.imagedirectory,chapman_code) : register_folders = File.join(Rails.root,Rails.application.config.imagedirectory,chapman_code)
      File.exist?(register_folders) ? process = true : process = false
      if process
        Dir.chdir(register_folders)
        pattern = '*'
        registers = Dir.glob(pattern, File::FNM_CASEFOLD).sort
      end
      return process,registers
    end

    def valid_thumbnail_image?(image_name)
      image_name_parts = image_name.split('.')
      valid = self.valid_extension_for_thumbnail?(image_name_parts.last)
      valid
    end

    def valid_extension_for_thumbnail?(extension)
      valid = extension.present?  && (extension.downcase == 'jpg' || extension.downcase == 'jpeg' || extension.downcase == 'tif' || extension.downcase == 'tiff')
      valid
    end
  end # end self class

  def process_upload(host,chapman_code,folder_name,register,image_server_group,userid,param)
    files_exist = Array.new
    files_uploaded = Array.new
    if self.freereg_images_cache.nil?
      proceed = false
      message = "One or more of the images being uploaded had an invalid file type"
      website = ''
    else
      if self.process_upload_check_length
        cache_parts = self.freereg_images_cache.split(',')
        cache_parts.each do |cach|
          cache_file = cach.gsub(/\[/,'').gsub(/\]/,'').gsub(/\"/, '').gsub(/\\/,'')
          file_parts = cache_file.split('/')
          (Rails.application.config.website == 'https://image_management.freereg.org.uk/') ? to = File.join(Rails.application.config.imagedirectory,chapman_code,folder_name,file_parts[1])  : to   = File.join(Rails.root,Rails.application.config.imagedirectory,chapman_code,folder_name,file_parts[1])
          if File.exist?(to)
            files_exist << file_parts[1]
          else
            from =  File.join(Rails.root,'public', 'carrierwave',cache_file)
            FileUtils.mv(from,to,:verbose => true)
            files_uploaded << file_parts[1]
          end
        end
        files_exist.length == 0 ? files_exist = ' ' : files_exist = files_exist.join('/ ')
        files_uploaded.length == 0 ? files_uploaded = ' ' : files_uploaded = files_uploaded.join('/ ')
        proceed = true
        message = ''

        website = URI.escape(Rails.application.config.application_website + 'image_server_groups/upload_return?register=' + register + '&folder_name=' + folder_name + '&image_server_group=' + image_server_group +'&userid=' +
                             userid + '&files_exist=' + files_exist.to_s + '&files_uploaded=' + files_uploaded.to_s)
      else
        proceed = false
        message = "There were too many files in combination with their names for the upload to succeed"
        website = ''
      end
    end
    return proceed, message, website
  end
  def process_upload_check_length
    characters = 0
    cache_parts = self.freereg_images_cache.split(',')
    cache_parts.each do |cach|
      cache_file = cach.gsub(/\[/,'').gsub(/\]/,'').gsub(/\"/, '').gsub(/\\/,'')
      file_parts = cache_file.split('/')
      characters = characters + file_parts[1].to_s.length
    end
    characters <= 1800 ? process = true : process = false
  end
end
