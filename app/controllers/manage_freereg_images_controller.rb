class ManageFreeregImagesController < ApplicationController
  before_action :set_manage_freereg_image, only: [:show, :edit, :update, :destroy]
  
  def access
    process,@counties = ManageFreeregImage.get_county_folders(params)
    if process
      render '_county_index'
    else
     flash[:notice] = "There was a problem with locating the image folder."
     render '_error_message'
    end 
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

  # GET /manage_freereg_images
  # GET /manage_freereg_images.json
  def index
    flash[:notice] = "You are not permitted to use these resources." 
   render '_error_message'
  end

  # GET /manage_freereg_images/1
  # GET /manage_freereg_images/1.json
  def show
  end

  # GET /manage_freereg_images/new
  def new
    #@manage_freereg_image = ManageFreeregImage.new
  end

  # GET /manage_freereg_images/1/edit
  def edit
  end

  # POST /manage_freereg_images
  # POST /manage_freereg_images.json
  def create
    #@manage_freereg_image = ManageFreeregImage.new(manage_freereg_image_params)

    respond_to do |format|
      if @manage_freereg_image.save
        format.html { redirect_to @manage_freereg_image, notice: 'Manage freereg image was successfully created.' }
        format.json { render :show, status: :created, location: @manage_freereg_image }
      else
        format.html { render :new }
        format.json { render json: @manage_freereg_image.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def images
    @county = params[:county]
    @register = params[:register]
    process,@images = ManageFreeregImage.get_images(@county, @register )
     if !process
      flash[:notice] = "There was a problem with locating the images for the register folder #{@register}  for the county of #{@county}."
      render '_error_message'
     end
  end
  
  def register_folders
    @county = params[:county]
    process,@registers = ManageFreeregImage.get_register_folders(@county)
     if !process
      flash[:notice] = "There was a problem with locating the register folders for the county of #{@county}."
      render '_error_message'
     end
  end

  # PATCH/PUT /manage_freereg_images/1
  # PATCH/PUT /manage_freereg_images/1.json
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

  # DELETE /manage_freereg_images/1
  # DELETE /manage_freereg_images/1.json
  def destroy
    @manage_freereg_image.destroy
    respond_to do |format|
      format.html { redirect_to manage_freereg_images_url, notice: 'Manage freereg image was successfully destroyed.' }
      format.json { head :no_content }
    end
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
      params.fetch(:manage_freereg_image, {})
    end
end
