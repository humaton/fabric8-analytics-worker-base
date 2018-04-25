FROM registry.centos.org/centos/centos:7

ENV LANG=en_US.UTF-8 \
    JAVANCSS_PATH='/opt/javancss/' \
    OWASP_DEP_CHECK_PATH='/opt/dependency-check/' \
    OWASP_DEP_CHECK_SUPPRESS_PATH='/opt/dependency-check/suppress/' \
    SCANCODE_PATH='/opt/scancode-toolkit/'

# https://copr.fedorainfracloud.org/coprs/jpopelka/mercator/
# https://copr.fedorainfracloud.org/coprs/fche/pcp/
COPY hack/_copr_jpopelka-mercator.repo hack/_copr_fche_pcp.repo /etc/yum.repos.d/

# Install RPM dependencies
COPY hack/install_deps_rpm.sh /tmp/install_deps/
RUN yum install -y epel-release && \
    /tmp/install_deps/install_deps_rpm.sh && \
    yum clean all

# Work-arounds & hacks:
# 'pip install --upgrade wheel': http://stackoverflow.com/questions/14296531
RUN pip3 install --upgrade 'pip>=10.0.0' && pip install --upgrade wheel && \
    pip3 install alembic psycopg2

# Install javascript deps
COPY hack/install_deps_npm.sh /tmp/install_deps/
RUN /tmp/install_deps/install_deps_npm.sh

# Install binwalk, the pip package is broken, following docs from github.com/devttys0/binwalk
#RUN mkdir /tmp/binwalk/ && \
#    curl -L https://github.com/devttys0/binwalk/archive/v2.1.1.tar.gz | tar xz -C /tmp/binwalk/ --strip-components 1 && \
#    python /tmp/binwalk/setup.py install && \
#    rm -rf /tmp/binwalk/

# Languages scanner
# RUN gem install --no-document github-linguist

# Install JavaNCSS for code metrics
#COPY hack/install_javancss.sh /tmp/install_deps/
#RUN /tmp/install_deps/install_javancss.sh

# Install OWASP dependency-check cli for security scan of jar files
COPY hack/install_owasp_dependency-check.sh /tmp/install_deps/
RUN /tmp/install_deps/install_owasp_dependency-check.sh
COPY hack/suppressions.xml ${OWASP_DEP_CHECK_SUPPRESS_PATH}

# Install ScanCode-toolkit for license scan
COPY hack/install_scancode.sh /tmp/install_deps/
RUN /tmp/install_deps/install_scancode.sh

# Install dependencies required in both Python 2 and 3 versions
COPY ./hack/py23requirements.txt /tmp/install_deps/
RUN pip2 install -r /tmp/install_deps/py23requirements.txt
RUN pip3 install -r /tmp/install_deps/py23requirements.txt

# Install gofedlib needed for Go support
RUN pip2 install --egg git+https://github.com/gofed/gofedlib.git@18e0ce72d2c7bcbe3b19c20378f602633292eedf

# Create & set pcp dirs
RUN mkdir -p /etc/pcp /var/run/pcp /var/lib/pcp /var/log/pcp  && \
    chgrp -R root /etc/pcp /var/run/pcp /var/lib/pcp /var/log/pcp && \
    chmod -R g+rwX /etc/pcp /var/run/pcp /var/lib/pcp /var/log/pcp

# Not-yet-upstream-released patches
COPY hack/patches/* /tmp/install_deps/patches/
# Apply patches here to be able to patch selinon as well
RUN /tmp/install_deps/patches/apply_patches.sh
