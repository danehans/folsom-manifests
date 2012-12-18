# This document serves as an example of how to deploy
# basic multi-node openstack environments.
# In this scenario Quantum is using OVS with GRE Tunnels
# Swift is not included.

node base {
    ########### Folsom Release ###############

    # Disable pipelining to avoid unfortunate interactions between apt and
    # upstream network gear that does not properly handle http pipelining
    # See https://bugs.launchpad.net/ubuntu/+source/apt/+bug/996151 for details

    file { '/etc/apt/apt.conf.d/00no_pipelining':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => 'Acquire::http::Pipeline-Depth "0";'
    }

    # Load apt prerequisites.  This is only valid on Ubuntu systmes
    apt::source { "cisco-openstack-mirror_folsom-proposed":
	#location => "ftp://ftpeng.cisco.com/openstack/cisco/",
        location => "http://128.107.252.163/openstack/cisco",
	release => "folsom-proposed",
	repos => "main",
	key => "E8CC67053ED3B199",
	key_content => '-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.11 (GNU/Linux)

mQENBE/oXVkBCACcjAcV7lRGskECEHovgZ6a2robpBroQBW+tJds7B+qn/DslOAN
1hm0UuGQsi8pNzHDE29FMO3yOhmkenDd1V/T6tHNXqhHvf55nL6anlzwMmq3syIS
uqVjeMMXbZ4d+Rh0K/rI4TyRbUiI2DDLP+6wYeh1pTPwrleHm5FXBMDbU/OZ5vKZ
67j99GaARYxHp8W/be8KRSoV9wU1WXr4+GA6K7ENe2A8PT+jH79Sr4kF4uKC3VxD
BF5Z0yaLqr+1V2pHU3AfmybOCmoPYviOqpwj3FQ2PhtObLs+hq7zCviDTX2IxHBb
Q3mGsD8wS9uyZcHN77maAzZlL5G794DEr1NLABEBAAG0NU9wZW5TdGFja0BDaXNj
byBBUFQgcmVwbyA8b3BlbnN0YWNrLWJ1aWxkZEBjaXNjby5jb20+iQE4BBMBAgAi
BQJP6F1ZAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRDozGcFPtOxmXcK
B/9WvQrBwxmIMV2M+VMBhQqtipvJeDX2Uv34Ytpsg2jldl0TS8XheGlUNZ5djxDy
u3X0hKwRLeOppV09GVO3wGizNCV1EJjqQbCMkq6VSJjD1B/6Tg+3M/XmNaKHK3Op
zSi+35OQ6xXc38DUOrigaCZUU40nGQeYUMRYzI+d3pPlNd0+nLndrE4rNNFB91dM
BTeoyQMWd6tpTwz5MAi+I11tCIQAPCSG1qR52R3bog/0PlJzilxjkdShl1Cj0RmX
7bHIMD66uC1FKCpbRaiPR8XmTPLv29ZTk1ABBzoynZyFDfliRwQi6TS20TuEj+ZH
xq/T6MM6+rpdBVz62ek6/KBcuQENBE/oXVkBCACgzyyGvvHLx7g/Rpys1WdevYMH
THBS24RMaDHqg7H7xe0fFzmiblWjV8V4Yy+heLLV5nTYBQLS43MFvFbnFvB3ygDI
IdVjLVDXcPfcp+Np2PE8cJuDEE4seGU26UoJ2pPK/IHbnmGWYwXJBbik9YepD61c
NJ5XMzMYI5z9/YNupeJoy8/8uxdxI/B66PL9QN8wKBk5js2OX8TtEjmEZSrZrIuM
rVVXRU/1m732lhIyVVws4StRkpG+D15Dp98yDGjbCRREzZPeKHpvO/Uhn23hVyHe
PIc+bu1mXMQ+N/3UjXtfUg27hmmgBDAjxUeSb1moFpeqLys2AAY+yXiHDv57ABEB
AAGJAR8EGAECAAkFAk/oXVkCGwwACgkQ6MxnBT7TsZng+AgAnFogD90f3ByTVlNp
Sb+HHd/cPqZ83RB9XUxRRnkIQmOozUjw8nq8I8eTT4t0Sa8G9q1fl14tXIJ9szzz
BUIYyda/RYZszL9rHhucSfFIkpnp7ddfE9NDlnZUvavnnyRsWpIZa6hJq8hQEp92
IQBF6R7wOws0A0oUmME25Rzam9qVbywOh9ZQvzYPpFaEmmjpCRDxJLB1DYu8lnC4
h1jP1GXFUIQDbcznrR2MQDy5fNt678HcIqMwVp2CJz/2jrZlbSKfMckdpbiWNns/
xKyLYs5m34d4a0it6wsMem3YCefSYBjyLGSd/kCI/CgOdGN1ZY1HSdLmmjiDkQPQ
UcXHbA==
=v6jg
-----END PGP PUBLIC KEY BLOCK-----',
	proxy => $::proxy,
    }


    # /etc/hosts entries for the controller nodes
    host { $::controller_hostname:
	ip => $::controller_node_internal
    }

#    class { 'collectd':
#        graphitehost		=> $::build_node_fqdn,
#	management_interface	=> $::public_interface,
#    }
}

