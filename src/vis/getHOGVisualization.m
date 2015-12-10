function img = getHOGVisualization(f, bs)

scale = max(max(f(:)),max(-f(:)));

img = HOGpicture(f, bs) * 255/scale;