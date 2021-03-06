This is [Cntlm](http://cntlm.sourceforge.net/) **with Kerberos patch applied**.

Works on a Ubuntu 12.04 box, at least for me.

Dependency: [Kerberos](http://web.mit.edu/kerberos/).

If Kerberos is compiled to a different location, say, $HOME/usr, compile Cntlm with

`./configure --enable-kerberos`

`export LIBRARY_PATH=$HOME/usr/lib`

`export C_INCLUDE_PATH=$HOME/usr/include`

`make`

To run it, try `cntlm --help` or `cntlm -v` and fix whatever it complains.

I have only the following lines in my ctnlm.conf file:

```
Username	
Domain		
Password	
Proxy		proxy.server.domain.com:3128
NoProxy		localhost, 127.0.0.*, 10.*, 192.168.*
Listen		3128
```

The username, domain and password are all unset.

I could start it with `/home/me/usr/opt/cntlm-0.92.3/cntlm -a gss -c /home/me/usr/opt/cntlm-0.92.3/cntlm.conf` .

# Docker image

To access Kerberos credential cache from docker container it needs to be of
type `FILE`. Either set the default in `/etc/krb5.conf` using
`default_ccache_name` variable in `[libdefaults]` section, or set it using
`KRBCCNAME` env var before issuing `kinit`:

```
export KRB5CCNAME=FILE:/tmp/krb5cc_`id -u`
```

You can run docker image as follows (don't forget to add yourself to the
`docker` group):

```
docker run -d --restart=unless-stopped --network=host -v $HOME/.cntlm.conf:/etc/cntlm.conf:ro -v /tmp:/tmp:ro -u `id -u`:`id -g` --name cntlm-gss lorf/cntlm-gss
```

To show documentatoin use

```
docker run --rm -it lorf/cntlm-gss man cntlm
```

To show sample config file use

```
docker run --rm -i lorf/cntlm-gss cat /etc/cntlm.conf
```
