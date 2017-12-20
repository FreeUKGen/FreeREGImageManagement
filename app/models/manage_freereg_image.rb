class ManageFreeregImage
  include Mongoid::Document
  require 'chapman_code' 
  field :chapman_code, type: String
  field :folder_name, type: String
  field :file_name,type: String 
  mount_uploaders :freereg_images, FreeregImageUploader    
    
  class << self 
   #include Mongoid::Document 
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
       Rails.application.config.image_server_access == param[:image_server_access] ? process0 = true : process0 = false
       message = "Access not prermitted" if !process0
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
   
   def create_county_and_register_folders(chapman_code,folder_name,image_server_access)
     #check if chapman exists if so use, if not create then create the register folder error if it does
     Rails.application.config.image_server_access == image_server_access ? process0 = true : process0 = false
     if !process0
       message = "Access not prermitted"
       proceed = false
     else
         message1 = ""
         proceed1,message1 =  self.check_or_create_chapman_code_folder(chapman_code)
         proceed2 = false
         message2 = ""
         proceed2,message2 = self.check_or_create_register_folder(chapman_code,folder_name) if proceed1
         proceed1 && proceed2 ? proceed = true : proceed = false
         message = message1 + " " + message2
     end 
     return proceed, message
   end
   
   def create_file_location(param)
     process = true
     #we use the test to diferentiate between the operational environment and a cloud9 test environment
     Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? location = File.join(Rails.application.config.imagedirectory,param[:chapman_code],param[:folder_name],param[:image_file_name]) : location =  File.join(Rails.root,Rails.application.config.imagedirectory,param[:chapman_code],param[:folder_name],param[:image_file_name])  
     process = false unless File.exist?(location)
     return process,location   
   end
   
   def create_return_url(register,folder_name,proceed,message)
     proceed ? success = "Succeeded" : success = "Failed"
     URI.escape(Rails.application.config.application_website + 'registers/create_image_server_return?register=' + register + '&folder_name=' + folder_name + '&success=' + success + '&message=' + message)
   end
   
   def create_upload_return_url(register,folder_name,proceed,message,image_server_group)
      proceed ? success = "Succeeded" : success = "Failed"
     URI.escape(Rails.application.config.application_website + 'registers/create_image_server_return?register=' + register + '&folder_name=' + folder_name + '&success=' + success + '&message=' + message + '&image_server_group=' + image_server_group)
     
   end
   
   def delete_image(param)
     Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? image_location = File.join(Rails.application.config.imagedirectory,param[:chapman_code],param[:folder_name],param[:image_file_name]) : image_location =  File.join(Rails.root,Rails.application.config.imagedirectory,param[:chapman_code],param[:folder_name],param[:image_file_name])  
     return true
   end
   
   
   def get_images(chapman_code,register)
    Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? register_folder = File.join(Rails.application.config.imagedirectory,chapman_code,register) : register_folder = File.join(Rails.root,Rails.application.config.imagedirectory,chapman_code,register)
    File.exist?(register_folder) ? process = true : process = false  
    if process
      Dir.chdir(register_folder)
      pattern = '*'
      images = Dir.glob(pattern, File::FNM_CASEFOLD).sort   
    end
    return process,images
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
  end # end self class
  
  def process_upload(chapman_code,folder_name,register,image_server_group,param)
    files_exist = Array.new
    files_uploaded = Array.new
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
    files_exist.length == 0 ? files_exist = ' ' : files_exist = files_exist.join('/')
    files_uploaded.length == 0 ? files_uploaded = ' ' : files_uploaded = files_uploaded.join('/')
    proceed = true
    message = ''
    website = URI.escape(Rails.application.config.application_website + 'image_server_groups/upload_return?register=' + register + '&folder_name=' + folder_name + '&image_server_group=' + image_server_group + '&files_exist=' + files_exist + '&files_uploaded=' + files_uploaded)
    return proceed, message, website
  end
end
