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
    clean_params_helper(params, skip_clean_params?) if params.present?
  end
  def clean_params_helper(params, skip_level=nil)
    # 2013-06-25: In Rails' multiparameter attribute assignment code,
    # .empty? is called on the attribute value.
    # nil doesn't have #empty?, so avoid multiparameter values.
    params.each do |k,v|
      if v.is_a?(Hash)
        # Crawl the branches.
        clean_params_helper(v)
      elsif !skip_level
        # 2015-07-13: RailsAdmin actions often depend on existence
        # of top-level params ("_continue" for cancel buttons,
        # "csv" for export, ...).
        if v.blank? && !k.to_s.include?('(')
          params[k] = nil
        elsif v.is_a?(String)
          params[k] = v.strip
        end
      end
    end
  end
  def skip_clean_params?
    self.class.name == 'RailsAdmin::MainController'
  end

end
