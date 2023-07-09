int gamemode = 1;
int point = 0;                    //ポイント
float travelTime = 60000;          //ゴールまでの時間(ミリ秒)
float startTime;                   //ゲームプレイ時間
int r = 100;
int g = 255;
int b = 100;
//--------------------------------------------↓
//Ball(投げる)というクラスを作る　変数4 関数2
class Ball {
  //Ballが持つ変数
  float x, y, v, t, t0;
  float x0, y0;       //ボールの移動位置開始
  float v0x, v0y;

  //new命令でボールを作った時に実行される特殊な関数
  //この関数には返り値を指定しない
  //(この関数をコンストラクタと呼ぶ)
  Ball(float _x, float _y, float _v0x, float _v0y) {
    x0 = _x;  //移動開始時のx座標値の初期化
    y0 = _y;  //移動開始時のy座標値の初期化
    x = _x;   //x座標値の初期化
    y = _y;   //y座標値の初期化
    v0x = _v0x;  //x方向の初速度
    v0y = _v0y;  //y方向の初速度
    t0 = millis() / 1000.0;  //この関数を実行したときの時刻
    t = 0;   //時刻tの初期化
  }

  //現在位置にボールを表示する関数
  void show() {
    fill(0, 255, 0);
    ellipse(x, y, 50, 50);
    if (x >= width) {
      v0x = -v0x;
    }
  }

  //現在位置を更新する関数
  void update() {
    t = millis() / 1000.0 - t0; //tの更新
    float g = 980.0;
    x = x0 + v0x * t;
    y = y0 +v0y * t + 0.5 * g * t * t;
  }
}
//--------------------------------------↑

//大域関数
Ball ball; //ボールの変数b
float ts, te, xs, xe, ys, ye;//初速度をもとめるための変数


//
void mousePressed() {
  ts = millis() / 1000.0; //現在の時間を記憶
  xs = mouseX;
  ys = mouseY;
}
//
void mouseReleased() {
  te = millis() / 1000.0; //現在時間を記憶
  if (mouseX <= width/4) {
    if (mouseY >= height/4) {
      xe = mouseX;
      ye = mouseY;
      float v0x = (xe -xs) / (te - ts); //x方向の初速度を計算
      float v0y = (ye - ys) / (te - ts); //y方向の初速度を計算
      ball = new Ball(xe, ye, v0x, v0y);
    }
  }
}
//
//
//
//-------------------------------------------------------↓
//的のクラス
class GOAL {
  float x1, y1, x2, y2, size1, size2, t0, t1, x0, v, wallx, wally; //的の座標 + 的の移動のための変数
  boolean atari1, atari2; //当たりのときtrue、そうでなければfalse

  //的のコンストラクタ
  GOAL() {
    x0 = 250;
    y1 = 300;
    x2 = random(400, 800);
    y2 = random(300, 500);
    t1 = 0;
    t0 = millis() / 1000.0;
    v = 100;
    wallx = 0;
    wally = 0;
    atari1 = false;
    atari2 = false;
  }
  //的を表示する関数
  void show() {
    float kyori1 = dist(x1, y1, ball.x, ball.y);
    if (ball.y <= y1 && kyori1 <= 75) {
      if (atari1 == false) {
        println("的1に当たりました");
        point++;
        score();
      }
      atari1 = true;
      fill(255, 0, 0);
    } else {
      atari1 = false;
      fill(255);
    }
    ellipse(x1, y1, 200, 50);

    fill(0, 0, 255);
  }
  //ゴールを動かす関数
  void update() {
    float t = millis() / 1000.0 - t0; // 現在の時間を計算
    x1 = v * t + x0; // 的の位置を更新

    // 右端に到達した場合の処理
    if (x1 >= width - 100) {
      float overshoot = x1 - (width - 100); // 右端を超えた距離を計算
      x0 = (width-100) - overshoot; // 初期値を現在位置に設定する
      t0 = millis() / 1000.0; // 時間の基準を更新
      t1 = overshoot / v; // ★t1を調整して的が正しい速度で動くようにする
      v = -v; // 速度を反転させる
    }
    // 左端に到達した場合の処理
    else if (x1 <= 2 * width / 3) {
      x0 = 2 * width / 3 +1; // 的を現在位置に戻す
      t0 = millis() / 1000.0; // 時間の基準を更新
      t1 = -x1 / v; // ★t1を調整して的が正しい速度で動くようにする
      v = -v; // 速度を反転させる
    }
  }

  void score() {
    fill(0);
    textSize(40);
    text("Score: " + point, width - 3*width /5, 30);
  }
  void wall() {
    wallx = x1+100;
    wally = y1-250;
    rect(wallx, wally, 30, 250);
  }
}
//--------------------------------------------------------------↑
//ゴールの動かす関数
GOAL goal;

void wallattack() {
  if (ball.x >= goal.wallx && ball.x <= goal.wallx + 30) {
    if (ball.y >= goal.wally && ball.y <= goal.y1) {
      float v0x = - (xe -xs) / (te - ts); //x方向の初速度を計算
      float v0y = - (ye - ys) / (te - ts); //y方向の初速度を計算
      ball = new Ball(ball.x, ball.y, v0x, v0y);
    }
  }
}



void changeGameMode() {
  if (keyPressed == true) {
    if (key == ' ') {
      startTime = millis();
      gamemode = 2;
    }
  }
}

//
void setup() {
  size(1000, 800);
  ball = new Ball(width+100, 0, 0, 0);
  goal = new GOAL();
}

void draw() {
  background(255);
  if (gamemode == 1) opening();
  else if (gamemode == 2) gamePlay();
  else if (gamemode == 3) ending();
}

void timer() {
  float halftime = 30000;
  //プレイ経過時間が60秒以上ならゲームクリア状態にする
  float elapsedTime = millis() - startTime;
  if (halftime >= travelTime) {
    r = 255;
    g = 255;
    b = 0;
  }
  if (elapsedTime >= travelTime)gamemode = 3;

  //ゲームクリアまでの残り時間を表示
  fill(r, g, b);
  textSize(70);
  textAlign(RIGHT, TOP);
  int remain = (int)(travelTime - elapsedTime) / 1000;
  text(remain, width/2, 20);
}

void opening() {
  fill(0);
  textSize(50);
  textAlign(CENTER, CENTER);
  text("Basketball Game", width/2, height/2);
  text("PRESS SPACE KEY TO START", width/2, height/2+50);

  changeGameMode();
}

void gamePlay() {
  fill(255);
  rect(0, 400, 200, 600);
  ball.update();
  ball.show();
  goal.show();
  goal.update();
  goal.score();
  goal.wall();
  timer();
  wallattack();
}

void ending() {
  fill(0);
  textSize(40);
  text("END!", 500, 400);
  text("score:" + point, 500, 600);
  changeGameMode();
}
