# name: private-topics
# about: Searchable private category topics
# version: 0.1
# authors: Jordan Seanor
# url: https://github.com/HMSAB/discourse-private-topic.git

enabled_site_setting :private_topics_enabled


register_asset("stylesheets/privatetopics.scss", :desktop)

after_initialize do
  load File.expand_path("../controllers/privatetopic_controller.rb", __FILE__)

  Discourse::Application.routes.prepend do
    post 'privatetopic/control_access' => 'privatetopic#control_access'
  end

  Topic.register_custom_field_type('topic_restricted_access', :boolean)
  add_to_serializer(:topic_view, :custom_fields, false) {object.topic.custom_fields}

  module ::TopicLocked
    def self.access_restricted(guardian, topic, user)
      if !user.nil?
        return false if guardian.is_admin? || guardian.is_moderator? || guardian.is_staff? || user.id == topic.user_id 
      end
      if SiteSetting.hms_phone_tracking_enabled
        if !topic.custom_fields["phone_survey_recipient"].nil? && !user.nil?
          surveyUserId = User.find_by(username: topic.custom_fields["phone_survey_recipient"]).id
          if user.id.to_i == surveyUserId.to_i
            return false
          end
        end
      end
      if !guardian.can_see?(topic)
        raise ::TopicLocked::NoAccessLocked.new
      end
      if topic.archetype == "private_message"
          if !topic.allowed_users.include?(user)
            raise ::TopicLocked::NoAccessLocked.new
          end
        end
        if topic.custom_fields["topic_restricted_access"] && !user.nil?
          if user.id != topic.user_id
            return true
          end
        end
      else
        return true if topic.archetype == "private_message" && user.nil?
        return true if topic.custom_fields["topic_restricted_access"] && user.nil?
      end

    class NoAccessLocked < StandardError; end
  end

  require_dependency 'topic_view'
  class ::TopicView
    alias_method :old_check_and_raise_exceptions, :check_and_raise_exceptions

    def check_and_raise_exceptions
      if SiteSetting.private_topics_enabled
        raise ::TopicLocked::NoAccessLocked.new if TopicLocked.access_restricted(@guardian, @topic, @user)
      end
    end
  end

  require_dependency 'application_controller'
  class ::ApplicationController
    rescue_from ::TopicLocked::NoAccessLocked do
      rescue_discourse_actions(:invalid_access, 403, include_ember: true)
    end
  end
end
