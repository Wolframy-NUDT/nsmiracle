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

# TCP over UMTS sample

#             Mobile Terminal(s)               Base Station
#	+-----------------------+	+-----------------------------------+
#	| 	7. TCP          |	| 7. TCP          |       7. TCP    |
#	+-----------------------+	+-----------------------------------+
#	| 	6. PORT         |     	|	6. PORT                	    |
#	+-----------------------+	+-----------------------------------+
#	| 	5. IP/Routing   |     	|	5. IP/Routing          	    |
#	+-----------------------+	+-----------------------------------+
#	| 	4. IP/Interface |     	|	4. IP/Interface        	    |
#	+-----------------------+	+-----------------------------------+
#	| 	3. UMTS/RLC/AM  |	| 3. UMTS/RLC/AM  | 3. UMTS/RLC/AM  |
#	+-----------------------+	+-----------------------------------+
#	| 	2. UMTS/MAC     |	| 2. UMTS/MAC     | 2. UMTS/MAC     |
#	+-----------------------+	+-----------------------------------+
#	| 	1. MPHY/BPSK	|	| 	1. MPHY/BPSK          	    |
#	+-----------------------+	+-----------------------------------+
#                    |                               |
#	+-------------------------------------------------------+
#       |                  DumbWirelessChannel                  |
#       +-------------------------------------------------------+







########################################
# Module Libraries
########################################

source dynlibutils.tcl

dynlibload Miracle
dynlibload MiracleBasicMovement
dynlibload MiracleIp
dynlibload MiracleIpRouting
dynlibload miracletcp
dynlibload miracleport
dynlibload MiracleWirelessCh
dynlibload mphy
dynlibload umts ../src/.libs/


########################################
# Tracers
########################################

#dynlibload mphytracer
dynlibload sinrtracer
dynlibload tcptracer
dynlibload umtstracer ../src/.libs/
#dynlibload routingtracer


########################################
# Scenario Configuration
########################################


# how many Mobile Terminals

set opt(nn) 5

# duration of each transmission
set opt(duration) 10


# field width
set xFieldWidth 200
set yFieldWidth 200

set posRNG [new RNG]



set ns [new Simulator]
$ns use-Miracle


proc finish {} {
    global ns tf 
    puts "done!"
   print_stats
    $ns flush-trace
    close $tf
    $ns halt
}


proc debug_rlc {id} {

    if {true} {

	global me_rlc bs_rlc

	set merlc [$me_rlc($id) getRlc]
	set bsrlc [$bs_rlc($id) getRlc]
	puts "---------------------------------------"
	puts "RLC var        ME   \t\t BS"
	puts "---------------------------------------"
	puts "payload_       [$merlc set payload_ ]\t\t [$bsrlc set payload_ ]"  
	puts "bandwidth_     [$merlc set bandwidth_ ]\t\t [$bsrlc set bandwidth_ ]"
	puts "TTI_           [$merlc set TTI_ ]\t\t [$bsrlc set TTI_ ]"
	puts "TTI_PDUs_      [$merlc set TTI_PDUs_ ]\t\t [$bsrlc set TTI_PDUs_ ]"
	puts "maxdat_        [$merlc set maxdat_ ]\t\t [$bsrlc set maxdat_ ]"
	puts "rlc id         [$me_rlc($id) getRlcId]\t\t [$bs_rlc($id) getRlcId]"

    }   
}


proc debug_phy {phy} {
    if {true} {
	puts "slot_duration_     [$phy set slot_duration_ ]"
	puts "chip_rate_         [$phy set chip_rate_ ]"
	puts "spreading_factor_  [$phy set spreading_factor_ ]"
	puts "bits_per_symbol_   [$phy set bits_per_symbol_ ]"
	puts "coding_rate_       [$phy set coding_rate_ ]"
	puts "coding_type_       [$phy set coding_type_ ]"
	puts "code_id_           [$phy set code_id_ ]"
	puts "DataRate           [$phy getDataRate]"
	puts "PERtarget_         [$phy set PERtarget_]"
	puts "SIRtarget_         [$phy set SIRtarget_]"
    }
}


