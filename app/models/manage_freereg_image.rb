class ManageFreeregImage 
    require 'chapman_code' 
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
   
   def create_file_location(param)
     process = true
     #we use the test to diferentiate between the operational environment and a cloud9 test environment
     Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? location = File.join(Rails.application.config.imagedirectory,param[:chapman_code],param[:folder_name],param[:image_file_name]) : location =  File.join(Rails.root,Rails.application.config.imagedirectory,param[:chapman_code],param[:folder_name],param[:image_file_name])  
     process = false unless File.exist?(location)
     return process,location   
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
     #This code is in development
     
     Rails.application.config.website == 'https://image_management.freereg.org.uk/' ? images_directory = File.join(Rails.application.config.imagedirectory) : images_directory = File.join(Rails.root,Rails.application.config.imagedirectory)
     File.exist?(images_directory) ?  process = true : process = false 
     if process
       Dir.chdir(images_directory)
       pattern = '*'
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
end
