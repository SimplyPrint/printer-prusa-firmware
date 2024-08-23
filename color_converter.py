import os
from PIL import Image


def color_within_tolerance(color1, color2, tolerance):
    return all(abs(a - b) <= tolerance for a, b in zip(color1, color2))


def replace_color_in_image(image_path, target_color, replacement_color, tolerance=30):
    with Image.open(image_path) as img:
        img = img.convert('RGBA')
        data = img.getdata()

        new_data = []
        for item in data:
            # If the pixel color is within the tolerance range, replace it
            if color_within_tolerance(item[:3], target_color, tolerance):
                new_data.append((replacement_color[0], replacement_color[1], replacement_color[2], item[3]))
            else:
                new_data.append(item)

        img.putdata(new_data)
        img.save(image_path)
        print(f"Processed: {image_path}")


def process_images_in_folder(folder_path, target_color, replacement_color, tolerance=30):
    for root, _, files in os.walk(folder_path):
        for filename in files:
            if filename.endswith(".png"):
                image_path = os.path.join(root, filename)
                replace_color_in_image(image_path, target_color, replacement_color, tolerance)


if __name__ == "__main__":
    folder_path = "./Prusa-Firmware-Buddy-DEV/src"  # Update with your folder path
    target_color = (248, 104, 48)  # #ef7f1a in RGB
    replacement_color = (56, 182, 255)  # #000000 in RGB

    # You can adjust the tolerance value if necessary
    process_images_in_folder(folder_path, target_color, replacement_color, tolerance=40)
    target_color = (150, 70, 43)  # #ef7f1a in RGB
    process_images_in_folder(folder_path, target_color, replacement_color, tolerance=40)
    target_color = (206, 123, 90)  # #ef7f1a in RGB
    process_images_in_folder(folder_path, target_color, replacement_color, tolerance=40)
    target_color = (253, 142, 103)  # #ef7f1a in RGB
    process_images_in_folder(folder_path, target_color, replacement_color, tolerance=40)
    target_color = (253, 184, 161)  # #ef7f1a in RGB
    process_images_in_folder(folder_path, target_color, replacement_color, tolerance=40)

