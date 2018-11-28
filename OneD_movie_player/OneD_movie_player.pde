import java.awt.datatransfer.*;  
import java.awt.dnd.*;  
import java.io.File;  
import java.io.IOException;  
import java.awt.Component;
import java.util.List;

DropTarget dropTarget;
Component component;

//システム変数
int mode = 0;
int max_width = 960;
int ratio_x = 16;
int ratio_y = 4;
boolean cs = false;//true=ratioの比、false=画像サイズ
//動画再生変数
String imgPath = "default.png";
PImage img;
int seq;//現在読み込み中の行数
int imgW;
int imgH;
int fr = 30;//フレームレート


void setup()  {
  
  // てきとうにサイズ設定
  size(640, 480);
  img = loadImage(imgPath);
  imgW = 640;
  imgH = 480;
  frameRate(30);
  // ==================================================
  // ファイルのドラッグ&ドロップをサポートするコード
  // ==================================================
  component = (Component)this.surface.getNative();
  dropTarget = new DropTarget(component, new DropTargetListener() {
    public void dragEnter(DropTargetDragEvent dtde) {}
    public void dragOver(DropTargetDragEvent dtde) {}
    public void dropActionChanged(DropTargetDragEvent dtde) {}
    public void dragExit(DropTargetEvent dte) {}
    public void drop(DropTargetDropEvent dtde) {
      dtde.acceptDrop(DnDConstants.ACTION_COPY_OR_MOVE);
      Transferable trans = dtde.getTransferable();
      List<File> fileNameList = null;
      if(trans.isDataFlavorSupported(DataFlavor.javaFileListFlavor)) {
        try {
          fileNameList = (List<File>)
            trans.getTransferData(DataFlavor.javaFileListFlavor);
        } catch (UnsupportedFlavorException ex) {
          /* 例外処理 */
        } catch (IOException ex) {
          /* 例外処理 */
        }
      }
      if(fileNameList == null) return;
      // ドラッグ&ドロップされたファイルの一覧は一時リストに格納される
      // 以下のように書くと、ファイルのフルパスを表示
      for(File f : fileNameList){
        println(f.getAbsolutePath());
        //新規画像登録へ
        imgPath = f.getAbsolutePath();
        mode=2;
      }
    }
  });
  // ==================================================
  
}

void draw(){
  switch(mode){
    case 0://待機モード
    if(!cs) {
      changeWindowSize(imgW,imgH);
      println("ScreenSize: "+imgW+","+imgH);
      cs = true;
    }
    try{
      image(img, 0, 0);
    }catch(NullPointerException e){
    }
    seq = 0;
    break;
    case 1://再生モード
    try{
      for(int i = 0; i < img.width; i++){
        stroke(img.pixels[img.width * seq + i]);
        strokeWeight(1);
        line(i, 0, i, height);
      }
      seq++;
      if(seq >= img.height) {
        mode = 0;
      }
    }catch(NullPointerException e){
      mode = 0;
    }
    if(cs) {
      changeWindowSize(imgW, int(imgW/ratio_x*ratio_y));
      println("ScreenSize: "+imgW+","+int(imgW/ratio_x*ratio_y));
      cs = false;
    }
    break;
    case 2://新規画像登録モード
    //新規画像登録ここから
        img = loadImage(imgPath);
        try{
          int w = img.width;
          println("元画像サイズ " + img.width + " : " + img.height);
          if(w > max_width){
            w = max_width;
            PGraphics pg = createGraphics(max_width, int((float)max_width/img.width * img.height));
            println("リサイズ定義 "+ max_width +" : "+ int((float)max_width/img.width * img.height));
            pg.beginDraw();
            pg.image(img,0,0,pg.width,pg.height);
            pg.endDraw();
            PImage tempImg = createImage(pg.width,pg.height,RGB);
            pg.loadPixels();
            println(pg.pixels.length);
            for(int y = 0; y < pg.height; y++){
              for(int x = 0; x < pg.width; x++){
                tempImg.pixels[pg.width * y + x] = pg.pixels[pg.width * y + x];
                
              }
            }
            tempImg.updatePixels();
            img = tempImg;
          }
          imgW = img.width;
          imgH = img.height;
          cs = false;
        }catch(NullPointerException e){
          
        }
        mode = 0;
    //ここまで
    break;
    case 3://一時停止モード
    break;
  }
  text(frameRate, 10, 10);
}

void keyPressed(){
  switch(key){
    case ' ':
    if(mode == 1){
      mode = 3;//一時停止モード
    }else{
      mode = 1;//再生モード
    }
    break;
    case CODED:
    switch(keyCode){
      case UP:
      fr+=5;
      frameRate(fr);
      break;
      case DOWN:
      fr-=5;
      frameRate(fr);
      break;
    }
    break;
  }
}

void changeWindowSize(int w, int h) {
  frame.setSize( w + frame.getInsets().left + frame.getInsets().right, h + frame.getInsets().top + frame.getInsets().bottom );
  size(w, h);
}
