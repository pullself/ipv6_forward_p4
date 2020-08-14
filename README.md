
1.In your shell, run:
```
$ ./run.sh
```

This will:
*compile ipv6_forward.p4, and
*start a Mininet instance with three switches 's1' configured in a triangle, each connected to one host 'h1', 'h2'.

2.You should now see a Mininet command prompt. Open two terminals for 'h1' and 'h2', respectively:

```
mininet> xterm h1 h2
```

3.Each host includes a small Python-based messaging client and server. In h2's xterm, start the server:
```
$ ./receive.py
```

4.In 'h1''s xterm, send a message from the client:
```
$ ./send.py fe80::1234 fe80::5678 "Hello P4!"
```
The message will be received in h2's windows.

5.Type 'exit' to leave each xterm and the Mininet command line.
```
mininet>exit
$./cleanup.sh
```

