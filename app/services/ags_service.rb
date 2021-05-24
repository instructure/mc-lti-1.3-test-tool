# frozen_string_literal: true

class AgsService
  ACTIVITY_PROGRESS_VALUES = %w[Initialized Started InProgress Submitted Completed].freeze
  GRADING_PROGRESS_VALUES = %w[FullyGraded Pending PendingManual Failed NotReady].freeze
  SUBMISSION_TYPE_VALUES = %w[none external_tool].freeze
  SUBMISSION_SCORE_TYPE_VALUES = %w[none basic_lti_launch online_text_entry online_url].freeze

  # Extensions
  AGS_EXT_SUBMISSION_TYPE = "https://canvas.instructure.com/lti/submission_type"
  AGS_EXT_SUBMISSION = "https://canvas.instructure.com/lti/submission"

  def initialize(url, access_token)
    @url = url
    @access_token = access_token
  end

  def get(query, id = nil, type = :line_item)
    @response = HTTParty.get(url(id, type), prepare_request.merge(query: compact(query)))
    result
  end

  def update(id, body)
    @response = HTTParty.put(url(id), prepare_request.merge(body: compact(body).to_json))
    result
  end

  def create(body, type = :line_item, id = nil)
    body = setup_submission_type(body) if type == :line_item
    body = setup_submission_score_type(body) if type == :scores
    @response = HTTParty.post(url(id, type), prepare_request.merge(body: compact(body).to_json))
    result
  end

  def destroy(id)
    @response = HTTParty.delete(url(id), prepare_request)
    result
  end

  def success?
    @response&.success?
  end

  private

  attr_reader :access_token

  def url(id = nil, type = :line_item)
    case type
    when :line_item
      base_url(id)
    when :scores
      "#{base_url(id)}/scores"
    when :results
      "#{base_url(id)}/results"
    when :progress
      # looks like canvas/courses/1/progress/1
      base_url(id).gsub(/line_items/, "progress")
    else
      raise 'Unrecognized request type'
    end
  end

  def base_url(id)
    id.nil? ? @url : "#{@url}/#{id}"
  end

  def prepare_request
    {
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{access_token['access_token']}"
      }
    }
  end

  def result
    success? ? JSON.parse(@response.body.presence || '{"type": "Success"}') : @response.body
  end

  def compact(hsh)
    hsh.delete_if { |_, value| value.blank? }
  end

  # Put submission type information in a sub-hash using ASG_EXT_SUBMISSION_TYPE as key
  def setup_submission_type(body)
    return body unless body.key?("submissionType") && body.key?("externalToolUrl")

    body[AGS_EXT_SUBMISSION_TYPE] = {
      type: body["submissionType"],
      external_tool_url: body["externalToolUrl"]
    }
    body.delete("submissionType")
    body.delete("externalToolUrl")
    body
  end

  def setup_submission_score_type(body)
    return body unless body.key?("submissionScoreType") && body.key?("submissionScoreData")
    body[AGS_EXT_SUBMISSION] = {
      new_submission: bool_from_params(body, "newSubmission"),
      submission_type: body.delete("submissionScoreType"),
      submission_data: body.delete("submissionScoreData")
    }
    body[AGS_EXT_SUBMISSION][:submitted_at] = body.delete("submittedAt") if bool_from_params(body, "sendSubmittedAt")

    content_item = {
      type: "file",
      url: body.delete("contentItemUrl"),
      title: body.delete("contentItemTitle")
    }
    body[AGS_EXT_SUBMISSION][:content_items] = [content_item] if bool_from_params(body, "sendContentItem")

    body
  end

  def bool_from_params(body, key)
    body.delete(key) == "1"
  end
end
