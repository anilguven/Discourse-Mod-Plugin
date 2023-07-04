# plugin.rb
# frozen_string_literal: true

Plugin::Metadata.new do |metadata|
  metadata.name        = "Discourse Mod Plugin"
  metadata.version     = "0.1"
  metadata.author      = "Anil Guven"
  metadata.url         = "https://github.com/anilguven"
  metadata.about       = "This is for moderator permissions."
end

after_initialize do
  Discourse::SiteSetting.define_setting(:custom_permissions_groups, 'group1|group2', type: :string, allow_user_override: true)
  Discourse::SiteSetting.define_setting(:custom_unapproved_post_viewers_groups, 'group3|group4', type: :string, allow_user_override: true)

  module ::GuardianExtensions
    def can_edit_post?(post)
      custom_group_check || super(post)
    end

    def can_delete_post?(post)
      custom_group_check || super(post)
    end

    def can_see_topic?(topic)
      user && topic.category && can_see_unapproved_posts_in_category?(topic.category) || super(topic)
    end

    def can_approve?(post)
      user && post.topic.category && can_see_unapproved_posts_in_category?(post.topic.category) || super(post)
    end

    def can_pin?(topic)
      custom_group_check || super(topic)
    end

    def can_unpin?(topic)
      custom_group_check || super(topic)
    end

    def can_close_topic?(topic)
      custom_group_check || super(topic)
    end

    def can_archive_topic?(topic)
      custom_group_check || super(topic)
    end

    def can_unlist_topic?(topic)
      custom_group_check || super(topic)
    end

    def can_split_merge_topic?(topic)
      custom_group_check || super(topic)
    end

    def can_view_flags?
      custom_group_check || super()
    end

    private

    def custom_group_check
      group_names = SiteSetting.custom_permissions_groups.split('|')
      user && group_names.any? { |name| user.groups.where(name: name).exists? }
    end

    def can_see_unapproved_posts_in_category?(category)
      group_names = SiteSetting.custom_unapproved_post_viewers_groups.split('|')
      group_names.any? { |name| user.groups.where(name: name).exists? }
    end

    # other methods...
  end

  require_dependency 'guardian'
  class ::Guardian
    prepend GuardianExtensions
  end
end
