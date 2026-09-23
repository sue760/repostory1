import cv2
import numpy as np
import matplotlib.pyplot as plt

# 1. 读取三张图
img_scenery = cv2.imread('source.jpg')  # 风景图（作为背景）
img_snake = cv2.imread('target.jpg')    # 蛇的图（要抠出来的部分）
img_mask = cv2.imread('mask.jpg', 0)    # 蛇的黑白轮廓


# 2. 找蛇的轮廓位置
thresh = np.where(img_mask > 127, 255, 0).astype(np.uint8)
ys, xs = np.where(thresh > 0)  # 找出所有白色像素的坐标
x, y = np.min(xs), np.min(ys)  # 最左边、最上面的坐标
w = np.max(xs) - x             # 宽度 = 最右边 - 最左边
h = np.max(ys) - y             # 高度 = 最下边 - 最上边

# 3. 设定变换点
# 蛇图（源）的四个角：左上、右上、右下、左下
pts_src = np.float32([[x, y], [x + w, y], [x + w, y + h], [x, y + h]])

# 风景图（目标）的四个角
pts_dst = np.float32([[400, 400], [800, 400], [800, 800], [400, 800]])

# 4. 计算变换矩阵并让蛇变形
H = cv2.getPerspectiveTransform(pts_src, pts_dst)
# 蛇图和Mask都要变形，且尺寸必须和风景图一样大
warped_snake = cv2.warpPerspective(img_snake, H, (img_scenery.shape[1], img_scenery.shape[0]))
warped_mask = cv2.warpPerspective(img_mask, H, (img_scenery.shape[1], img_scenery.shape[0]))

# 再次二值化，防止边缘有灰边
warped_mask = np.where(warped_mask > 127, 255, 0).astype(np.uint8)

# 5. 集合运算
result = np.zeros_like(img_scenery)

# 把变形后的Mask变成布尔值（True代表白色，False代表黑色）
mask_bool = warped_mask > 127

# 手动遍历操作
# 在Mask为白色的地方（True），填入变形后的水怪像素；
# 在Mask为黑色的地方（False），填入原本的风景图像素。
result[mask_bool] = warped_snake[mask_bool]      # 贴水怪
result[~mask_bool] = img_scenery[~mask_bool]    # 贴风景（~表示取反）

# 6. 显示结果并保存
plt.figure(figsize=(10, 10))
plt.title('Snake in Scenery Result')
plt.imshow(cv2.cvtColor(result, cv2.COLOR_BGR2RGB))
plt.axis('off')
plt.show()

cv2.imwrite('output_snake_in_scenery.jpg', result)
print("成功！结果已保存为 output_snake_in_scenery.jpg")