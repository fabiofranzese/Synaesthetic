class aP{

    constructor(_i,_f){
  
      this.pos = createVector(0,0);
      this.vel = createVector(0,0);
      this.center = createVector(0,0);
      this.id = _i;
      this.size =_f*2+4;
      this.freq = _f;
      this.amp = 0;
    
    }
    
    
    updateMe(){
    
      let t = millis()*.0004;
   
      let a = noise(this.id,t*.18)*TWO_PI*2;
      
      
      if(this.freq == 0){this.amp = sub_freq/255;}
      if(this.freq == 1){this.amp= low_freq/255;}
      if(this.freq == 2){this.amp = mid_freq/255;}
      if(this.freq == 3){this.amp = hi_freq/255;}
      if(this.freq == 4){this.amp = treble_freq/255;}
      
     this.pos.x += sin(a)*this.amp *  3.2 * (this.freq+1)  ;
     this.pos.y += cos(a)*this.amp *  3.2 * (this.freq+1)  ;
      
      this.center.x =  w *.5 - this.pos.x   ;
      this.center.y =  h *.5-  this.pos.y  ;
      
      let magi = this.center.mag();
  
     let cf =  this.center.normalize();  
      
      // apply center force 
       this.pos.y += this.center.y*magi*.014;
       this.pos.x += this.center.x*magi*.014;
      
      // particle stay within stage bounaries
      if(this.pos.x>w){ this.pos.x = 0; }
      if(this.pos.x<0){ this.pos.x =w ; }
      
      if(this.pos.y>h){ this.pos.y = 0; }
      if(this.pos.y<0){ this.pos.y =h ; }
      
      noStroke();

    // Effetto gradiente radiale che cambia nel tempo
    let distFromCenter = dist(this.pos.x, this.pos.y, w / 2, h / 2);
    let maxDist = dist(0, 0, w / 2, h / 2);

    // Parametro per variare il colore nel tempo
    let timeColorShift = map(sin(t), -1, 1, 0, 1);

    // Colore graduale dal centro ai bordi, con cambiamento temporale
    let gradientColor = lerpColor(
      color(255 * timeColorShift, 100, 150), // Colore al centro
      color(100, 150, 255 * (1 - timeColorShift)), // Colore ai bordi
      distFromCenter / maxDist // Gradiente radiale
    );

    fill(gradientColor);

      let psize = 6 + (5-this.freq)*2 *this.amp*.6
      ellipse(this.pos.x,this.pos.y, psize );
    
    }
  }
