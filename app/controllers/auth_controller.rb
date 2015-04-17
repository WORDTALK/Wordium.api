class AuthController < ApplicationController

  def callback
    data = env["omniauth.auth"]
    provider = IdentityProvider.find_or_create_by(name: data["provider"])
    if provider.name == "facebook"
      facebook_callback(provider)
    end
    redirect_to ENV["UI_HOST"] + "/auth_callback?auth_key=#{identity.user.auth_key}&username=#{user.username}"
  end

 private

  def facebook_callback(provider)
    cred = data["credentials"]
    token = cred["token"]
    identity = provider.find_with_token(token)
    if identity.nil?
      if data["info"]["verified"] && (user = User.where(email: data["info"]["email"]).first)
        identity = user.identities.find_or_initialize_by(identity_provider: provider)
      else
        identity = provider.identities.build
      end
    end

    identity.token = token
    identity.expires_at = cred["expires_at"]
    identity.data = data
    identity.save!
    if identity.user.nil?
      redirect_to ENV["UI_HOST"] + "/auth/facebook/setup?token=#{data["credentials"]["token"]}"
    else
      redirect_to ENV["UI_HOST"] + "/auth/facebook/callback?auth_key=#{identity.user.auth_key}&username=#{user.username}"
    end
  end

end
