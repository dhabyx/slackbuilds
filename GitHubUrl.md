# How-to proper download tarball release files from GitHub

Pick up from SBo mail list.
Wrote by David Spencer

We start at the homepage on GitHub:
`https://github.com/ib/xarchiver`
The username here is 'ib'
The project name here is 'xarchiver'

We look at the 'releases' page from the link that says '32 releases'
`https://github.com/ib/xarchiver/releases`
This is actually a list of git tags. The one we want is '0.5.4.7'

The long-format download URL is
`https://github.com/<username>/<project>/archive/<tag>/<project>-<tag>.tar.gz`
in this case:
`https://github.com/ib/xarchiver/archive/0.5.4.7/xarchiver-0.5.4.7.tar.gz`

Inside the tarball, the top level directory will always be
`<project>-<tag>/`

This is true even if the tag starts with the project name, for example
previously xarchiver was like this:
`https://github.com/ib/xarchiver/archive/xarchiver-0.5.4.7/xarchiver-xarchiver-0.5.4.7.tar.gz`

**Exception** if the tag starts with 'v', the tarball name and top
level directory does *not* start with 'v', for example
`https://github.com/kparal/sendKindle/archive/v2.1/sendKindle-2.1.tar.gz`
