;	Include	[Sam]Start

	PushOrg	RamSav						;; It's important to note that RAMSAVE and RAMSAV are different

CalOne	rmb	1		;* Flag - if not zero, first call for a caller
RnSpch	rmb	1		;* Random speech call number of last call
EndPop	rmb	2		;* The End of Population pointer

	PullOrg	RamSav						