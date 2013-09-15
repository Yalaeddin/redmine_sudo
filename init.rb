require 'redmine'
require 'redmine_sudo/hooks'

# Little hack for deface in redmine:
# - redmine plugins are not railties nor engines, so deface overrides are not detected automatically
# - deface doesn't support direct loading anymore ; it unloads everything at boot so that reload in dev works
# - hack consists in adding "app/overrides" path of the plugin in Redmine's main #paths
Rails.application.paths["app/overrides"] ||= []
Rails.application.paths["app/overrides"] << File.expand_path("../app/overrides", __FILE__)

# Patches to existing classes/modules
ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine_sudo/user_patch'
end

# Ensure we don't run on a broken version of libxml with deface < 1.0
# TODO: remove it when we upgrade deface with this patch merged: https://github.com/spree/deface/commit/415422f73e43d757f2d524a8b2b8960ca09f621c
if Nokogiri.uses_libxml? && Nokogiri::LIBXML_VERSION.match(/^2.9/)
  raise "You cannot use libxml2 v2.9 with deface for now, see https://github.com/spree/deface/commit/415422f73e43d757f2d524a8b2b8960ca09f621c"
end

# Plugin generic informations
Redmine::Plugin.register :redmine_sudo do
  name 'Redmine Sudo plugin'
  description 'This plugin gives sudo-like powers to Redmine administrators'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  url 'https://github.com/jbbarth/redmine_sudo'
  version '0.0.1'
  requires_redmine :version_or_higher => '2.1.0'
  settings :default => {
    'become_admin' => '[sudo -v]',
    'become_user' => '[sudo -k]',
    'additional_css' => "#top-menu { background-color:#BA0C03; }\n#header { background-color:#dd0037; }\n#main-menu li a { background-color:#BA0C03; }\n#main-menu li a:hover { background-color:#8D0A02; }",
  }, :partial => 'settings/redmine_sudo_settings'
end
