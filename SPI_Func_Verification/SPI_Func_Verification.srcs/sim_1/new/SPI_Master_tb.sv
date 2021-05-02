module SPI_Master_tb ();


/*YAPILAB?LECEK TESTLER

1-FIXED DATA MOSI-MISO LOOPBACK
2-RANDOM DATA MOSI-MISO LOOPBACK
3-BEL?RLENEN SAYIDA RANDOM LOOPBACK ?LE SCOREBOARD OLU?TURMA
4- 4 FARKLI SPI MODE için yine scoreboard

*/

  
  parameter SPI_MODE = 0;
  parameter CLKS_PER_HALF_BIT = 2;    


// Interconnect sinyalleri ve ilklendirilmeleri
  logic r_Rst_L     = 1'b0;  
  logic w_SPI_Clk;
  logic r_Clk       = 1'b0;
  logic w_SPI_MOSI;

 
  logic [7:0] r_Master_TX_Byte = 0;
  logic r_Master_TX_DV = 1'b0;
  logic w_Master_TX_Ready;
  logic r_Master_RX_DV;
  logic [7:0] r_Master_RX_Byte;

  // Clock sinyalleri üretimi
  always #2 r_Clk = ~r_Clk; //2 ns de bir clock toggle lama 

  // DUT Tan?mlama
  SPI_Master 
  #(.SPI_MODE(SPI_MODE),
    .CLKS_PER_HALF_BIT(CLKS_PER_HALF_BIT)) SPI_Master_DUT
  (
   // Control ve Data sinyalleri,
   .i_Rst_L(r_Rst_L),     // FPGA Reset
   .i_Clk(r_Clk),         // FPGA Clock
   
   // TX (MOSI) Sinyalleri
   .i_TX_Byte(r_Master_TX_Byte),     // MOSI 'den transmit edilecek data
   .i_TX_DV(r_Master_TX_DV),         // transmit gerçekle?mesi için gerekli valid sinyali
   .o_TX_Ready(w_Master_TX_Ready),   // transmite haz?r sinyali
   
   // RX (MISO) Sinyalleri
   .o_RX_DV(r_Master_RX_DV),       // receive gerçekle?mesi için gerekli valid sinyali
   .o_RX_Byte(r_Master_RX_Byte),   // bütün byte receive edildi sinyali

   // SPI Interface
   .o_SPI_Clk(w_SPI_Clk),
   .i_SPI_MISO(w_SPI_MOSI),  //MOSI datas? MISO 'ya loopback yap?l?yor
   .o_SPI_MOSI(w_SPI_MOSI)
   );


  // Sends a single byte from master.
  task SendSingleByte(input [7:0] data);
    @(posedge r_Clk);
    r_Master_TX_Byte <= data; //Transmit edilecek datay? yaz
    r_Master_TX_DV   <= 1'b1; //Transmit valid i high a çek
    @(posedge r_Clk);
    r_Master_TX_DV <= 1'b0; //Transmit valid i low a çek
    @(posedge w_Master_TX_Ready); //Sonraki byte transferine haz?r sinyalini bekle
  endtask 

  
  initial
    begin
      
      repeat(10) @(posedge r_Clk);
      r_Rst_L  = 1'b1;
      
            // Tek byte transmit testi
      SendSingleByte(8'hEA);
      $display("Sent out 0xEA, Received 0x%X", r_Master_RX_Byte);
      
      repeat(10) @(posedge r_Clk);
      r_Rst_L          = 1'b0;
      
      //Tek byte transmit testi
      SendSingleByte(8'h35);
      $display("Sent out 0xEA, Received 0x%X", r_Master_RX_Byte);    

      repeat(10) @(posedge r_Clk);
      $finish();      
    end 

endmodule 



