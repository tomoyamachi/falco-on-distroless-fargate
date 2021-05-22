# falco-on-distroless-fargate


## on Local
Only supports x86_64 arch.

```shell
$ git clone https://github.com/tomoyamachi/falco-on-distroless-fargate --recursive
$ docker build -t falco-on-distroless .
$ docker run --rm -it falco-on-distroless .

2021/05/11 15:18:08 start :  /usr/bin/falco -u --pidfile /var/run/falco.pid
2021-05-11T15:18:08+0000: Falco version 0.28.1 (driver version 5c0b863ddade7a45568c0ac97d037422c9efb750)
2021-05-11T15:18:08+0000: Falco initialized with configuration file /etc/falco/falco.yaml
2021-05-11T15:18:08+0000: Configured rules filenames:
2021-05-11T15:18:08+0000:    /etc/falco/falco_rules.yaml
2021-05-11T15:18:08+0000: Loading rules from file /etc/falco/falco_rules.yaml:
2021/05/11 15:18:13 successfully create 1620746293.txt
{"output":"2021-05-11T15:18:13.962071600+0000: Error File below / or /root opened for writing (user=root user_loginuid=-1 command=app parent=pdig file=/ program=app container_id=b6c6e31f1bbf image=<NA>)","priority":"Error","rule":"Write below root","time":"2021-05-11T15:18:13.962071600Z", "output_fields": {"container.id":"b6c6e31f1bbf","container.image.repository":null,"evt.time.iso8601":1620746293962071600,"fd.name":"/","proc.cmdline":"app","proc.name":"app","proc.pname":"pdig","user.loginuid":-1,"user.name":"root"}}
2021/05/11 15:18:18 successfully create 1620746298.txt
{"output":"2021-05-11T15:18:18.929868000+0000: Error File below / or /root opened for writing (user=root user_loginuid=-1 command=app parent=pdig file=/ program=app container_id=b6c6e31f1bbf image=<NA>)","priority":"Error","rule":"Write below root","time":"2021-05-11T15:18:18.929868000Z", "output_fields": {"container.id":"b6c6e31f1bbf","container.image.repository":null,"evt.time.iso8601":1620746298929868000,"fd.name":"/","proc.cmdline":"app","proc.name":"app","proc.pname":"pdig","user.loginuid":-1,"user.name":"root"}}
^C2021-05-11T15:18:19+0000: SIGINT received, exiting...
Events detected: 2
Rule counts by severity:
   ERROR: 2
Triggered rules by rule name:
   Write below root: 2
Syscall event drop monitoring:
   - event drop detected: 0 occurrences
   - num times actions taken: 0
```

## on Fargate

Add SYS_PTRACE capability to containers. ([sysdig blog](https://sysdig.com/blog/falco-support-on-aws-fargate/)) 

```shell
"linuxParameters": {"capabilities":{"add":["SYS_PTRACE"]}}
```