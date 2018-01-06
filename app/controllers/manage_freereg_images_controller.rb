class ManageFreeregImagesController < ApplicationController
  before_action :set_manage_freereg_image, only: [:show, :edit, :update, :destroy]
  
  def access
    ManageFreeregImage.access_permitted?( params[:image_server_access]) 
    session[:role] = params[:role]
    @chapman_code = params[:chapman_code]
    session[:county_chapman_code] =  @chapman_code
    process,@counties = ManageFreeregImage.get_county_folders(params)
    if !process
      flash[:notice] = "There was a problem with locating the image folder."
      render '_error_message'
    end 
  end
  
  def close
    session.delete(:role)
    session.delete(:params)
    session.delete(:county_chapman_code)
    session.delete(:register_chapman_code)
  end
  
  def create
    manage_freereg_image = ManageFreeregImage.new(manage_freereg_image_params)
    parameters = session[:params]
    chapman_code = parameters["chapman_code"] 
    folder_name = parameters["folder_name"]
    register = parameters["register"]
    image_server_group =  parameters["group_id"]
    proceed, message, website = manage_freereg_image.process_upload(chapman_code,folder_name,register,image_server_group,params)
    if proceed
      redirect_to website and return
    else 
      flash[:notice] = message
      @manage_freereg_image = ManageFreeregImage.new
      parameters = session[:params]
      @chapman_code = parameters["chapman_code"] 
      @folder_name = parameters["folder_name"]
      @register = parameters["register"]
      @church = parameters["church"]
      @register_type = parameters["register_type"]
      @place = parameters["place"]
      @image_server_group =  parameters["group_id"]
      render 'upload_images'
    end
  end
  
  def create_folder
    ManageFreeregImage.access_permitted?( params[:image_server_access]) 
    #entry point to create  a new register folder on the IS
    proceed,message = ManageFreeregImage.create_county_and_register_folders(params[:chapman_code],params[:folder_name])
    website = ManageFreeregImage.create_return_url(params[:register],params[:folder_name],proceed,message)
    redirect_to website and return
  end
  
  def download
    process,message = ManageFreeregImage.check_parameters(params)
    process,@image = ManageFreeregImage.create_file_location(params) if process
    if process
       send_file @image
    else
     flash[:notice] = "There was a problem with your request. #{message}"
     render '_error_message'
    end
  end

  def images
    @county = params[:county]
    @register = params[:register]
    process,@images,@thumbnails = ManageFreeregImage.get_images_and_get_or_create_thumbnails(@county, @register )
    if !process
      flash[:notice] = "There was a problem with locating the images for the register folder #{@register}  for the county of #{@county}."
      render '_error_message'
    end
  end
  
  def index
    flash[:notice] = "You are not permitted to use these resources." 
   render '_error_message'
  end
  
  def register_folders
    @county = params[:county]
    session[:register_chapman_code] =    @county
    process,@registers = ManageFreeregImage.get_register_folders(@county)
    if !process
      flash[:notice] = "There was a problem with locating the register folders for the county of #{@county}."
      render '_error_message'
    end
  end
  
  
  def remove_image
    ManageFreeregImage.access_permitted?( params[:image_server_access]) 
    process,message = ManageFreeregImage.delete_image(params)
    if !process
      notice = "There was a problem with deleting the image because #{message}"
    else
       notice = "Image removed"
    end
     website = ManageFreeregImage.create_return_url_after_image_delete(params[:image_server_group_id],params[:image_file_name],message)
     redirect_to website
  end

  def update
    respond_to do |format|
      if @manage_freereg_image.update(manage_freereg_image_params)
        format.html { redirect_to @manage_freereg_image, notice: 'Manage freereg image was successfully updated.' }
        format.json { render :show, status: :ok, location: @manage_freereg_image }
      else
        format.html { render :edit }
        format.json { render json: @manage_freereg_image.errors, status: :unprocessable_entity }
      end
    end
  end

  def upload_images
    ManageFreeregImage.access_permitted?( params[:image_server_access]) 
    session[:params] = params
    @place = params[:place]
    @manage_freereg_image = ManageFreeregImage.new
    @chapman_code = params[:chapman_code] 
    @folder_name = params[:folder_name]
    @register_type = params[:register_type]
    @church = params[:church]
    @image_server_group =  params[:group_id]
  end
  
  def view
    process,@message = ManageFreeregImage.check_parameters(params)
    process,@image = ManageFreeregImage.create_file_location(params) if process
    if process
       send_file @image,  :disposition => 'inline'
    else
      flash[:notice] = "There was a problem with your request. #{@message}"
      render '_error_message'
    end
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_manage_freereg_image
      @manage_freereg_image = ManageFreeregImage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def manage_freereg_image_params
      params.require(:manage_freereg_image).permit!
    end
end
