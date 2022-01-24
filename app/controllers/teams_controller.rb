class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy assignment_of_authority] 
  before_action :if_not_owner, only: %i[edit]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  # チームの編集はオーナーのみ可能
  def edit
  end

  def create
    @team = Team.new(team_params)  
      # @team.ownerにcurrent_userをセット
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t('views.messages.create_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to teams_path, notice: I18n.t('views.messages.update_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :edit
    end
  end

  def destroy    
    @team.destroy
    redirect_to teams_url, notice: I18n.t('views.messages.delete_team')
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  def assignment_of_authority
    if @team.update(owner_id: params[:user_id])
      AssignMailer.assignment_of_authority_mail(@team.owner.email).deliver
      redirect_to @team, notice: I18n.t('views.messages.assignment_of_authority')
    else
      redirect_to team_url, notice: I18n.t('views.messages.assignment_of_authority_4_some_reson')
    end
  end


  private

  def if_not_owner
    redirect_to teams_path, notice: I18n.t('views.messages.owner_authority') unless @team.owner.id == current_user.id
  end

  def set_team
    # https://qiita.com/reizist/items/c4482a358e7b5d69c83f
    # チーム名をURLに使う
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end
end
