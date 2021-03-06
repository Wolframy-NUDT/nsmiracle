/* -*- Mode:C++ -*- */

/*
 * Copyright (c) 2007 Regents of the SIGNET lab, University of Padova.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University of Padova (SIGNET lab) nor the 
 *    names of its contributors may be used to endorse or promote products 
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
 * OR BUSINESS ON_OFF_SWITCHION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


/**
 * @file   clmsg-mac-phy.h
 * @author Federico Guerra
 * @date   Thu Oct 2 14:23:09 2008
 * 
 * @brief  
 * 
 * 
 */


#ifndef PHY_CLMSG_ON_OFF_SWITCH_H
#define PHY_CLMSG_ON_OFF_SWITCH_H

#include <clmessage.h>
#include <packet.h>

#define CLMSG_PHY_ON_OFF_SWITCH_VERBOSITY 3
#define CLMSG_PHY_ON_OFF_SWITCH_STATUS_VERBOSITY 3

extern ClMessage_t CLMSG_PHY_ON_OFF_SWITCH;
extern ClMessage_t CLMSG_PHY_ON_OFF_SWITCH_STATUS;

class ClSAP;

class ClMsgPhyOnOffSwitch : public ClMessage
{

public:

  ClMsgPhyOnOffSwitch();
  ClMsgPhyOnOffSwitch(int destination);

  void setOn();
  void setOff();
  bool isOn();

  ClMessage* copy();	// copy the message
	
private:

  bool turnOn;
};

class ClMsgPhyOnOffSwitchStatus : public ClMessage
{

public:

  ClMsgPhyOnOffSwitchStatus();
  ClMsgPhyOnOffSwitchStatus(int destination);

  void setStatus(bool flag);
  bool getStatus();

  ClMessage* copy();	// copy the message
	
private:

  bool isOn_status;
};


#endif /* PHY_CLMSG_ON_OFF_SWITCH_H */


