##############
#  Defaults  #
##############
# All of the settings below should be left as-is
OPERATING_SYSTEM = "LINUX" unless defined? OPERATING_SYSTEM
PT_VERSION = "856" unless defined? PT_VERSION
FQDN = 'psvagabond' unless defined? FQDN
DPK_VERSION = PATCH_ID unless defined? DPK_VERSION
DPK_LOCAL_DIR = "dpk/download" unless defined? DPK_LOCAL_DIR
# NOTE: The pum setup script for linux will fail unless the DPK_REMOTE_DIR (DPK
#       installation directory) is mounted under "/media/sf_*".
DPK_REMOTE_DIR_LNX = "/media/sf_#{DPK_VERSION}" unless defined? DPK_REMOTE_DIR
DPK_REMOTE_DIR_WIN = "C:/psft/dpk/download/#{DPK_VERSION}" unless defined? DPK_REMOTE_DIR
NETWORK_SETTINGS = { :type => "hostonly", :host_http_port => "8000", :guest_http_port => "8000", :host_listener_port => "1522", :guest_listener_port => "1522", :host_rdp_port => "33389", :guest_rdp_port => "3389"} unless defined? NETWORK_SETTINGS

DPK_BOOTSTRAP = 'true' unless defined? DPK_BOOTSTRAP
PUPPET_APPLY = 'true' unless defined? PUPPET_APPLY
CA_SETTINGS = { :setup => false, :path => '', :type => '', :backup => '' } unless defined? CA_SETTINGS
PTF_SETUP = 'false' unless defined? PTF_SETUP
APPLY_PT_PATCH = 'false' unless defined? APPLY_PT_PATCH
DPK_ROLE = '' unless defined? DPK_ROLE
IE_HOMEPAGE = 'http://localhost:8000/ps/signon.html' unless defined? IE_HOMEPAGE

if OPERATING_SYSTEM.upcase == "WINDOWS"
  PUPPET_HOME = "C:/ProgramData/PuppetLabs/puppet/etc" unless defined? PUPPET_HOME
elsif OPERATING_SYSTEM == "LINUX"
  PUPPET_HOME = "/etc/puppet" unless defined? PUPPET_HOME
else
  raise Vagrant::Errors::VagrantError.new, "Operating System #{OPERATING_SYSTEM} is not supported"
end
