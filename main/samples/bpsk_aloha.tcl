#
# Copyright (c) 2007 Regents of the SIGNET lab, University of Padova.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the University of Padova (SIGNET lab) nor the 
#    names of its contributors may be used to endorse or promote products 
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# BPSK + ALOHA sample


#	+-----------------------+	+-----------------------+
#	| 	3. CBR  (sm)    |	| 	3. CBR	(rm)    |
#	+-----------------------+	+-----------------------+
#	| 	2. MMAC/ALOHA   |	| 	2. MMAC/ALOHA   |
#	+-----------------------+	+-----------------------+
#	| 	1. MPHY/BPSK	|	| 	1. MPHY/BPSK	|
#	+-----------------------+	+-----------------------+
#                    |                               |
#	+-------------------------------------------------------+
#       |                  DumbWirelessChannel                  |
#       +-------------------------------------------------------+


# Module libraries

load ../nsmiracle/.libs/libMiracle.so
load ../cbr/.libs/libmiraclecbr.so
load ../wirelessch/.libs/libMiracleWirelessCh.so
load ../mphy/.libs/libmphy.so
load ../mobility/.libs/libMiracleBasicMovement.so


#load ../mphy/.libs/libmphytracer.so
load ../cbr/.libs/libcbrtracer.so
load ../mphy/.libs/libsinrtracer.so
load ../mphy/.libs/libmphymaccltracer.so
#load ../cltrace/.libs/libClTrace.so
load ../cltrace/.libs/libverboseclcmntracer.so


proc finish {} {
	global ns opt
	puts "done!"
        puts "tracefile: $opt(tracefilename)"
	$ns flush-trace
	close $opt(tracefile)
}




set ns [new Simulator]
$ns use-Miracle


#Module/CBR set debug_ 1


######################################
# global allocations & misc options
######################################

set opt(starttime)     0.0
set opt(stoptime)    0.2
set opt(txduration) [expr $opt(stoptime) - $opt(starttime)]
set opt(xmax)        100.0


set opt(tracefilename) "/tmp/bpsk_aloha.tr"
set opt(tracefile) [open $opt(tracefilename) w]
$ns trace-all $opt(tracefile)


set channel [new Module/DumbWirelessCh]

set propagation [new MPropagation/MFreeSpace]

set smask [new MSpectralMask/Rect]
$smask setFreq 2.4e9
$smask setBandwidth 100e6


MInterference/MIV set maxinterval_ 0.5
Module/MPhy/BPSK set bitrate_ 80000

Module/MPhy/BPSK set AcquisitionThreshold_dB_ 0.0

Module/CBR set packetSize_ 210
Module/CBR set period_    0.02


###############################
# Procedure for creating nodes
###############################

proc createNode {id } {

    global channel propagation smask ns cbr position bpsk node
    
    set node($id) [$ns create-M_Node] 

    set cbr($id) [new Module/CBR] 
    set mac($id) [new Module/MMac/ALOHA] 
    set phy($id) [new Module/MPhy/BPSK]

    $node($id) addModule 3 $cbr($id) 0 "CBR($id)"
    $node($id) addModule 2 $mac($id) 0 "MAC($id)"
    $node($id) addModule 1 $phy($id) 0 "PHY($id)"

    $node($id) setConnection $cbr($id) $mac($id) 1
    $node($id) setConnection $mac($id) $phy($id) 1
    $node($id) addToChannel $channel $phy($id)   0

    set position($id) [new "Position/BM"]
    $node($id) addPosition $position($id)
    $position($id) setX_ 0.0
    $position($id) setY_ 0.0
    $position($id) setZ_ 0.0

    $phy($id) set debug_ 0
    $phy($id) setSpectralMask $smask
    $phy($id) setPropagation $propagation

    set interf($id) [new MInterference/MIV]
    $phy($id) setInterference $interf($id)



}


###############################
# create nodes
###############################

createNode 1
$position(1) setX_ 1000.0
$ns at $opt(starttime)   "$cbr(1) start"
$ns at $opt(stoptime)   "$cbr(1) stop"

createNode 2
$position(2) setX_ 0.0
#$position(2) set debug_ 543

#puts "Node 2 moving to ($opt(xmax),0.0) at [expr $opt(xmax) / $opt(txduration)] m/s"
#$ns at [expr $opt(txduration) / 2.0] "$position(2) setdest $opt(xmax) 0.0 [expr $opt(xmax) / ($opt(txduration) /2.0)]"


###################
# start simulation
###################




puts -nonewline "Simulating"

for {set t $opt(starttime)} {$t <= $opt(stoptime)} {set t [expr $t + $opt(txduration) / 40.0 ]} {
    $ns at $t "puts -nonewline ."
}
$ns at [expr $opt(stoptime) + 50]  "finish; $ns halt"
$ns run
