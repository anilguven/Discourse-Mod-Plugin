# plugin.rb
# frozen_string_literal: true

Plugin::Metadata.new do
  name        "Discourse Mod Plugin"
  version     "0.1"
  author      "Anil Guven"
  url         "https://github.com/anilguven"
  about       "This is for moderator permissions."
  version     "1.0.0"
  required_version "2.7.0"
end

after_initialize do
Discourse::SiteSetting.define_setting(:custom_permissions_groups, 'group1|group2', type: :string, allow_user_override: true)
Discourse::SiteSetting.define_setting(:custom_unapproved_post_viewers_groups, 'group3|group4', type: :string, allow_user_override: true)

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

    def can_pin?(topic)
      group_names = SiteSetting.custom_permissions_groups.split('|')
      return true if user && group_names.any? { |name| user.groups.where(name: name).exists? }
      super(topic)
    end

    def can_unpin?(topic)
      group_names = SiteSetting.custom_permissions_groups.split('|')
      return true if user && group_names.any? { |name| user.groups.where(name: name).exists? }
      super(topic)
    end

    def can_close_topic?(topic)
      group_names = SiteSetting.custom_permissions_groups.split('|')
      return true if user && group_names.any? { |name| user.groups.where(name: name).exists? }
      super(topic)
    end

    def can_archive_topic?(topic)
      group_names = SiteSetting.custom_permissions_groups.split('|')
      return true if user && group_names.any? { |name| user.groups.where(name: name).exists? }
      super(topic)
    end

    def can_unlist_topic?(topic)
      group_names = SiteSetting.custom_permissions_groups.split('|')
      return true if user && group_names.any? { |name| user.groups.where(name: name).exists? }
      super(topic)
    end

    def can_split_merge_topic?(topic)
      group_names = SiteSetting.custom_permissions_groups.split('|')
      return true if user && group_names.any? { |name| user.groups.where(name: name).exists? }
      super(topic)
    end

    def can_view_flags?
      group_names = SiteSetting.custom_permissions_groups.split('|')
      return true if user && group_names.any? { |name| user.groups.where(name: name).exists? }
      super()
    end

    # diğer metodlar...
  end

  require_dependency 'guardian'
  class ::Guardian
    prepend GuardianExtensions
  end
end