node os_base inherits base {

    class { ntp:
	servers		=> [$::build_node_fqdn],
	ensure 		=> running,
	autoupdate 	=> true,
    }

    # Deploy a script that can be used to test nova
    class { 'openstack::test_file': }

    class { 'openstack::auth_file':
	admin_password       => $admin_password,
	keystone_admin_token => $keystone_admin_token,
	controller_node      => $controller_node_internal,
    }

}

node control inherits "os_base" {

    class { 'openstack::controller':
	public_address          => $controller_node_public,
	public_interface        => $public_interface,
	private_interface       => $private_interface,
	internal_address        => $controller_node_internal,
	floating_range          => $floating_ip_range,
	fixed_range             => $fixed_network_range,
	multi_host              => $multi_host,
	verbose                 => $verbose,
	auto_assign_floating_ip => $auto_assign_floating_ip,
	mysql_root_password     => $mysql_root_password,
	admin_email             => $admin_email,
	admin_password          => $admin_password,
	keystone_db_password    => $keystone_db_password,
	keystone_admin_token    => $keystone_admin_token,
	glance_db_password      => $glance_db_password,
	glance_user_password    => $glance_user_password,
        glance_sql_connection   => $glance_sql_connection,
        glance_on_swift         => $glance_on_swift,
	nova_db_password        => $nova_db_password,
	nova_user_password      => $nova_user_password,
	rabbit_password         => $rabbit_password,
	rabbit_user             => $rabbit_user,
	export_resources        => false,
	quantum_db_password     => $quantum_db_password,
        ovs_bridge_uplinks      => ["br-ex:${external_interface}"],
	quantum_rabbit_host     => $controller_node_internal, 
    }
}


node compute inherits "os_base" {

    class { 'openstack::compute':
	public_interface        => $public_interface,
	private_interface       => $private_interface,
	internal_address        => $ipaddress_eth0,
	libvirt_type            => 'kvm',
	fixed_range             => $fixed_network_range,
	network_manager         => 'nova.network.quantum.manager.QuantumManager',
	multi_host              => $multi_host,
	sql_connection          => $sql_connection,
	nova_user_password      => $nova_user_password,
	auth_host	        => $controller_node_internal,
        rabbit_host             => $controller_node_internal,
	rabbit_password         => $rabbit_password,
	rabbit_user             => $rabbit_user,
	glance_api_servers      => "${controller_node_internal}:9292",
	vncproxy_host           => $controller_node_public,
	vnc_enabled             => 'true',
	verbose                 => $verbose,
	manage_volumes          => true,
	nova_volume             => 'nova-volumes',
	quantum_url             => "http://${controller_node_internal}:9696",
        quantum_admin_auth_url  => "http://${controller_node_internal}:35357/v2.0",
        quantum_rabbit_host     => $controller_node_internal,
        ovs_sql_connection      => "mysql://quantum:${quantum_db_password}@${controller_node_internal}/quantum",
    }
}

########### Definition of the Build Node #######################
#
# Definition of this node should match the name assigned to the build node in your deployment.
# In this example we are using build-node, you dont need to use the FQDN. 
#
node master-node inherits "cobbler-node" {

    # Change the servers for your NTP environment
    # (Must be a reachable NTP Server by your build-node, i.e. ntp.esl.cisco.com)
    class { ntp:
	servers 	=> [$::company_ntp_server],
	ensure 		=> running,
	autoupdate 	=> true,
    }

#    class { 'nagios':
#    }

#    class { 'graphite': 
#	graphitehost 	=> $::build_node_fqdn,
#    }

    # set up a local apt cache.  Eventually this may become a local mirror/repo instead
    class { apt-cacher-ng: 
  	proxy 		=> $::proxy,
    }

    # set the right local puppet environment up.  This builds puppetmaster with storedconfigs (a nd a local mysql instance)
    class { puppet:
	run_master 		=> true,
	puppetmaster_address 	=> $build_node_fqdn, 
	certname 		=> $build_node_fqdn,
	mysql_password 		=> 'ubuntu',
    }<-

    file {'/etc/puppet/files':
	ensure => directory,
	owner => 'root',
	group => 'root',
	mode => '0755',
    }

    file {'/etc/puppet/fileserver.conf':
	ensure => file,
	owner => 'root',
	group => 'root',
	mode => '0644',
	content => '

# This file consists of arbitrarily named sections/modules
# defining where files are served from and to whom

# Define a section "files"
# Adapt the allow/deny settings to your needs. Order
# for allow/deny does not matter, allow always takes precedence
# over deny
[files]
  path /etc/puppet/files
  allow *
#  allow *.example.com
#  deny *.evil.example.com
#  allow 192.168.0.0/24

[plugins]
#  allow *.example.com
#  deny *.evil.example.com
#  allow 192.168.0.0/24
',
    }
}

