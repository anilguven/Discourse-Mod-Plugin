# plugin.rb
# frozen_string_literal: true

Plugin::Metadata.new do
  name        "Discourse Mod Plugin"
  version     "0.1"
  author      "Anil Guven"
  url         "https://github.com/anilguven"
  about       "This if for moderator permissions."
  version     "1.0.0"
  required_version "2.7.0"
end

# SiteSetting ekranı
SiteSetting.defaults[:custom_permissions_groups] = ''
SiteSetting.defaults[:custom_unapproved_post_viewers_groups] = ''

after_initialize do
  module ::GuardianExtensions
    def can_edit_post?(post)
      group_names = SiteSetting.custom_permissions_groups.split('|')
      return true if user && group_names.any? { |name| user.groups.where(name: name).exists? }
      super(post)
    end

    def can_delete_post?(post)
      group_names = SiteSetting.custom_permissions_groups.split('|')
      return true if user && group_names.any? { |name| user.groups.where(name: name).exists? }
      super(post)
    end

    def can_delete_user?(deletee)
      group_names = SiteSetting.custom_permissions_groups.split('|')
      return true if user && group_names.any? { |name| user.groups.where(name: name).exists? }
      super(deletee)
    end

    def can_see_topic?(topic)
      return true if user && topic.category && can_see_unapproved_posts_in_category?(topic.category)
      super(topic)
    end

    def can_see_unapproved_posts_in_category?(category)
      group_names = SiteSetting.custom_unapproved_post_viewers_groups.split('|')
      group_names.any? { |name| user.groups.where(name: name).exists? }
    end

    def can_approve?(post)
      return true if user && post.topic.category && can_see_unapproved_posts_in_category?(post.topic.category)
      super(post)
    end

    # diğer metodlar...
  end

  require_dependency 'guardian'
  class ::Guardian
    prepend GuardianExtensions
  end
end
