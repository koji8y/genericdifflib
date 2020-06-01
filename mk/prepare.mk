ifndef python3
python3=python3
endif
pip3=${python3} -m pip $${http_proxy:+--proxy $${http_proxy}}
