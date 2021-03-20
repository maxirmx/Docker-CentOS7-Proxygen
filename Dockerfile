# ##################################################################################################### #
# This is a script to create CentOS 7 container development with PROXYGEN and dependencies installed    #
# ##################################################################################################### #

FROM centos:7
LABEL mantainer="Maxim [maxirmx] Samsonov <m.samsonov@computer.org>"

# V stands for "version" :)
ENV V_CMAKE=3.19.0
ENV V_BOOST=1.74.0
ENV V_BOOST_=1_74_0
ENV V_PROXIGEN=2020.11.16.00

RUN yum -y update                          \
&&  yum -y install epel-release            \
# The next line is for git 2.x
&&  yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm \
&&  yum -y install centos-release-scl      \
&&  yum -y install devtoolset-8            \
                   double-conversion-devel \
                   jemalloc-devel          \ 
                   glog-devel              \
                   gflags-devel            \
                   snappy-devel            \
                   libevent-devel          \
                   libsodium-devel         \ 
                   gperf                   \
                   libzstd-devel           \  
                   xmlto                   \
                   xz-devel                \
                   bzip2-devel             \ 
                   openssl-devel           \
                   python3                 \
                   wget                    \
                   git                     ; yum clean all   

WORKDIR / 
SHELL [ "scl", "enable", "devtoolset-8"]

RUN mkdir /bootstrap && cd /bootstrap \
&& wget https://github.com/Kitware/CMake/releases/download/v${V_CMAKE}/cmake-${V_CMAKE}.tar.gz -nv -O cmake.tar.gz \ 
&& tar -xzf cmake.tar.gz && cd /bootstrap/cmake-${V_CMAKE} \
&& ./bootstrap --prefix=/usr/local && make -j8 install \
&& cd /bootstrap && rm -rf /bootstrap/cmake-${V_CMAKE} \
&& wget https://dl.bintray.com/boostorg/release/${V_BOOST}/source/boost_${V_BOOST_}.tar.gz -nv -O boost.tar.gz \
&& tar -xzf boost.tar.gz && cd /bootstrap/boost_${V_BOOST_} \
&& ./bootstrap.sh  && ./b2 -j8 -d1 --without-python --prefix=/usr/local install \
&& cd /bootstrap && rm -rf /bootstrap/boost_${V_BOOST_} 

RUN cd /bootstrap \
&& wget https://github.com/facebook/proxygen/archive/v${V_PROXIGEN}.tar.gz -nv -O proxygen.tar.gz \
&& tar -xzf proxygen.tar.gz \
&& cd /bootstrap/proxygen-${V_PROXIGEN}/proxygen/ \
# An ugly patching in operations ...
&& sed s/\-DCMAKE_INSTALL_PREFIX=\"\$DEPS_DIR\"/\-DCMAKE_INSTALL_PREFIX=\"\$PREFIX\"/ < build.sh > b.sh \
&& chmod +x b.sh \
&& ./b.sh -j 4 --prefix /usr/local && ./install.sh \
&& cd /bootstrap && rm -rf /bootstrap 

CMD ["bash"]
