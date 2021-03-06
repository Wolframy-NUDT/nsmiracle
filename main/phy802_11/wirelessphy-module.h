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
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF 
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef _WIRELESSPHYModule_
#define _WIRELESSPHYModule_

#include "module.h"
#include "wireless-phy.h"
//#include <node-core.h>

class Position;

/*Header introduced to solve MobileNode dependeces in WirelessPhy (regarding position and energy model)*/
struct hdr_MrclWrlPhy {
	Position *sourcePos_;
	Position *destPos_;
	
	static int offset_;
	inline int& offset() { return offset_; }
	static hdr_MrclWrlPhy* access(const Packet* p) {
		return (hdr_MrclWrlPhy*) p->access(offset_);
	}

};

#define HDR_MRCLWRLPHY(p)      (hdr_MrclWrlPhy::access(p))

class WirelessPhyModule : public Module
{
	public:
		WirelessPhyModule();
		virtual ~WirelessPhyModule();
		virtual void recv(Packet*, Handler* callback);
		virtual void recv(Packet *p);
		virtual int command(int argc, const char*const* argv);
	protected:
		Phy *phy_;
};

#endif
