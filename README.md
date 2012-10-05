# QueueNotifier

This few lines of code can be used to trigger any shell command and push its 
status into the STOMP queue. I have found it handy combined with MCollective to
track longer tasks which I daemonize previously using @ripienaar daemonize script.
Called with '-a' switch can be used as STOMP sniffer.

## Example of use

    $ queue_notifier.rb -c 'ls / >/dev/null 2>&1'                
    Sending UUID: 61f7fd0b-835c-428d-8beb-3f7b8ea7139e
    $ ./bin/get_status.rb -t 10 -u 61f7fd0b-835c-428d-8beb-3f7b8ea7139e
    Operation with UUID: 61f7fd0b-835c-428d-8beb-3f7b8ea7139e finished with exitstatus: 0
    $
 
## Config file

Config file should be placed in 'etc/queue_notifier.conf' and looks like:

    [stomp]
    username = USERNAME
    password = PASSWORD
    host     = HOST
    queue    = QUEUE

## Dependencies

To deal with deps, just launch:

    bundle install


