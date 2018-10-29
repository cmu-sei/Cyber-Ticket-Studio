##########################
# RHEL:
sudo yum install libcurl-devel
sudo yum install openssl-devel
sudo yum install ImageMagick-c++-devel
# #x11:
# https://stackoverflow.com/a/41189797/2232265
# https://stackoverflow.com/a/33512942/2232265
sudo yum groupinstall "X Window System" # says Kodiak