Exifview::Application.routes.draw do

  root to: 'main#index'
  get 'content' => 'main#content'
  get 'image' => 'main#image'

end
