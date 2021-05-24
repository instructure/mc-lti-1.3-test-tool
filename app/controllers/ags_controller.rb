# frozen_string_literal: true

class AgsController < ApplicationController
  def new
    @activity_progress = AgsService::ACTIVITY_PROGRESS_VALUES
    @grading_progress = AgsService::GRADING_PROGRESS_VALUES
    @submission_types = AgsService::SUBMISSION_TYPE_VALUES
    @submission_score_types = AgsService::SUBMISSION_SCORE_TYPE_VALUES
  end
end
