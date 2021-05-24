# frozen_string_literal: true

class DeepLinkingController < ApplicationController
  RESPONSE_MESSAGE_TYPE = 'LtiDeepLinkingResponse'
  LTI_VERSION = '1.3.0'

  def redirect
    @deep_link_return_url = deep_link_return_url
    @jwt = jwt
  end

  private

  def jwt
    DeepLinkingProvider.create_jws(
      iss: params[:iss],
      aud: params[:aud],
      content_items: content_items,
      message: params[:message],
      deployment_id: params[:deployment_id],
      error_message: params[:error_message],
      log: params[:log],
      error_log: params[:error_log]
    )
  end

  def content_item(multiple_items_number=nil)
    Factories::ContentItemFactory.create(
      params.merge(multiple_items_number: multiple_items_number),
      content_type,
      host: request.host_with_port
    )
  end

  def content_items
    return [] if params[:without_content_items].present?

    if params[:multiple_items].present?
      (1..3).map { |i| content_item(i) }
    else
      [content_item]
    end
  end

  def hashed_param(param)
    return {} unless params.key?(param)

    JSON.parse params[param].to_s
  rescue JSON::ParserError
    nil
  end

  def deep_link_return_url
    params.require(:deep_link_return_url)
  end

  def content_type
    params.require(:content_type)
  end
end
