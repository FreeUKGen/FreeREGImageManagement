module ApplicationHelper
  def title(title = nil)
    if title.present?
      content_for :title, title
    elsif content_for?(:title)
      title = content_for(:title) +  ' | ' + "FreeReg Image Server"

    elsif  page_title.present?
      title = page_title + ' | '  + "FreeReg Image Server"
    else
      title = "FreeReg Image Server"
    end
  end 
    
end
