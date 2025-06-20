module digit_recognition(
    input clk,
    input rst_n,
    input [7:0] img_data [0:783],  // 输入 28x28 图像数据
    output reg [3:0] digit          // 输出识别结果 0~9
);

reg [15:0] distance [0:9];         // 存储与各模板的距离
integer i, j;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < 10; i = i + 1)
            distance[i] <= 16'd0;
    end else begin
        for (i = 0; i < 10; i = i + 1) begin
            distance[i] = 0;
            for (j = 0; j < 784; j = j + 1) begin
                if (img_data[j] != template[i][j])
                    distance[i] = distance[i] + 1;
            end
        end
    end
end

// 找出最小距离对应的数字
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        digit <= 4'd0;
    else begin
        integer min_index = 0;
        for (i = 1; i < 10; i = i + 1) begin
            if (distance[i] < distance[min_index])
                min_index = i;
        end
        digit <= min_index;
    end
end

// 模板存储器（ROM）
parameter [7:0] template [0:9][0:783] = '{
    0: '{ default: 8'hFF },
    1: '{ default: 8'h00 },
    2: '{ default: 8'h00 },
    3: '{ default: 8'h00 },
    4: '{ default: 8'h00 },
    5: '{ default: 8'h00 },
    6: '{ default: 8'h00 },
    7: '{ default: 8'h00 },
    8: '{ default: 8'h00 },
    9: '{ default: 8'h00 }
};

endmodule