// GPIO模块
module gpio(

    input wire clk,             // 时钟信号
	input wire rst_n,           // 复位信号

    input wire we_i,            // 写使能   
    input wire[31:0] addr_i,    // 写地址
    input wire[31:0] data_i,    // 写数据

    output reg[31:0] data_o,    // 读数据

    input wire[1:0] io_pin_i,   // IO输入
    output wire[31:0] reg_ctrl, // 寄存器控制
    output wire[31:0] reg_data  // 寄存器数据

    );
    /*
    reg_ctrl,reg_data:用于外部模块访问GPIO内部控制寄存器的接口，从而知道GPIO目前的状态
    we_i,addr_i,data_i:用于外部模块对GPIO进行写操作的接口，地址addr_i用于选择对控制寄存器写入还是对输出寄存器写入
    */

    // GPIO控制寄存器
    localparam GPIO_CTRL = 4'h0;
    // GPIO数据寄存器
    localparam GPIO_DATA = 4'h1;//字地址

    // 每2位控制1个IO的模式，最多支持16个IO
    // 0: 高阻，1：输出，2：输入
    reg[31:0] gpio_ctrl;
    // 输入输出数据
    reg[31:0] gpio_data;


    assign reg_ctrl = gpio_ctrl;
    assign reg_data = gpio_data;


    // 读写寄存器
    always @ (posedge clk) begin
        if (rst_n == 1'b0) begin
            gpio_data <= 32'h0;
            gpio_ctrl <= 32'h0;
        end else begin
            if (we_i == 1'b1) begin
                case (addr_i[3:0])
                    GPIO_CTRL: begin
                        gpio_ctrl <= data_i;
                        data_o <= data_i;
                    end
                    GPIO_DATA: begin
                        gpio_data <= data_i;
                        data_o <= data_i;
                    end
                endcase
            end else begin
                if (gpio_ctrl[1:0] == 2'b10) begin  //若为输入模式  则将IO上的输入数据写入gpio_data
                    gpio_data[0] <= io_pin_i[0];
                end
                if (gpio_ctrl[3:2] == 2'b10) begin
                    gpio_data[1] <= io_pin_i[1];
                end
                case (addr_i[3:0])
                    GPIO_CTRL: begin
                        data_o <= gpio_ctrl;
                    end
                    GPIO_DATA: begin
                        data_o <= gpio_data;
                    end
                endcase
            end
        end
    end

endmodule
