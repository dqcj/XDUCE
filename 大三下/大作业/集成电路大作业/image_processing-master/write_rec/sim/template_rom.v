module template_rom(
    input [3:0] digit,
    input [9:0] index,
    output reg [7:0] template_pixel
);

// 每个数字模板大小为 28x28 = 784 pixels
parameter [7:0] template_data [0:9][0:783] = '{
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

always @(*) begin
    template_pixel = template_data[digit][index];
end

endmodule