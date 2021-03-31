import processing.video.*;
import cvimage.*;
import org.opencv.core.*;
import org.opencv.imgproc.Imgproc;

Capture cam;
CVImage img, img2;

ArrayList<FilteredFrame> frames;
boolean creatingFrame, movingFrame;
int filterType, a1, b1, a2, b2, mx, my, startx, starty, endx, endy, chosen;

void setup() {
  size(1040, 540);
  stroke(255);
  noFill();
  textSize(15);

  cam = new Capture(this, 640, 480);
  cam.start();

  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  println(Core.VERSION);

  img = new CVImage(cam.width, cam.height);

  a1 = -1;
  b1 = -1;
  a2 = -1;
  b2 = -1;
  filterType = -1;
  chosen = -1;

  creatingFrame = false;

  frames = new ArrayList<FilteredFrame>();
}

void draw() {
  if (cam.available()) {
    background(0);
    cam.read();

    img.copy(cam, 0, 0, cam.width, cam.height, 0, 0, img.width, img.height);
    image(img, 0, 0);

    if (movingFrame) {
      if (chosen == -1) {
        for (int i = frames.size() - 1; i >= 0; i--) {
          if (mx > frames.get(i).getP1().getX() && mx < frames.get(i).getP2().getX() && my > frames.get(i).getP1().getY() && my < frames.get(i).getP2().getY()) {
            chosen = i;
            break;
          }
        }
      } else {
        int actx = mouseX;
        int acty = mouseY;
        frames.get(chosen).modifyPosition(mouseX - mx, mouseY - my);
        mx = actx;
        my = acty;
      }
    }

    for (FilteredFrame f : frames) {
      startx = f.getP1().getX();
      starty = f.getP1().getY();
      endx = f.getP2().getX();
      endy = f.getP2().getY();

      f.getImg().copy(cam, startx, starty, endx-startx, endy-starty, 0, 0, f.getImg().width, f.getImg().height);
      f.getImg().copyTo();

      switch(f.getFilter()) {        

      case 1:
        Mat gris1 = f.getImg().getGrey();
        cpMat2CVImage(gris1, f.getImg(), endx-startx, endy-starty);
        break;

      case 2:
        Mat gris2 = f.getImg().getGrey();

        int ddepth = CvType.CV_16S;
        Mat grad_x = new Mat();
        Mat grad_y = new Mat();
        Mat abs_grad_x = new Mat();
        Mat abs_grad_y = new Mat();

        Imgproc.Sobel(gris2, grad_x, ddepth, 1, 0);
        Core.convertScaleAbs(grad_x, abs_grad_x);

        Imgproc.Sobel(gris2, grad_y, ddepth, 1, 0);
        Core.convertScaleAbs(grad_y, abs_grad_y);

        Core.addWeighted(abs_grad_x, 0.5, abs_grad_y, 0.5, 0, gris2);

        cpMat2CVImage(gris2, f.getImg(), endx-startx, endy-starty);
        break;

      case 3:
        Mat gris3 = f.getImg().getGrey();
        Imgproc.threshold(gris3, gris3, 105, 255, Imgproc.THRESH_BINARY);
        cpMat2CVImage(gris3, f.getImg(), endx-startx, endy-starty);
        break;

      case 4:
        Mat gris4 = f.getImg().getGrey();
        cpMat2CVImageInv(gris4, f.getImg(), endx-startx, endy-starty);
        break;

      case 5:
        Mat gris5 = f.getImg().getGrey();

        int ddepth2 = CvType.CV_16S;
        Mat grad_x2 = new Mat();
        Mat grad_y2 = new Mat();
        Mat abs_grad_x2 = new Mat();
        Mat abs_grad_y2 = new Mat();

        Imgproc.Sobel(gris5, grad_x2, ddepth2, 1, 0);
        Core.convertScaleAbs(grad_x2, abs_grad_x2);

        Imgproc.Sobel(gris5, grad_y2, ddepth2, 1, 0);
        Core.convertScaleAbs(grad_y2, abs_grad_y2);

        Core.addWeighted(abs_grad_x2, 0.5, abs_grad_y2, 0.5, 0, gris5);

        cpMat2CVImageInv(gris5, f.getImg(), endx-startx, endy-starty);
        break;

      case 6:
        Mat gris6 = f.getImg().getGrey();
        Imgproc.threshold(gris6, gris6, 105, 255, Imgproc.THRESH_BINARY);
        cpMat2CVImageInv(gris6, f.getImg(), endx-startx, endy-starty);
        break;
      }

      image(f.getImg(), startx, starty);
      rect(startx, starty, endx - startx, endy - starty);
    }
  }
  fill(0);
  rect(640, 0, 400, 540);
  rect(0, 480, 1040, 60);
  fill(255);
  text("Press one of the following numbers to create a\nnew Filtered Frame:\n   1.- Grey Scale\n   2.- Border Detection\n   3.- Threshold\n   4.- Inverted Grey Scale\n   5.- Inverted Border Detection\n   6.- Inverted Threshold\nPress SPACE to delete the last frame created\nPress TAB to delete ALL frames\nHold LEFT CLICK to drag the frame around the camera", 645, 20);
  if (creatingFrame) {
    if (a1 == -1 || b1 == -1) {
      text("Click anywhere on the camera to set the start point of the filtered frame", 5, 500);
    } else if (a2 == -1 || b2 == -1) {
      text("Click anywhere on the camera to set the end point of the filtered frame", 5, 500);
    } else {
      frames.add(new FilteredFrame(a1, b1, a2, b2, filterType));
      a1 = -1;
      b1 = -1;
      a2 = -1;
      b2 = -1;
      filterType = -1;
      creatingFrame = false;
    }
  } else {
    text("Choose a filter from the right side to create a new frame\nYou can drag any created frame to modify its position", 5, 500);
  }
  noFill();
}
void keyReleased() {
  if (!creatingFrame) {
    if (key == '1') {
      filterType = 1;
      creatingFrame = true;
    } else if (key == '2') {
      filterType = 2;
      creatingFrame = true;
    } else if (key == '3') {
      filterType = 3;
      creatingFrame = true;
    } else if (key == '4') {
      filterType = 4;
      creatingFrame = true;
    } else if (key == '5') {
      filterType = 5;
      creatingFrame = true;
    } else if (key == '6') {
      filterType = 6;
      creatingFrame = true;
    }
  } 
  if (key == ' ' && !frames.isEmpty()) {
    frames.remove(frames.size()-1);
  }
  if (keyCode == TAB && !frames.isEmpty()) {
    frames.removeAll(frames);
  }
}

