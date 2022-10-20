# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_show_blog, only: %i[show]
  before_action :set_editable_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_show_blog
    target_blog = Blog.find(params[:id])

    return @blog = Blog.published.find(params[:id]) unless current_user
    return @blog = Blog.published.find(params[:id]) if current_user && !target_blog.owned_by?(current_user)

    @blog = target_blog if current_user && target_blog.owned_by?(current_user)
  end

  def set_editable_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def blog_params
    columns = %i[title content secret]
    columns << :random_eyecatch if current_user.premium?
    params.require(:blog).permit(columns)
  end
end
