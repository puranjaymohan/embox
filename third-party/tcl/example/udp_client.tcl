package require udp

set server "192.168.0.210"
set port   12345
set prompt ">>"

set state initial

proc printDataFromSock {sock} {
	global state
	# waiting while some data will be avaliable
	gets $sock buf

	fconfigure $sock -blocking 0
	while 1 {
		puts $buf
		if {[gets $sock buf] < 0} {
			after 100
			if {[gets $sock buf] < 0} break
		}
	}
	fconfigure $sock -blocking 1

	set state readed
}

set sock [udp_open]
fconfigure $sock -buffering none -remote [list $server $port]
fileevent $sock readable [list printDataFromSock $sock]

fconfigure stdout -buffering none

puts "enter commands:"
puts -nonewline $prompt
flush stdout

while {1} {
	gets stdin cmd
	puts -nonewline $sock $cmd
	vwait state
	puts -nonewline $prompt
}

