# Define options
set val(chan) Channel/WirelessChannel 	;# channel type
set val(prop) Propagation/TwoRayGround 	;# radio-propagation model
set val(netif) Phy/WirelessPhy 		;# network interface type
set val(mac) Mac/802_11 		;# MAC type
set val(ifq) Queue/DropTail/PriQueue 	;# interface queue type
set val(ll) LL 				;# link layer type
set val(ant) Antenna/OmniAntenna 	;# antenna model
set val(ifqlen) 50 			;# max packet in ifq
set val(nn) 20 				;# number of mobilenodes
set val(rp) AODV 			;# routing protocol
set val(x) 300				;# X dimension of topography
set val(y) 160				;# Y dimension of topography 
set val(stop) 75 			;# time of simulation end

#-------Event scheduler object creation--------#
set ns              [new Simulator]

#creating trace file and nam file
set tracefd       [open 2gates.tr w]
set windowVsTime2 [open win.tr w] 
set namtrace      [open 2gates.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

# configure gateway node
        $ns node-config -adhocRouting $val(rp) \
                   -llType $val(ll) \
                   -macType $val(mac) \
                   -ifqType $val(ifq) \
                   -ifqLen $val(ifqlen) \
                   -antType $val(ant) \
                   -propType $val(prop) \
                   -phyType $val(netif) \
                   -channelType $val(chan) \
                   -topoInstance $topo \
                   -agentTrace ON \
                   -routerTrace ON \
                   -macTrace OFF \
                   -movementTrace ON

		
	for {set i 0} {$i < 2 } { incr i } {
	        set node_($i) [$ns node];
	        $node_($i) color "red";
	        $ns at 3.0 "$node_($i) color red"	        
		}
		
	for {set i 0} {$i < 2 } { incr i } {
		$ns at 3.0 "$node_($i) label gateway"
		}
		
	for {set i 2} {$i < $val(nn) } { incr i } {
	        set node_($i) [$ns node];
	        $node_($i) color "blue";
	        $ns at 3.0 "$node_($i) color blue"
		}
     

#Change node color based on role
$node_(4) color green
$ns at 7.0 "$node_(2) color green"
$ns at 36.0 "$node_(2) color blue"

$node_(5) color green
$ns at 8.0 "$node_(3) color green"
$ns at 39.0 "$node_(3) color blue"

$node_(6) color green
$ns at 44.0 "$node_(4) color green"
$ns at 65.0 "$node_(4) color blue"

$node_(9) color green
$ns at 45.0 "$node_(5) color green"
$ns at 66.0 "$node_(5) color blue"

#Change node label based on role
$ns at 7.0 "$node_(2) label sender"
$ns at 36.0 "$node_(2) label \"\""

$ns at 8.0 "$node_(3) label reciever"
$ns at 39.0 "$node_(3) label \"\""

$ns at 44.0 "$node_(4) label sender"
$ns at 65.0 "$node_(4) label \"\""

$ns at 45.0 "$node_(5) label reciever"
$ns at 66.0 "$node_(5) label \"\""

#Provide location of gateways
	
$node_(0) set X_ 200.0
$node_(0) set Y_ 90.0
$node_(0) set Z_ 0.0
$node_(0) color red

$node_(1) set X_ 50.0
$node_(1) set Y_ 125.0
$node_(1) set Z_ 0.0
$node_(1) color red

$node_(2) set X_ 250.0
$node_(2) set Y_ 150.0
$node_(2) set Z_ 0.0
$node_(2) color red

$node_(3) set X_ 5.0
$node_(3) set Y_ 70.0
$node_(3) set Z_ 0.0
$node_(3) color red

$node_(4) set X_ 25.0
$node_(4) set Y_ 25.0
$node_(4) set Z_ 0.0
$node_(4) color red

$node_(5) set X_ 50.0
$node_(5) set Y_ 50.0
$node_(5) set Z_ 0.0
$node_(5) color red

# Provide random initial position of mobilenodes
for {set i 6} {$i < $val(nn)} {incr i} {
	$node_($i) set X_ [expr rand()*300]
	$node_($i) set Y_ [expr rand()*160]
	$node_($i) set Z_ 0
}


# Generation of random movement and speed
for {set i 0} {$i < 6} {incr i} {
$ns at 0.0 "$node_($i) setdest [expr rand()*300] [expr rand()*160] 1.0"
}

for {set i 6} {$i < $val(nn)} {incr i} {
$ns at 0.0 "$node_($i) setdest [expr rand()*300] [expr rand()*160] [expr rand()*10]"
}


# Set up TCP connections
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(2) $tcp
$ns attach-agent $node_(0) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 9.0 "$ftp start"
$ns at 35.0 "$ftp stop"

set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start"
$ns at 36.0 "$ftp stop"

set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(1) $tcp
$ns attach-agent $node_(3) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 11.0 "$ftp start"
$ns at 37.0 "$ftp stop"

set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(4) $tcp
$ns attach-agent $node_(5) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 45.0 "$ftp start"
$ns at 65.0 "$ftp stop"

# Printing the window size
proc plotWindow {tcpSource file} {
global ns
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
$ns at 10.0 "plotWindow $tcp $windowVsTime2" 

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
$ns initial_node_pos $node_($i) 30
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
exec nam 2gates.nam &
}

$ns run
