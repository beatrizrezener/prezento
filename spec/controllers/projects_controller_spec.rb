require 'spec_helper'

describe ProjectsController do

  describe 'new' do
    before :each do
      get :new
    end

    it { should respond_with(:success) }
    it { should render_template(:new) }
  end
  
  describe 'create' do

    context 'with valid fields' do
      before :each do
        @subject = FactoryGirl.build(:project)
        @subject_params = Hash[FactoryGirl.attributes_for(:project).map { |k,v| [k.to_s, v.to_s] }] #FIXME: Mocha is creating the expectations with strings, but FactoryGirl returns everything with sybols and integers

        Project.expects(:new).at_least_once.with(@subject_params).returns(@subject)
        Project.any_instance.expects(:save).returns(true)
      end

      context 'rendering the show' do
        before :each do 
          Project.expects(:exists?).returns(true)

          post :create, :project => @subject_params
        end

        it 'should redirect to the show view' do
          response.should redirect_to project_path(@subject)
        end
      end

      context 'without rendering the show view' do
        before :each do
          post :create, :project => @subject_params
        end
  
        it { should respond_with(:redirect) }
      end
    end

    context 'with an invalid field' do
      before :each do
        @subject = FactoryGirl.build(:project)
        @subject_params = Hash[FactoryGirl.attributes_for(:project).map { |k,v| [k.to_s, v.to_s] }] #FIXME: Mocha is creating the expectations with strings, but FactoryGirl returns everything with sybols and integers
        
        Project.expects(:new).at_least_once.with(@subject_params).returns(@subject)
        Project.any_instance.expects(:save).returns(false)

        post :create, :project => @subject_params
      end

      it { should render_template(:new) }
    end
  end

  describe 'show' do
    before :each do
      @subject = FactoryGirl.build(:project)
      Project.expects(:find).with(@subject.id.to_s).returns(@subject)
      get :show, :id => @subject.id
    end

    it { should render_template(:show) }
  end

  describe 'delete' do
    before :each do
      @subject = FactoryGirl.build(:project)
      @subject.expects(:destroy)
      Project.expects(:find).with(@subject.id.to_s).returns(@subject)
      delete :destroy, :id => @subject.id
    end

    it 'should redirect to the projects page' do
      response.should redirect_to projects_url
    end

    it { should respond_with(:redirect) }
  end

  describe 'index' do
    before :each do
      @subject = FactoryGirl.build(:project)
      Project.expects(:all).returns([@subject])
      get :index
    end

    it { should render_template(:index) }
  end

  describe 'edit' do
    before :each do
      @subject = FactoryGirl.build(:project)
      Project.expects(:find).with(@subject.id.to_s).returns(@subject)
      get :edit, :id => @subject.id
    end

    it { should render_template(:edit) }

    it 'should assign to @project the @subject' do
      assigns(:project).should eq(@subject)
    end
  end

  describe 'update' do
  
    context 'with valid fields' do
      before :each do
        @subject = FactoryGirl.build(:project)
        @subject_params = Hash[FactoryGirl.attributes_for(:project).map { |k,v| [k.to_s, v.to_s] }] #FIXME: Mocha is creating the expectations with strings, but FactoryGirl returns everything with sybols and integers

        Project.expects(:find).with(@subject.id.to_s).returns(@subject)
        Project.any_instance.expects(:update).with(@subject_params).returns(true)
      end

      context 'rendering the show' do
        before :each do 
          Project.expects(:exists?).returns(true)

          post :update, :id => @subject.id, :project => @subject_params
        end

        it 'should redirect to the show view' do
          response.should redirect_to project_path(@subject)
        end
      end

      context 'without rendering the show view' do
        before :each do
          post :update, :id => @subject.id, :project => @subject_params
        end
  
        it { should respond_with(:redirect) }
      end
    end

    context 'with an invalid field' do
      before :each do
        @subject = FactoryGirl.build(:project)
        @subject_params = Hash[FactoryGirl.attributes_for(:project).map { |k,v| [k.to_s, v.to_s] }] #FIXME: Mocha is creating the expectations with strings, but FactoryGirl returns everything with sybols and integers
        
        Project.expects(:find).with(@subject.id.to_s).returns(@subject)
        Project.any_instance.expects(:update).with(@subject_params).returns(false)

        post :update, :id => @subject.id, :project => @subject_params
      end

      it { should render_template(:edit) }
    end
  end

end