proc print_stats  {} {
    global bs_tcpa bs_cbr me_cbr opt bs_rlc me_rlc
    puts ""
    puts "            <----------------DOWNLINK------------------->   <-------UPLINK--------> "
    puts "ID\t\tTHR\t\tRTT\t\tAckPDUs\tDropPDUs\t\tAckPDUs\tDropPDUs"
                                          
    for {set id 1} {$id <= $opt(nn) } {incr id} {


	set bs_rlcm [$bs_rlc($id) getRlc]
	set me_rlcm [$me_rlc($id) getRlc]

	set thrtcp [ expr [ $bs_tcpa($id) set ack_  ] * [$bs_tcpa($id) set packetSize_] * 8 / ($opt(duration) + 0.0)]
	set rtttcp [ expr [ $bs_tcpa($id) set rtt_] * [$bs_tcpa($id) set tcpTick_]]

	set bs_ackpdus  [$bs_rlcm set ack_PDUs_ ]
	set bs_droppdus [$bs_rlcm set drop_PDUs_]
	set me_ackpdus  [$me_rlcm set ack_PDUs_ ]
	set me_droppdus [$me_rlcm set drop_PDUs_]
	set me_acksdus  [$me_rlcm set ack_SDUs_]
	set me_dropsdus [$me_rlcm set drop_SDUs_]

#	set pduer [expr $droppdus / ($ackpdus + $droppdus)]

	puts "$id\t\t$thrtcp\t$rtttcp\t$bs_ackpdus\t$bs_droppdus\t\t\t$me_ackpdus\t$me_droppdus"
    }

    puts ""
    puts "Tracefile:       $opt(tracefile)"
    puts "TCP tracefile:   $opt(tcptrfname)"

}



set opt(tracefile) /tmp/umts_tcp.tr
set tf [open $opt(tracefile) w]
$ns trace-all $tf


########################################
# Override Default Module Configuration
########################################

Agent/TCP set packetSize_    500
UMTS/RLC/AM set win_         1024
UMTS/RLC/AM set maxdat_      3
UMTS/RLC/AM set stprob_timeout_       40ms
UMTS/RLC/AM set poll_timeout_         85ms
Module/UMTS/MAC set interleaving_    0.040
Module/MPhy/UMTS set PERtarget_ 1e-6
Module/MPhy/UMTS set PowerCtrlUpdateCmdAtStartRx_   1
Module/MPhy/UMTS set PowerCtrlReadCmdAtStartRx_     1
Module/MPhy/UMTS/BS set spreading_factor_ 8
Module/MPhy/UMTS/ME set spreading_factor_ 8
Module/MPhy/UMTS/BS set minTxPower_      2.5e-10

UMTS/RLC/AM set debug_        0
Module/UMTS/RLC/AM set debug_ 0
Module/MPhy/UMTS set debug_   0
MInterference/MIV/UMTS set debug_  0
Correlation/UMTS set debug_   0
set bsdebug 0
set medebug 0


###############################
# Global allocations
###############################

set channel [new Module/UmtsWirelessCh]
$channel setTag "CHA"

set spectralmask_umts_downlink [new MSpectralMask/Rect]
$spectralmask_umts_downlink setFreq 2115000000
$spectralmask_umts_downlink setBandwidth 3840000
set spectralmask_umts_uplink [new MSpectralMask/Rect]
$spectralmask_umts_uplink setFreq   1925000000
$spectralmask_umts_uplink setBandwidth 3840000

set propagation [new MPropagation/MFreeSpace]



###############################
#  Create Base Station
###############################


set bs_node   [$ns create-M_Node] 

set bs_phy    [new Module/MPhy/UMTS/BS]

set bs_ipif   [new Module/IP/Interface]
set bs_ipr    [new Module/IP/Routing]
set bs_port   [new Module/Port/Map]

$bs_ipif  addr   "1.0.0.1"
$bs_ipif   subnet "255.255.0.0"
# Ok this is somehow obvious but its implementation is somehow broken
$bs_ipr  addroute "1.0.1.0" "255.255.255.0" "1.0.0.1"

$bs_node addModule 1 $bs_phy  0 "PHY "
$bs_node addModule 4 $bs_ipif 0 "WIF "
$bs_node addModule 5 $bs_ipr  0 "IPR "
$bs_node addModule 6 $bs_port  0 "PRT "

