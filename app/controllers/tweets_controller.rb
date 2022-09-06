class TweetsController < ApplicationController
  def index
    @tweets = Tweet.all.order(created_at: :desc)
    render 'tweets/index'
  end

  def create
    return render 'tweets/rate_limit_error', status: 400 unless current_user.pass_rate_limit?

    @tweet = current_user.tweets.new(tweet_params)

    render 'tweets/create', status: 201 if @tweet.save
  end

  def destroy
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)

    return render json: { success: false } unless session

    user = session.user
    tweet = Tweet.find_by(id: params[:id])

    if tweet && (tweet.user == user) && tweet.destroy
      render json: {
        success: true
      }
    else
      render json: {
        success: false
      }
    end
  end

  def index_by_user
    user = User.find_by(username: params[:username])

    if user
      @tweets = user.tweets
      render 'tweets/index'
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:message, :image)
  end
end
