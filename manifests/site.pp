# This document serves as an example of how to deploy
# basic multi-node openstack environments.
# In this scenario Quantum is using OVS with GRE Tunnels
# Swift is not included.

# Switch this to false after your first run to prevent unsafe operations
# from potentially running again
$initial_setup           = true

########### Proxy Configuration ##########
# If you use an HTTP/HTTPS proxy, point this at its URL.
#$proxy			= "http://proxy-rtp-1.cisco.com:8080"
#$proxy	= false
      
########### Build Node (Cobbler, Puppet Master, NTP) ######
$build_node_fqdn        = "build-os.dmz25.lab"

########### NTP Configuration ############
$company_ntp_server	= "192.168.25.1"

########### Cobbler Variables ############
$cobbler_node_ip = '192.168.25.254'
$node_subnet = '192.168.25.0'
$node_netmask = '255.255.255.0'
$node_gateway = '192.168.25.1'
$dhcp_ip_low = '192.168.25.120'
$dhcp_ip_high = '192.168.25.127'
$domain_name = 'dmz25.lab'
$cobbler_proxy = "http://${cobbler_node_ip}:3142/"

####### Preseed File Configuration #######
# This will build a preseed file called 'cisco-preseed' in /etc/cobbler/preseeds/
# The following variables may be changed by the system admin:
# 1) admin_user
# 2) password_crypted
# Default user is: localadmin
# An example MD5 crypted password is "ubuntu": $6$UfgWxrIv$k4KfzAEMqMg.fppmSOTd0usI4j6gfjs0962.JXsoJRWa5wMz8yQk4SfInn4.WZ3L/MCt5u.62tHDGB36EhiKF1
$admin_user = "localadmin"
$password_crypted = '$6$5NP1.NbW$WOXi0W1eXf9GOc0uThT5pBNZHqDH9JNczVjt9nzFsH7IkJdkUpLeuvBU.Zs9x3P6LBGKQh6b0zuR8XSlmcuGn.'
$node_boot_disk = '/dev/sda'

### Advanced Users Configuration ###
$node_dns = "${cobbler_node_ip}"
$ip = "${cobbler_node_ip}"
$dns_service = "dnsmasq"
$dhcp_service = "dnsmasq"


########### OpenStack Variables ############
# The address services will attempt to connect to the controller with
$controller_node_address       = '192.168.25.10'
$controller_node_network       = '192.168.25.0'
$controller_hostname           = 'control'
$controller_node_public        = $controller_node_address
$controller_node_internal      = $controller_node_address

$multi_host		= true

# Assumes that eth0 is the public interface
# This is also node as the Management Interface
$public_interface        = 'eth0'
$external_interface	 = 'eth1'
$private_interface       = 'eth0.24'

# OpenStack Services Credentials
$admin_email             = 'root@localhost'
$admin_password          = 'Cisco123'
$keystone_db_password    = 'keystone_db_pass'
$keystone_admin_token    = 'keystone_admin_token'
$nova_user		 = 'nova'
$nova_db_password        = 'nova_pass'
$nova_user_password      = 'nova_pass'
$glance_db_password      = 'glance_pass'
$glance_user_password    = 'glance_pass'
$glance_on_swift         = false
$rabbit_password         = 'openstack_rabbit_password'
$rabbit_user             = 'openstack_rabbit_user'
#$fixed_network_range     = '10.0.0.0/24'
$floating_ip_range       = '192.168.25.128/25'
# Nova DB connection
$sql_connection = "mysql://${nova_user}:${nova_db_password}@${controller_node_address}/nova"
# Switch this to true to have all service log at verbose
$verbose                 = false
# by default it does not enable atomatically adding floating IPs
$auto_assign_floating_ip = false
#### end shared variables #################

####### Adding Core Configuration and Cobbler Nodes Definition #####
import 'cobbler-node'
import 'core'
