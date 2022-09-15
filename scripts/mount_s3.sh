# Using new instance of CentOS or Red Hat.Update the system.
sudo yum update all

# First, we will install all the dependencies for fuse and s3cmd. Install the required packages to system use following command
sudo yum install automake fuse fuse-devel gcc-c++ git libcurl-devel libxml2-devel make openssl-devel -y

# Download s3fs source code from git.
git clone https://github.com/s3fs-fuse/s3fs-fuse.git

# Now Compile and install the code.
cd s3fs-fuse
./autogen.sh
./configure -prefix=/usr -with-openssl
make
sudo make install

# Use the below command to check where the s3fs command is placed in O.S. It will also tell you the installation is ok.
which s3fs

# Create a directory to mount s3 bucket
sudo mkdir /s3bucket

# mount s3 bucket
# sudo s3fs ${BUCKET_NAME} -o iam_role=${IAM_ROLE_NAME} -o use_cache=/tmp -o allow_other -o uid=1000 -o mp_umask=002 -o multireq_max=5 /s3bucket

sudo cat << EOF >> /etc/fstab
s3fs#${BUCKET_NAME} /s3bucket fuse _netdev,iam_role=${IAM_ROLE_NAME},use_cache=/tmp,allow_other,uid=1000 0 0
EOF

sudo mount -a