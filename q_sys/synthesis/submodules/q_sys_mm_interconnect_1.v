// q_sys_mm_interconnect_1.v

// This file was auto-generated from altera_mm_interconnect_hw.tcl.  If you edit it your changes
// will probably be lost.
// 
// Generated using ACDS version 18.1 646

`timescale 1 ps / 1 ps
module q_sys_mm_interconnect_1 (
		input  wire        clk_0_clk_clk,                                                   //                                                 clk_0_clk.clk
		input  wire        vj_avalon_master_0_clock_sink_reset_reset_bridge_in_reset_reset, // vj_avalon_master_0_clock_sink_reset_reset_bridge_in_reset.reset
		input  wire [31:0] vj_avalon_master_0_avalon_master_address,                        //                          vj_avalon_master_0_avalon_master.address
		output wire        vj_avalon_master_0_avalon_master_waitrequest,                    //                                                          .waitrequest
		input  wire        vj_avalon_master_0_avalon_master_read,                           //                                                          .read
		output wire [31:0] vj_avalon_master_0_avalon_master_readdata,                       //                                                          .readdata
		input  wire        vj_avalon_master_0_avalon_master_write,                          //                                                          .write
		input  wire [31:0] vj_avalon_master_0_avalon_master_writedata,                      //                                                          .writedata
		output wire [9:0]  i2c_cont_bridge_0_slv_address,                                   //                                     i2c_cont_bridge_0_slv.address
		output wire        i2c_cont_bridge_0_slv_write,                                     //                                                          .write
		output wire        i2c_cont_bridge_0_slv_read,                                      //                                                          .read
		input  wire [31:0] i2c_cont_bridge_0_slv_readdata,                                  //                                                          .readdata
		output wire [31:0] i2c_cont_bridge_0_slv_writedata,                                 //                                                          .writedata
		input  wire        i2c_cont_bridge_0_slv_waitrequest,                               //                                                          .waitrequest
		output wire        i2c_cont_bridge_0_slv_chipselect                                 //                                                          .chipselect
	);

	wire         vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_waitrequest;   // i2c_cont_bridge_0_slv_translator:uav_waitrequest -> vj_avalon_master_0_avalon_master_translator:uav_waitrequest
	wire  [31:0] vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_readdata;      // i2c_cont_bridge_0_slv_translator:uav_readdata -> vj_avalon_master_0_avalon_master_translator:uav_readdata
	wire         vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_debugaccess;   // vj_avalon_master_0_avalon_master_translator:uav_debugaccess -> i2c_cont_bridge_0_slv_translator:uav_debugaccess
	wire  [31:0] vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_address;       // vj_avalon_master_0_avalon_master_translator:uav_address -> i2c_cont_bridge_0_slv_translator:uav_address
	wire         vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_read;          // vj_avalon_master_0_avalon_master_translator:uav_read -> i2c_cont_bridge_0_slv_translator:uav_read
	wire   [3:0] vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_byteenable;    // vj_avalon_master_0_avalon_master_translator:uav_byteenable -> i2c_cont_bridge_0_slv_translator:uav_byteenable
	wire         vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_readdatavalid; // i2c_cont_bridge_0_slv_translator:uav_readdatavalid -> vj_avalon_master_0_avalon_master_translator:uav_readdatavalid
	wire         vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_lock;          // vj_avalon_master_0_avalon_master_translator:uav_lock -> i2c_cont_bridge_0_slv_translator:uav_lock
	wire         vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_write;         // vj_avalon_master_0_avalon_master_translator:uav_write -> i2c_cont_bridge_0_slv_translator:uav_write
	wire  [31:0] vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_writedata;     // vj_avalon_master_0_avalon_master_translator:uav_writedata -> i2c_cont_bridge_0_slv_translator:uav_writedata
	wire   [2:0] vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_burstcount;    // vj_avalon_master_0_avalon_master_translator:uav_burstcount -> i2c_cont_bridge_0_slv_translator:uav_burstcount

	altera_merlin_master_translator #(
		.AV_ADDRESS_W                (32),
		.AV_DATA_W                   (32),
		.AV_BURSTCOUNT_W             (1),
		.AV_BYTEENABLE_W             (4),
		.UAV_ADDRESS_W               (32),
		.UAV_BURSTCOUNT_W            (3),
		.USE_READ                    (1),
		.USE_WRITE                   (1),
		.USE_BEGINBURSTTRANSFER      (0),
		.USE_BEGINTRANSFER           (0),
		.USE_CHIPSELECT              (0),
		.USE_BURSTCOUNT              (0),
		.USE_READDATAVALID           (0),
		.USE_WAITREQUEST             (1),
		.USE_READRESPONSE            (0),
		.USE_WRITERESPONSE           (0),
		.AV_SYMBOLS_PER_WORD         (4),
		.AV_ADDRESS_SYMBOLS          (1),
		.AV_BURSTCOUNT_SYMBOLS       (0),
		.AV_CONSTANT_BURST_BEHAVIOR  (0),
		.UAV_CONSTANT_BURST_BEHAVIOR (0),
		.AV_LINEWRAPBURSTS           (0),
		.AV_REGISTERINCOMINGSIGNALS  (0)
	) vj_avalon_master_0_avalon_master_translator (
		.clk                    (clk_0_clk_clk),                                                                       //                       clk.clk
		.reset                  (vj_avalon_master_0_clock_sink_reset_reset_bridge_in_reset_reset),                     //                     reset.reset
		.uav_address            (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_address),       // avalon_universal_master_0.address
		.uav_burstcount         (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_burstcount),    //                          .burstcount
		.uav_read               (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_read),          //                          .read
		.uav_write              (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_write),         //                          .write
		.uav_waitrequest        (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_waitrequest),   //                          .waitrequest
		.uav_readdatavalid      (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_readdatavalid), //                          .readdatavalid
		.uav_byteenable         (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_byteenable),    //                          .byteenable
		.uav_readdata           (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_readdata),      //                          .readdata
		.uav_writedata          (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_writedata),     //                          .writedata
		.uav_lock               (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_lock),          //                          .lock
		.uav_debugaccess        (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_debugaccess),   //                          .debugaccess
		.av_address             (vj_avalon_master_0_avalon_master_address),                                            //      avalon_anti_master_0.address
		.av_waitrequest         (vj_avalon_master_0_avalon_master_waitrequest),                                        //                          .waitrequest
		.av_read                (vj_avalon_master_0_avalon_master_read),                                               //                          .read
		.av_readdata            (vj_avalon_master_0_avalon_master_readdata),                                           //                          .readdata
		.av_write               (vj_avalon_master_0_avalon_master_write),                                              //                          .write
		.av_writedata           (vj_avalon_master_0_avalon_master_writedata),                                          //                          .writedata
		.av_burstcount          (1'b1),                                                                                //               (terminated)
		.av_byteenable          (4'b1111),                                                                             //               (terminated)
		.av_beginbursttransfer  (1'b0),                                                                                //               (terminated)
		.av_begintransfer       (1'b0),                                                                                //               (terminated)
		.av_chipselect          (1'b0),                                                                                //               (terminated)
		.av_readdatavalid       (),                                                                                    //               (terminated)
		.av_lock                (1'b0),                                                                                //               (terminated)
		.av_debugaccess         (1'b0),                                                                                //               (terminated)
		.uav_clken              (),                                                                                    //               (terminated)
		.av_clken               (1'b1),                                                                                //               (terminated)
		.uav_response           (2'b00),                                                                               //               (terminated)
		.av_response            (),                                                                                    //               (terminated)
		.uav_writeresponsevalid (1'b0),                                                                                //               (terminated)
		.av_writeresponsevalid  ()                                                                                     //               (terminated)
	);

	altera_merlin_slave_translator #(
		.AV_ADDRESS_W                   (10),
		.AV_DATA_W                      (32),
		.UAV_DATA_W                     (32),
		.AV_BURSTCOUNT_W                (1),
		.AV_BYTEENABLE_W                (4),
		.UAV_BYTEENABLE_W               (4),
		.UAV_ADDRESS_W                  (32),
		.UAV_BURSTCOUNT_W               (3),
		.AV_READLATENCY                 (0),
		.USE_READDATAVALID              (0),
		.USE_WAITREQUEST                (1),
		.USE_UAV_CLKEN                  (0),
		.USE_READRESPONSE               (0),
		.USE_WRITERESPONSE              (0),
		.AV_SYMBOLS_PER_WORD            (4),
		.AV_ADDRESS_SYMBOLS             (0),
		.AV_BURSTCOUNT_SYMBOLS          (0),
		.AV_CONSTANT_BURST_BEHAVIOR     (0),
		.UAV_CONSTANT_BURST_BEHAVIOR    (0),
		.AV_REQUIRE_UNALIGNED_ADDRESSES (0),
		.CHIPSELECT_THROUGH_READLATENCY (0),
		.AV_READ_WAIT_CYCLES            (1),
		.AV_WRITE_WAIT_CYCLES           (0),
		.AV_SETUP_WAIT_CYCLES           (0),
		.AV_DATA_HOLD_CYCLES            (0)
	) i2c_cont_bridge_0_slv_translator (
		.clk                    (clk_0_clk_clk),                                                                       //                      clk.clk
		.reset                  (vj_avalon_master_0_clock_sink_reset_reset_bridge_in_reset_reset),                     //                    reset.reset
		.uav_address            (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_address),       // avalon_universal_slave_0.address
		.uav_burstcount         (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_burstcount),    //                         .burstcount
		.uav_read               (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_read),          //                         .read
		.uav_write              (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_write),         //                         .write
		.uav_waitrequest        (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_waitrequest),   //                         .waitrequest
		.uav_readdatavalid      (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_readdatavalid), //                         .readdatavalid
		.uav_byteenable         (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_byteenable),    //                         .byteenable
		.uav_readdata           (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_readdata),      //                         .readdata
		.uav_writedata          (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_writedata),     //                         .writedata
		.uav_lock               (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_lock),          //                         .lock
		.uav_debugaccess        (vj_avalon_master_0_avalon_master_translator_avalon_universal_master_0_debugaccess),   //                         .debugaccess
		.av_address             (i2c_cont_bridge_0_slv_address),                                                       //      avalon_anti_slave_0.address
		.av_write               (i2c_cont_bridge_0_slv_write),                                                         //                         .write
		.av_read                (i2c_cont_bridge_0_slv_read),                                                          //                         .read
		.av_readdata            (i2c_cont_bridge_0_slv_readdata),                                                      //                         .readdata
		.av_writedata           (i2c_cont_bridge_0_slv_writedata),                                                     //                         .writedata
		.av_waitrequest         (i2c_cont_bridge_0_slv_waitrequest),                                                   //                         .waitrequest
		.av_chipselect          (i2c_cont_bridge_0_slv_chipselect),                                                    //                         .chipselect
		.av_begintransfer       (),                                                                                    //              (terminated)
		.av_beginbursttransfer  (),                                                                                    //              (terminated)
		.av_burstcount          (),                                                                                    //              (terminated)
		.av_byteenable          (),                                                                                    //              (terminated)
		.av_readdatavalid       (1'b0),                                                                                //              (terminated)
		.av_writebyteenable     (),                                                                                    //              (terminated)
		.av_lock                (),                                                                                    //              (terminated)
		.av_clken               (),                                                                                    //              (terminated)
		.uav_clken              (1'b0),                                                                                //              (terminated)
		.av_debugaccess         (),                                                                                    //              (terminated)
		.av_outputenable        (),                                                                                    //              (terminated)
		.uav_response           (),                                                                                    //              (terminated)
		.av_response            (2'b00),                                                                               //              (terminated)
		.uav_writeresponsevalid (),                                                                                    //              (terminated)
		.av_writeresponsevalid  (1'b0)                                                                                 //              (terminated)
	);

endmodule
