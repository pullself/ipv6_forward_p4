#include<core.p4>
#include<v1model.p4>

const bit<16> TYPE_IPV6 = 0x86DD;

/*HEADERS*/

typedef bit<9> egressSpec_t;
typedef bit<48> macAddr_t;

header ethernet_t{
	macAddr_t dstAddr;
	macAddr_t srcAddr;
	bit<16> etherType;
}
 
header ipv6_t{
	bit<4> version;
	bit<8> trafficClass;
	bit<20> flowLabel;
	bit<16> payLoadLen;
	bit<8> nextHdr;
	bit<8> hopLimit;
	bit<128> srcAddr;
	bit<128> dstAddr;
}

struct metadata{
	
}

struct headers{
	ethernet_t ethernet;
	ipv6_t ipv6;
}

/*PARSER*/

parser MyParser(packet_in packet,out headers hdr,inout metadata meta,inout standard_metadata_t standard_metadata){
	state start{
		transition parse_ethernet;
	}
	
	state parse_ethernet{
		packet.extract(hdr.ethernet);
		transition select(hdr.ethernet.etherType){
			TYPE_IPV6:parse_ipv6;
			default:accept;
		}
	}
	
	state parse_ipv6{
		packet.extract(hdr.ipv6);
		transition accept;
	}
}

/*CHECKSUM VERIFICATION*/

control MyVerifyChecksum(inout headers hdr,inout metadata meta){
	apply{}
}

/*INGRESS PROCESSING*/

control MyIngress(inout headers hdr,inout metadata meta,inout standard_metadata_t standard_metadata){
	action drop(){
		mark_to_drop();
	}
	
	action ipv6_forward(macAddr_t dstAddr,egressSpec_t port){
		standard_metadata.egress_spec = port;
		hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
		hdr.ethernet.dstAddr = dstAddr;
		hdr.ipv6.hopLimit = hdr.ipv6.hopLimit - 1;
	}
	
	table ipv6_lpm{
		key = {
			hdr.ipv6.dstAddr: lpm;
		}
		
		actions = {
			ipv6_forward;
			drop;
			NoAction;
		}
		
		size = 1024;
		
		default_action = drop();
	}
	
	apply{
		if(hdr.ipv6.isValid()){
			ipv6_lpm.apply();
		}
	}
}

/*EGRESS PROCESSING*/

control MyEgress(inout headers hdr,inout metadata meta,inout standard_metadata_t standard_metadata){
	apply{}
}

/*CHECKSUM COMPUTATION*/

control MyComputeChecksum(inout headers hdr,inout metadata meta){
	apply{}
}

/*DEPARSER*/

control MyDeparser(packet_out packet,in headers hdr){
	apply{
		packet.emit(hdr.ethernet);
		packet.emit(hdr.ipv6);
	}
}

/*SWITCH*/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
)main;

