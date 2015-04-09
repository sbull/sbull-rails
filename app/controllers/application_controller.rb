class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  rescue_from ActionController::InvalidAuthenticityToken do |_exception|
    redirect_to root_url, alert: t('devise.failure.timeout')
  end

  before_action :clean_params!


  private

  def clean_params!
    clean_params_helper(params) if params.present? && !skip_clean_params?
  end
  def clean_params_helper(params)
    # 2013-06-25: In Rails' multiparameter attribute assignment code,
    # .empty? is called on the attribute value.
    # nil doesn't have #empty?, so avoid multiparameter values.
    params.each do |k,v|
      if v.blank? && !k.to_s.include?('(')
        params[k] = nil
      elsif v.is_a?(String)
        params[k] = v.strip
      elsif v.is_a?(Hash)
        # Crawl the branches.
        clean_params_helper(v)
      end
    end
  end
  def skip_clean_params?
    self.class.name == 'RailsAdmin::MainController' && action_name == 'export'
  end

end
