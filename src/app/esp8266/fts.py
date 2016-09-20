#!/usr/bin/python
import socket
import sys

verbs = {}

def fts_put():
    name = sys.argv[4]
    data = file(name, 'r').read()
    sock.send('put %s' % name)
    sock.send(data)
    print >>sys.stderr, 'size = %d' % len(data)

verbs['put'] = fts_put

def fts_get():
    name = sys.argv[4]
    sock.send('get %s' % name)
    data = sock.recv(256 * 1024)
    file(name, 'w').write(data)  # FIXME: clobbers file
    print >>sys.stderr, 'size = %d' % len(data)

verbs['get'] = fts_get

def fts_show():
    name = sys.argv[4]
    sock.send('get %s' % name)

    data = ''
    while True:
        chunk = sock.recv(256 * 1024)
        if chunk == '':
            break
        data += chunk
    print data,

verbs['show'] = fts_show
verbs['cat'] = fts_show

def fts_list():
    sock.send('list')
    response = sock.recv(256 * 1024)
    for line in response.split('\n'):
        if line != '':
            print line

verbs['list'] = fts_list
verbs['ls'] = fts_list
verbs['dir'] = fts_list

def fts_remove():
    name = sys.argv[4]
    sock.send('remove %s' % name)

verbs['remove'] = fts_remove
verbs['rm'] = fts_remove
verbs['del'] = fts_remove

def fts_restart():
    sock.send('restart')

verbs['restart'] = fts_restart


def usage():
    print """Usage:
        fts IP PORT put NAME            upload file to remote
        fts IP PORT get NAME            download file from remote (clobbers)
        fts IP PORT show NAME           download file from remote to stdout
        fts IP PORT list                list files
        fts IP PORT remove NAME         delete file on remote
        fts IP PORT restart             restart remote"""

verb = sys.argv[3]
if verb not in verbs:
    print >>sys.stderr, "unknown command"
    usage()
    exit(-1)

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect((sys.argv[1], int(sys.argv[2])))
sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)

verbs[verb]()
