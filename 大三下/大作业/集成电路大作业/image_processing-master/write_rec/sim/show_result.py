from PIL import Image
import numpy as np
import matplotlib.pyplot as plt

def read_image(path):
    with open(path, 'r') as f:
        data = [int(line.strip(), 16) for line in f.readlines()]
    return np.array(data).reshape((28, 28))

# 加载输入图像
input_img = read_image("digit_3.txt")

plt.figure(figsize=(5, 5))
plt.subplot(1, 2, 1)
plt.imshow(input_img, cmap='gray')
plt.title("Input Image")

# 假设识别结果是 3
recognized_digit = 3
recognized_img = plt.imread(f"templates/{recognized_digit}.bmp")
plt.subplot(1, 2, 2)
plt.imshow(recognized_img, cmap='gray')
plt.title(f"Recognized Digit: {recognized_digit}")

plt.show()