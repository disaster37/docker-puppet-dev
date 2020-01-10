FROM centos:7

MAINTAINER Sebastien LANGOUREAUX <sebastien.langoureaux@sihm.fr>

ARG http_proxy
ARG https_proxy

ENV PUPPET_VERSION=5.5.16 \
    LANG=C.UTF-8 \
    PATH=$PATH:/opt/puppetlabs/puppet/bin

    
# Install ruby and require for beaker and puppet
RUN \
    rpm -Uvh https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm &&\
    yum install -y make gcc-c++ libxml2 libxml2-devel libxslt-devel zlib-devel pdk git puppet-agent-${PUPPET_VERSION} &&\
    yum clean all


# Install ruby lib
RUN /opt/puppetlabs/puppet/bin/gem install rspec
RUN /opt/puppetlabs/puppet/bin/gem install rspec-puppet
#RUN /opt/puppetlabs/puppet/bin/gem install rspec-puppet-facts
RUN /opt/puppetlabs/puppet/bin/gem install puppetlabs_spec_helper
RUN /opt/puppetlabs/puppet/bin/gem install puppet-lint
RUN /opt/puppetlabs/puppet/bin/gem install r10k

# Install beaker
RUN /opt/puppetlabs/puppet/bin/gem install nokogiri -- --use-system-libraries=true --with-xml2-include=/usr/include/libxml2
RUN /opt/puppetlabs/puppet/bin/gem install beaker
RUN /opt/puppetlabs/puppet/bin/gem install beaker-puppet
RUN /opt/puppetlabs/puppet/bin/gem install beaker-puppet_install_helper
RUN /opt/puppetlabs/puppet/bin/gem install beaker-pe
RUN /opt/puppetlabs/puppet/bin/gem install beaker-module_install_helper
RUN /opt/puppetlabs/puppet/bin/gem install beaker-task_helper
RUN /opt/puppetlabs/puppet/bin/gem install beaker-rspec
RUN /opt/puppetlabs/puppet/bin/gem install beaker-docker

RUN /opt/puppetlabs/puppet/bin/gem install beaker-hiera

# Install Bolt
RUN yum install -y puppet-bolt-1.8.1 &&\
    yum clean all

COPY hiera.yaml /etc/puppetlabs/puppet/hiera.yaml

# Systemd
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;


# Copy patch
COPY patch/module_install_helper.rb /opt/puppetlabs/puppet/lib/ruby/gems/2.4.0/gems/beaker-module_install_helper-0.1.7/lib/beaker/module_install_helper.rb

# Create dev user
RUN useradd -G wheel -m dev

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]


