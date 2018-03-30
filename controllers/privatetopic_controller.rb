class ::PrivatetopicController < ::ApplicationController
  def control_access
    topic_id = params[:topic_id]
    access_allowed = params[:access_allowed]

    @topic = Topic.find_by(id: topic_id)
    @topic.custom_fields["topic_restricted_access"] = access_allowed
    @topic.save!
    render json: { success: @topic.custom_fields["topic_restricted_access"] }
  end
end
