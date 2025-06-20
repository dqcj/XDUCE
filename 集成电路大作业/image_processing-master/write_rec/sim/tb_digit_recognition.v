module tb_digit_recognition;

reg clk;
reg rst_n;
reg [7:0] img_data [0:783];
wire [3:0] digit;

// 实例化识别模块
digit_recognition uut (
    .clk(clk),
    .rst_n(rst_n),
    .img_data(img_data),
    .digit(digit)
);

// 初始化测试图像
initial begin
    $readmemh("digit_3.txt", img_data);  // 从文本读取图像数据
    rst_n = 0;
    #100 rst_n = 1;
end

// 生成时钟
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// 显示识别结果
initial begin
    $monitor("Recognized Digit: %d", digit);
end

endmodule