(new-object net.webclient).downloadfile('http://python-distribute.org/distribute_setup.py', "$pwd\distribute_setup.py")
python .\distribute_setup.py
(new-object net.webclient).downloadfile('https://raw.github.com/pypa/pip/master/contrib/get-pip.py', "$pwd\get-pip.py")
python .\get-pip.py
rm distribute-*.gz
rm distribute_setup.py
rm get-pip.py