$bs_node setConnection $bs_port $bs_ipr   0
$bs_node setConnection $bs_ipr  $bs_ipif  0
$bs_node addToChannel $channel $bs_phy    0

$channel BSphymoduleId [$bs_phy Id_]

$bs_phy setDownlinkSpectralMask $spectralmask_umts_downlink
$bs_phy setUplinkSpectralMask   $spectralmask_umts_uplink

$bs_phy setInterference         [new MInterference/MIV/UMTS]
$bs_phy setPropagation          $propagation
$bs_phy set debug_ $bsdebug




set bs_pos [new "Position/BM"]
$bs_pos set debug_ 11
$bs_node addPosition $bs_pos
# BS is placed in the centre of the simulation area
$bs_pos setX_ [expr $xFieldWidth / 2]
$bs_pos setY_ [expr $yFieldWidth / 2]



puts ""
puts "-----------------------"
puts "Packet Header Debugging "
puts "-----------------------"
$bs_phy printPktHeaderInfo
puts ""

#$bs_phy set debug_ 0

###############################
#  Create Mobile Equipments
###############################

for {set id 1} {$id <= $opt(nn)} {incr id} {

    set me_node($id)   [$ns create-M_Node] 


    # Create Protocol Stack 

    set me_tcpsink($id)  [new Module/TCPSink]
    set me_port($id)     [new Module/Port/Map]
    set me_ipr($id)      [new Module/IP/Routing]
    set me_ipif($id)     [new Module/IP/Interface]
    set me_rlc($id)      [new Module/UMTS/RLC/AM]
    set me_mac($id)      [new Module/UMTS/MAC/ME]
    set me_phy($id)      [new Module/MPhy/UMTS/ME]
  
    set me_tcpa($id)     [$me_tcpsink($id) getTcpAgent]    

    $me_node($id) addModule 7 $me_tcpsink($id)  0 "TCP "
    $me_node($id) addModule 6 $me_port($id) 0 "PRT "
    $me_node($id) addModule 5 $me_ipr($id)  0 "IPR "
    $me_node($id) addModule 4 $me_ipif($id) 0 "IPF "
    $me_node($id) addModule 3 $me_rlc($id)  0 "RLC "
    $me_node($id) addModule 2 $me_mac($id)  0 "MAC "
    $me_node($id) addModule 1 $me_phy($id)  0 "PHY "


    $me_node($id) setConnection $me_tcpsink($id)  $me_port($id)  1
    $me_node($id) setConnection $me_port($id) $me_ipr($id)   0
    $me_node($id) setConnection $me_ipr($id)  $me_ipif($id)  0
    $me_node($id) setConnection $me_ipif($id) $me_rlc($id)   0
    $me_node($id) setConnection $me_rlc($id)  $me_mac($id)   1
    $me_node($id) setConnection $me_mac($id)  $me_phy($id)   1
    $me_node($id) addToChannel  $channel      $me_phy($id)   0

    # Protocol Stack Configuration

    $me_phy($id) setDownlinkSpectralMask $spectralmask_umts_downlink
    $me_phy($id) setUplinkSpectralMask   $spectralmask_umts_uplink

    $me_phy($id) setInterference         [new MInterference/MIV/UMTS]
    $me_phy($id) setPropagation          $propagation
    
    $me_phy($id) set debug_ $medebug
    $me_mac($id) set debug_ $medebug

    $me_ipif($id) addr   "1.0.1.$id"
    $me_ipif($id) subnet "255.255.0.0"
    # Ok this is somehow obvious but its implementation is somehow broken
    $me_ipr($id)  addroute "1.0.0.0" "255.255.255.0" "1.0.1.$id"

    set me_tcpportnum($id) [$me_port($id) assignPort $me_tcpsink($id) ]

    finalizeUmtsStack $me_phy($id) $me_mac($id) $me_rlc($id) [$me_ipif($id) addr]

    # We need a cbr and a RLC module at the BS for each ME
    set bs_tcp($id)        [new Module/TCP/Reno] 
    set bs_rlc($id)        [new Module/UMTS/RLC/AM]
    set bs_mac($id)        [new Module/UMTS/MAC/BS]

    set bs_tcpa($id)   [$bs_tcp($id) getTcpAgent]
    set bs_ftp($id)    [new Application/FTP]
    $bs_ftp($id) attach-agent $bs_tcpa($id)

    $bs_rlc($id) set debug_ 0
    $bs_mac($id) set debug_ $bsdebug



    $bs_node addModule 7 $bs_tcp($id) 0 "TCP$id"
    $bs_node addModule 3 $bs_rlc($id) 0 "RLC$id"
    $bs_node addModule 2 $bs_mac($id) 0 "MAC$id"

    $bs_node setConnection $bs_tcp($id)    $bs_port      1
    $bs_node setConnection $bs_ipif        $bs_rlc($id)  0
    $bs_node setConnection $bs_rlc($id)    $bs_mac($id)  1
    $bs_node setConnection $bs_mac($id)    $bs_phy       1

    set bs_tcpportnum($id) [$bs_port assignPort $bs_tcp($id) ]



    finalizeUmtsStack $bs_phy $bs_mac($id) $bs_rlc($id) [$bs_ipif addr]

    $me_rlc($id) connect2CoreNetRlc  $bs_rlc($id) 



    # setup socket connection between ME and BS
    $bs_tcpa($id) set dst_addr_ [$me_ipif($id) addr]
    $bs_tcpa($id) set dst_port_ $me_tcpportnum($id)
    $me_tcpa($id) set dst_addr_ [$bs_ipif addr]
    $me_tcpa($id) set dst_port_ $bs_tcpportnum($id)


    $ns at 0 "$bs_ftp($id) start"
    $ns at $opt(duration)  "$bs_ftp($id) stop"


    set me_pos($id) [new "Position/BM"]
    $me_node($id) addPosition $me_pos($id)

    # mobile equipment are placed randomly (with uniform distribution) in the simulation area
    $me_pos($id) setX_ [$posRNG uniform 0 $xFieldWidth]
    $me_pos($id) setY_ [$posRNG uniform 0 $yFieldWidth]

  
    
    puts ""
    puts "--------------------"
    puts "Node $id is at ([expr int([$me_pos($id) getX_])],[expr int([$me_pos($id) getY_])])"
    puts "--------------------"
    debug_phy $me_phy($id)
    debug_rlc $id
    puts ""


}