void mousePressed() {
  if (!creatingFrame) {
    movingFrame = true;
    mx = mouseX;
    my = mouseY;
  }
}

void mouseReleased() {
  if (!movingFrame && creatingFrame) {
    if (mouseX >= 0 && mouseX <= 640 && mouseY >= 0 && mouseY <= 480) {
      if (a1 == -1 || b1 == -1) {
        a1 = mouseX;
        b1 = mouseY;
      } else {
        a2 = mouseX;
        b2 = mouseY;
      }
    }
  }
  movingFrame = false;
  mx = -1;
  my = -1;
  chosen = -1;
}

class FilteredFrame {

  private Point p1, p2;
  private int filter;
  private CVImage img, pimg;

  FilteredFrame(int x1, int y1, int x2, int y2, int filter) {

    if (x1 > x2) {
      int aux = x2;
      x2 = x1;
      x1 = aux;
    }

    if (y1 > y2) {
      int aux = y2;
      y2 = y1;
      y1 = aux;
    }

    this.p1 = new Point(x1, y1);
    this.p2 = new Point(x2, y2);

    this.filter = filter;
    this.img = new CVImage(x2-x1, y2-y1);

    if (this.filter == 3) {
      this.pimg = new CVImage(x2-x1, y2-y1);
    }
  }

  void modifyPosition(int xinc, int yinc) {
    p1.modify(xinc, yinc);
    p2.modify(xinc, yinc);
  }

  Point getP1() {
    return p1;
  }

  Point getP2() {
    return p2;
  }

  int getFilter() {
    return filter;
  }

  CVImage getImg() {
    return img;
  }

  CVImage getPimg() {
    return pimg;
  }
}

class Point {

  private int x;
  private int y;

  Point(int x, int y) {
    this.x = x;
    this.y = y;
  }

  int getX() {
    return x;
  }

  int getY() {
    return y;
  }

  void modify(int xinc, int yinc) {
    this.x += xinc;
    this.y += yinc;
  }
}

void  cpMat2CVImage(Mat in_mat, CVImage out_img, int aux1, int aux2) {    
  byte[] data8 = new byte[aux1*aux2];

  out_img.loadPixels();
  in_mat.get(0, 0, data8);

  // Cada columna
  for (int x = 0; x < aux1; x++) {
    // Cada fila
    for (int y = 0; y < aux2; y++) {
      // Posición en el vector 1D
      int loc = x + y * aux1;
      //Conversión del valor a unsigned basado en 
      //https://stackoverflow.com/questions/4266756/can-we-make-unsigned-byte-in-java
      int val = data8[loc] & 0xFF;
      //Copia a CVImage
      out_img.pixels[loc] = color(val);
    }
  }
  out_img.updatePixels();
}

void  cpMat2CVImageInv(Mat in_mat, CVImage out_img, int aux1, int aux2) {    
  byte[] data8 = new byte[aux1*aux2];

  out_img.loadPixels();
  in_mat.get(0, 0, data8);

  // Cada columna
  for (int x = 0; x < aux1; x++) {
    // Cada fila
    for (int y = 0; y < aux2; y++) {
      // Posición en el vector 1D
      int loc = x + y * aux1;
      //Conversión del valor a unsigned basado en 
      //https://stackoverflow.com/questions/4266756/can-we-make-unsigned-byte-in-java
      int val = data8[loc] & 0xFF;
      //Copia a CVImage
      out_img.pixels[out_img.pixels.length - loc - 1 ] = color(val);
    }
  }
  out_img.updatePixels();
}
