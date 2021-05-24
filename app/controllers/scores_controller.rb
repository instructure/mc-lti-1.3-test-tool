# frozen_string_literal: true

class ScoresController < ApplicationController
  include Concerns::AgsConcerns

  before_action :validate_params

  def create
    service_render service.create(create_params, :scores, params[:line_item_id])
  end

  private

  def create_params
    params
      .permit(:scoreGiven, :scoreMaximum, :comment, :activityProgress, :gradingProgress, :userId,
              :newSubmission, :submissionScoreType, :submissionScoreData, :submittedAt, :sendSubmittedAt,
              :sendContentItem, :contentItemTitle, :contentItemUrl)
      .to_h.merge(timestamp: timestamp)
  end

  def validate_params
    params.require(:userId)
    unless AgsService::ACTIVITY_PROGRESS_VALUES.include? params.require(:activityProgress)
      raise InvalidParameterValue, "activityProgress must be one of #{AgsService::ACTIVITY_PROGRESS_VALUES}"
    end
    unless AgsService::GRADING_PROGRESS_VALUES.include? params.require(:gradingProgress)
      raise InvalidParameterValue, "gradingProgress must be one of #{GRADING_PROGRESS_VALUES}"
    end
    validate_scores
  end

  def validate_scores
    score_given = params[:scoreGiven]
    return if score_given.blank?
    raise InvalidParameterValue, "scoreGiven must be greater than or equal to zero" if score_given.to_i.negative?
    raise InvalidParameterValue, "scoreMaximum must be present if scoreGiven set" unless params[:scoreMaximum]
  end

  def timestamp
    Time.zone.now.iso8601(3)
  end
end