puts ""
puts "--------------------"
puts "Base Station:"
puts "--------------------"
debug_phy $bs_phy 
puts "iuccorr_           [$bs_phy set iuccorr_]"
puts ""


# $bs_cbr(1) set debug_ 0
# $bs_phy set debug_ 0
# $me_phy(1) set debug_ 0

[$me_rlc(1) getRlc] set receiver_debug_ 0
# [$bs_rlc(1) getRlc] set sender_debug_   0

# $me_pos(1) setX_ 50000
# $me_pos(1) setY_ 0

#$ns at 2.19 "[$me_rlc(1) getRlc] set debug_ 2"




###############################
#  CWND tracing
###############################

set opt(tcptrfname)  "/tmp/tcp_trace.tr"
set opt(tcpTrace)    [ open  $opt(tcptrfname) w]

set tcptracer [new BaseTrace/Event]
$tcptracer attach $opt(tcpTrace)
$bs_tcpa(1) eventtrace $tcptracer
$bs_tcpa(1) attach $opt(tcpTrace)
$bs_tcpa(1) trace cwnd_
$bs_tcpa(1) trace nrexmit_
$bs_tcpa(1) trace t_seqno_
#$bs_tcpa(1) trace last_cwnd_action_
$bs_tcpa(1) trace rtt_
$bs_tcpa(1) trace srtt_
$bs_tcpa(1) trace ssthresh_



proc printRTT {} {
    global bs_tcpa
    puts [ expr [ $bs_tcpa(1) set rtt_] * [$bs_tcpa(1) set tcpTick_]]
}


###############################
#  Start Simulation
###############################

puts -nonewline "Simulating"
for {set i 1} {$i < 40} {incr i} {
    $ns at [expr  (($opt(duration) * $i)/ 40.0) ] "puts -nonewline . ; flush stdout"
    #$ns at [expr  (($opt(duration) * $i)/ 40.0) ] "printRTT"
}
$ns at [expr $opt(duration) + 3] "finish"
$ns run
