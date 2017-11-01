class ManageFreeregImage 
    require 'chapman_code' 
  class << self 
   #include Mongoid::Document 
   def check_chapman_code_folder?(chapman_code)
       process = true
       image_directory = File.join(Rails.root,Rails.application.config.imagedirectory)
       counties = Dir.entries(image_directory) 
       process = false unless counties.include?(chapman_code)
       return process
   end
   
   def check_register?(chapman_code,register)
       process = true
       county_directory = File.join(Rails.root,Rails.application.config.imagedirectory,chapman_code)
       registers = Dir.entries(county_directory) 
       process = false unless registers.include?(register)
       return process 
   end
   
   def check_file?(chapman_code,register,file)
       process = true
       register_directory = File.join(Rails.root,Rails.application.config.imagedirectory,chapman_code,register)
       files = Dir.entries(register_directory) 
       process = false unless files.include?(file)
       return process 
   end
   
   def check_parameters(param)
       # need to add check that userid is valid
       process = true
       message = ""
       ChapmanCode.value?(param[:chapman_code]) ?  process1 = true :  process1 = false 
       message = "Invalid Chapman Code #{}" unless ChapmanCode.value?(param[:chapman_code])
       self.check_chapman_code_folder?(param[:chapman_code]) ? process2 = true :  process2 = false
       meassage = message + "There is no folder for chapman code #{param[:chapman_code]}" unless process2
       self.check_register?(param[:chapman_code],param[:folder_name]) ? process3 = true : process3 = false
       meassage = message + "There is no folder for register #{param[:folder_name]}" unless process3
       self.check_file?(param[:chapman_code],param[:folder_name],param[:image_file_name]) ? process4 = true : process4 = false
       meassage = message + "There is file #{param[:image_file_name]}" unless process4
       process = false if !process1 || !process2 || !process3 || !process4
       return process,message
       
   end
   
   def create_file_location(param)
      File.join(Rails.root,Rails.application.config.imagedirectory,param[:chapman_code],param[:folder_name],param[:image_file_name])  
   end
   
   def get_folders
       hash_of_images = Hash
       p Rails.application.config.imagedirectory
       image_directory = File.join(Rails.root,Rails.application.config.imagedirectory)
       p image_directory
       Dir.chdir(image_directory)
       #p DIR.pwd
       pattern = '*'
       p pattern
       counties = Dir.glob(pattern, File::FNM_CASEFOLD).sort 
       p counties
       counties.each do |county|
           p county
         county_directory = File.join(image_directory,county)
         Dir.chdir(county_directory)   
         register_sources = Dir.glob(pattern, File::FNM_CASEFOLD).sort 
         p register_sources
         register_sources.each do |register|
             register_directory = File.join(county_directory,register)
             Dir.chdir(register_directory)
             images =  Dir.glob(pattern, File::FNM_CASEFOLD).sort
             p images
         end
       end
   end
  end # end self class
  
end
