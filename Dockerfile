FROM centos:7

MAINTAINER Sebastien LANGOUREAUX <sebastien.langoureaux@sihm.fr>

ARG http_proxy
ARG https_proxy

ENV PUPPET_VERSION=5.3.7 \
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
RUN /opt/puppetlabs/puppet/bin/gem install beaker -v 4.0.0
RUN /opt/puppetlabs/puppet/bin/gem install beaker-puppet -v 1.1.0
RUN /opt/puppetlabs/puppet/bin/gem install beaker-puppet_install_helper -v 0.9.7
RUN /opt/puppetlabs/puppet/bin/gem install beaker-pe -v 2.0.6
RUN /opt/puppetlabs/puppet/bin/gem install beaker-module_install_helper -v 0.1.7
RUN /opt/puppetlabs/puppet/bin/gem install beaker-task_helper -v 1.7.2
RUN /opt/puppetlabs/puppet/bin/gem install beaker-rspec -v 6.2.4
RUN /opt/puppetlabs/puppet/bin/gem install beaker-docker -v 0.5.1

RUN /opt/puppetlabs/puppet/bin/gem install beaker-hiera -v 0.1.1

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

# Create dev user
RUN useradd -G wheel -m dev

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]


