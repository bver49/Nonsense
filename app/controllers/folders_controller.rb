class FoldersController < ApplicationController
  before_action :check_login,except: %i[myfolder show]
  before_action :find_folder, only: %i[show edit update destroy]

  def myfolder
    @user = User.find(params[:id])
    if @user.role == 0
      redirect_to :back
    end
    @show=1
    @folder= Folder.where("user_id = ?",params[:id])
    @folderownerid = params[:id].to_i
  end

  def show
    @post = Post.where("folder_id = ?",@folder.id)
  end

  def create
    @folder= Folder.new(folder_params)
    @folder.user_id = current_user.id
    if @folder.save
      redirect_to myfolder_path(current_user)
    else
      redirect_to myfolder_path(current_user)
    end
  end

  def choose_addpost
    @folder=Folder.find(params[:folder_id])
    @post = Post.where("folder_id = ?",0)
  end

  def choose_removepost
    @folder=Folder.find(params[:folder_id])
    @post = Post.where("folder_id = ?",@folder.id)
  end


  def addpost
    @post = Post.find(params[:id])
    @post.folder_id = params[:folder_id]
    @post.save
    respond_to do |format|
      format.js
    end
  end

  def removepost
    @post = Post.find(params[:id])
    @post.folder_id = 0
    @post.save
    respond_to do |format|
      format.js
    end
  end

  def destroy
    @post = Post.where(folder_id: @folder.id)
    @post.each do |post|
      post.folder_id = 0
      post.save
    end
    @folder.destroy
    respond_to do |format|
      format.js
    end
  end
  private
  def find_folder
    @folder=Folder.find(params[:id])
  end

  def folder_params
    params.require(:folder).permit(:title,:about)
  end
end
